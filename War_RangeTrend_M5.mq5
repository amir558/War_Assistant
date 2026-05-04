//+------------------------------------------------------------------+
//|                                          War_RangeTrend_M5.mq5   |
//|   Trend-first (H1), range floor/ceiling on M5, fixed 0.01 lot   |
//|   Close entire position when profit >= InpCloseProfitUsd         |
//|   Range breakout entry after confirmation candle                 |
//+------------------------------------------------------------------+
#property copyright "War Assistant"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

const long InpMagicNumber = 20260505;
CTrade     g_trade;

input ENUM_TIMEFRAMES InpTrendTimeframe = PERIOD_H1;
input ENUM_TIMEFRAMES InpWorkTimeframe  = PERIOD_M5;

input double InpFixedLot            = 0.01;
input double InpCloseProfitUsd      = 4.0;
input int    InpMaxSpreadPoints     = 150;
input int    InpSlippagePoints      = 30;
input int    InpRangeLookbackBars   = 72;
input double InpRangeBottomMaxPct   = 0.32;
input double InpRangeTopMinPct      = 0.68;
input int    InpSwingLeft           = 2;
input int    InpSwingRight          = 2;
input int    InpTrendLookbackBars   = 100;
input int    InpAtrPeriod            = 14;
input double InpBreakBodyAtrMult     = 0.35;
input double InpWickToBodyRatio      = 1.15;
input int    InpStopBufferPoints     = 80;
input int    InpBreakCooldownBars    = 8;
input double InpMaxDailyLossUsd      = 35.0;
input int    InpMaxTradesPerDay      = 30;
input bool   InpBlockCounterStrong   = true;

int g_atrWorkHandle = INVALID_HANDLE;
int g_tradesToday   = 0;
int g_lastDayId     = -1;
double g_dayStartEquity = 0.0;
datetime g_lastBreakoutBarTime = 0;

enum ENUM_TREND_BIAS
{
   TREND_BULL_STRONG = 0,
   TREND_BULL_WEAK = 1,
   TREND_BEAR_STRONG = 2,
   TREND_BEAR_WEAK = 3,
   TREND_RANGE = 4
};

struct SwingPt
{
   double price;
   int    index;
};

bool isNewBarWork(datetime &storedTime)
{
   const datetime t = iTime(_Symbol, InpWorkTimeframe, 0);
   if(t == 0)
   {
      return false;
   }
   if(t != storedTime)
   {
      storedTime = t;
      return true;
   }
   return false;
}

bool swingHighRates(const MqlRates &r[], const int i, const int L, const int R)
{
   const double h = r[i].high;
   for(int k = 1; k <= L; k++)
   {
      if(r[i - k].high >= h)
      {
         return false;
      }
   }
   for(int k = 1; k <= R; k++)
   {
      if(r[i + k].high > h)
      {
         return false;
      }
   }
   return true;
}

bool swingLowRates(const MqlRates &r[], const int i, const int L, const int R)
{
   const double l = r[i].low;
   for(int k = 1; k <= L; k++)
   {
      if(r[i - k].low <= l)
      {
         return false;
      }
   }
   for(int k = 1; k <= R; k++)
   {
      if(r[i + k].low < l)
      {
         return false;
      }
   }
   return true;
}

void collectSwingsNewestLast(const MqlRates &r[], SwingPt &outHighs[], SwingPt &outLows[])
{
   ArrayResize(outHighs, 0);
   ArrayResize(outLows, 0);
   const int n = ArraySize(r);
   if(n < InpSwingLeft + InpSwingRight + 5)
   {
      return;
   }
   for(int i = InpSwingLeft; i < n - InpSwingRight; i++)
   {
      if(swingHighRates(r, i, InpSwingLeft, InpSwingRight))
      {
         const int m = ArraySize(outHighs);
         ArrayResize(outHighs, m + 1);
         outHighs[m].price = r[i].high;
         outHighs[m].index = i;
      }
      if(swingLowRates(r, i, InpSwingLeft, InpSwingRight))
      {
         const int m = ArraySize(outLows);
         ArrayResize(outLows, m + 1);
         outLows[m].price = r[i].low;
         outLows[m].index = i;
      }
   }
}

bool seqHigherNewestFirst(const SwingPt &p[], const int need)
{
   const int n = ArraySize(p);
   if(n < need)
   {
      return false;
   }
   for(int i = 0; i < need - 1; i++)
   {
      if(p[i].price <= p[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool seqLowerNewestFirst(const SwingPt &p[], const int need)
{
   const int n = ArraySize(p);
   if(n < need)
   {
      return false;
   }
   for(int i = 0; i < need - 1; i++)
   {
      if(p[i].price >= p[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool overlapMinMax(const SwingPt &h[], const SwingPt &l[])
{
   if(ArraySize(h) < 2 || ArraySize(l) < 2)
   {
      return true;
   }
   return (MathMin(h[0].price, h[1].price) - MathMax(l[0].price, l[1].price)) > 0.0;
}

ENUM_TREND_BIAS classifyTrendBias()
{
   MqlRates r[];
   if(CopyRates(_Symbol, InpTrendTimeframe, 0, InpTrendLookbackBars, r) != InpTrendLookbackBars)
   {
      return TREND_RANGE;
   }
   ArraySetAsSeries(r, true);
   SwingPt highs[];
   SwingPt lows[];
   collectSwingsNewestLast(r, highs, lows);
   const bool bull = seqHigherNewestFirst(highs, 2) && seqHigherNewestFirst(lows, 2);
   const bool bear = seqLowerNewestFirst(lows, 2) && seqLowerNewestFirst(highs, 2);
   if(bull && !bear)
   {
      if(!overlapMinMax(highs, lows))
      {
         return TREND_BULL_STRONG;
      }
      return TREND_BULL_WEAK;
   }
   if(bear && !bull)
   {
      if(!overlapMinMax(highs, lows))
      {
         return TREND_BEAR_STRONG;
      }
      return TREND_BEAR_WEAK;
   }
   return TREND_RANGE;
}

void getRangeBoxM5(double &outLo, double &outHi, bool &ok)
{
   ok = false;
   outLo = 0.0;
   outHi = 0.0;
   MqlRates r[];
   if(CopyRates(_Symbol, InpWorkTimeframe, 0, InpRangeLookbackBars, r) != InpRangeLookbackBars)
   {
      return;
   }
   ArraySetAsSeries(r, true);
   double mn = r[0].low;
   double mx = r[0].high;
   for(int i = 0; i < InpRangeLookbackBars; i++)
   {
      if(r[i].low < mn)
      {
         mn = r[i].low;
      }
      if(r[i].high > mx)
      {
         mx = r[i].high;
      }
   }
   outLo = mn;
   outHi = mx;
   ok = (mx > mn);
}

bool longLowerWick(const MqlRates &c)
{
   const double body = MathAbs(c.close - c.open);
   const double w = MathMin(c.open, c.close) - c.low;
   if(body < _Point * 0.25)
   {
      return w >= InpWickToBodyRatio * _Point * 5.0;
   }
   return w >= InpWickToBodyRatio * body;
}

bool longUpperWick(const MqlRates &c)
{
   const double body = MathAbs(c.close - c.open);
   const double w = c.high - MathMax(c.open, c.close);
   if(body < _Point * 0.25)
   {
      return w >= InpWickToBodyRatio * _Point * 5.0;
   }
   return w >= InpWickToBodyRatio * body;
}

bool getWorkAtr(const int shift, double &atr)
{
   double b[];
   ArraySetAsSeries(b, true);
   if(CopyBuffer(g_atrWorkHandle, 0, shift, 2, b) < 2)
   {
      return false;
   }
   atr = b[shift];
   return atr > 0.0;
}

void resetDayCounters()
{
   const datetime t = iTime(_Symbol, InpWorkTimeframe, 0);
   if(t == 0)
   {
      return;
   }
   MqlDateTime dt;
   TimeToStruct(t, dt);
   const int dayId = dt.year * 10000 + dt.mon * 100 + dt.day;
   if(dayId != g_lastDayId)
   {
      g_lastDayId = dayId;
      g_tradesToday = 0;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   }
}

bool spreadOk()
{
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) <= InpMaxSpreadPoints;
}

bool dailyLossBlocked()
{
   if(InpMaxDailyLossUsd <= 0.0 || g_dayStartEquity <= 0.0)
   {
      return false;
   }
   const double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   return (g_dayStartEquity - eq) >= InpMaxDailyLossUsd;
}

int countOurPositions()
{
   int c = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t))
      {
         continue;
      }
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
      {
         continue;
      }
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
      {
         continue;
      }
      c++;
   }
   return c;
}

void closePositionsIfProfitTarget()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t))
      {
         continue;
      }
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
      {
         continue;
      }
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
      {
         continue;
      }
      if(PositionGetDouble(POSITION_PROFIT) >= InpCloseProfitUsd)
      {
         g_trade.PositionClose(t);
      }
   }
}

double normalizeFixedLot()
{
   double lot = InpFixedLot;
   const double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0.0)
   {
      lot = MathFloor(lot / step) * step;
   }
   if(lot < minLot)
   {
      lot = minLot;
   }
   if(lot > maxLot)
   {
      lot = maxLot;
   }
   return lot;
}

bool tryBuy(const double sl, const double tp, const string tag)
{
   resetDayCounters();
   if(dailyLossBlocked() || g_tradesToday >= InpMaxTradesPerDay || countOurPositions() > 0)
   {
      return false;
   }
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double lot = normalizeFixedLot();
   if(!g_trade.Buy(lot, _Symbol, ask, sl, tp, "wrt5|" + tag))
   {
      return false;
   }
   g_tradesToday++;
   return true;
}

bool trySell(const double sl, const double tp, const string tag)
{
   resetDayCounters();
   if(dailyLossBlocked() || g_tradesToday >= InpMaxTradesPerDay || countOurPositions() > 0)
   {
      return false;
   }
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double lot = normalizeFixedLot();
   if(!g_trade.Sell(lot, _Symbol, bid, sl, tp, "wrt5|" + tag))
   {
      return false;
   }
   g_tradesToday++;
   return true;
}

bool allowLongByTrend(const ENUM_TREND_BIAS tr)
{
   if(!InpBlockCounterStrong)
   {
      return true;
   }
   return tr != TREND_BEAR_STRONG;
}

bool allowShortByTrend(const ENUM_TREND_BIAS tr)
{
   if(!InpBlockCounterStrong)
   {
      return true;
   }
   return tr != TREND_BULL_STRONG;
}

int barsSinceWorkTime(const datetime tBar)
{
   if(tBar <= 0)
   {
      return 999999;
   }
   const int sh = iBarShift(_Symbol, InpWorkTimeframe, tBar, false);
   return (sh < 0) ? 999999 : sh;
}

int OnInit()
{
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   const int fm = (int)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((fm & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
   {
      g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   }
   else if((fm & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
   {
      g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   }
   else
   {
      g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }
   g_atrWorkHandle = iATR(_Symbol, InpWorkTimeframe, InpAtrPeriod);
   if(g_atrWorkHandle == INVALID_HANDLE)
   {
      return INIT_FAILED;
   }
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(g_atrWorkHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atrWorkHandle);
   }
}

void OnTick()
{
   closePositionsIfProfitTarget();
   if(!spreadOk())
   {
      return;
   }
   static datetime lastBar = 0;
   if(!isNewBarWork(lastBar))
   {
      return;
   }
   resetDayCounters();
   if(dailyLossBlocked())
   {
      return;
   }
   if(countOurPositions() > 0)
   {
      return;
   }
   const ENUM_TREND_BIAS trend = classifyTrendBias();
   MqlRates r[];
   if(CopyRates(_Symbol, InpWorkTimeframe, 0, 6, r) != 6)
   {
      return;
   }
   ArraySetAsSeries(r, true);
   double atr = 0.0;
   if(!getWorkAtr(1, atr))
   {
      return;
   }
   double boxLo = 0.0;
   double boxHi = 0.0;
   bool boxOk = false;
   getRangeBoxM5(boxLo, boxHi, boxOk);
   if(!boxOk)
   {
      return;
   }
   const double width = boxHi - boxLo;
   if(width <= _Point * 10.0)
   {
      return;
   }
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double pos = (bid - boxLo) / width;
   const MqlRates &c1 = r[1];
   const double buf = (double)InpStopBufferPoints * _Point;
   const double minBody = InpBreakBodyAtrMult * atr;
   const bool prevInside = (r[2].high <= boxHi && r[2].low >= boxLo);
   const double body1 = MathAbs(c1.close - c1.open);
   if(prevInside && c1.close > boxHi && c1.close > c1.open && body1 >= minBody && allowLongByTrend(trend))
   {
      if(barsSinceWorkTime(g_lastBreakoutBarTime) >= InpBreakCooldownBars)
      {
         const double sl = c1.low - buf;
         const double tp = 0.0;
         if(sl < ask && tryBuy(sl, tp, "BRK_UP"))
         {
            g_lastBreakoutBarTime = c1.time;
         }
      }
      return;
   }
   if(prevInside && c1.close < boxLo && c1.close < c1.open && body1 >= minBody && allowShortByTrend(trend))
   {
      if(barsSinceWorkTime(g_lastBreakoutBarTime) >= InpBreakCooldownBars)
      {
         const double sl = c1.high + buf;
         const double tp = 0.0;
         if(sl > bid && trySell(sl, tp, "BRK_DN"))
         {
            g_lastBreakoutBarTime = c1.time;
         }
      }
      return;
   }
   if(pos > InpRangeBottomMaxPct && pos < InpRangeTopMinPct)
   {
      return;
   }
   if(pos <= InpRangeBottomMaxPct && allowLongByTrend(trend) && longLowerWick(c1))
   {
      const double sl = MathMin(c1.low, r[2].low) - buf;
      const double tp = 0.0;
      if(sl < ask)
      {
         tryBuy(sl, tp, "RNG_BUY");
      }
      return;
   }
   if(pos >= InpRangeTopMinPct && allowShortByTrend(trend) && longUpperWick(c1))
   {
      const double sl = MathMax(c1.high, r[2].high) + buf;
      const double tp = 0.0;
      if(sl > bid)
      {
         trySell(sl, tp, "RNG_SELL");
      }
   }
}
