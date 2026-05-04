//+------------------------------------------------------------------+
//|                                                         war.mq5   |
//|   Ahangari methodology EA: Trend > Level > Slope (written plan)   |
//|   Miner + Range (FTB-style) + strong-trend direction filter       |
//+------------------------------------------------------------------+
#property copyright "War Assistant"
#property link      ""
#property version   "1.12"
#property strict

#include <Trade\Trade.mqh>

//--- Magic & trade
const long InpMagicNumber = 20260504;
CTrade g_trade;

//--- Timeframes (document: D1, H4, H1, M30 — simplified to bias + signal)
input ENUM_TIMEFRAMES InpBiasTimeframe   = PERIOD_H4;
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M15;

//--- Risk & execution (document: ideal 1.5–2% total open risk; formula lot sizing)
input double InpRiskPercentIdeal = 1.5;
input double InpRiskPercentNormal = 1.0;
input int    InpTradeMode        = 1; // 0 ideal, 1 normal, 2 high risk (0.5%)
input int    InpMaxSpreadPoints  = 120;
input int    InpSlippagePoints   = 30;
input bool   InpOneTradePerBar   = true;
input double InpMaxLotsHardCap   = 0.08;
input int    InpMinStopPointsForLotSizing = 250;
input double InpMinStopAtrMultForLotSizing = 0.75;
input double InpMaxRiskMoneyPerTrade = 15.0;
input double InpMaxDailyLossPercent = 4.0;
input double InpMaxEquityDrawdownFromPeakPercent = 25.0;

//--- Structure (swing / minor)
input int    InpSwingLeft        = 2;
input int    InpSwingRight       = 2;
input int    InpStructureLookback = 120;

//--- Range (document: no mid-range; bottom buyer / top seller; 50 pip split rule)
input int    InpRangeBoxBars    = 80;
input double InpRangeMiddleMinRatio = 0.40;
input double InpRangeMiddleMaxRatio = 0.60;
input int    InpRangeMaxPipsForSingleTp = 50;
input double InpRangeWideWidthAtrMult = 2.5;
input double InpRangeSlBufferAtrMult = 0.35;
input int    InpRangeCooldownBars = 24;
input double InpRangeMinRewardToRisk = 0.65;
input double InpWickToBodyMinRatio = 1.2;
input bool   InpRangeRequireBothTfRange = false;
input double InpRangeMaxWidthAtrMult = 6.0;
input bool   InpRangeRequireMinorTouch = false;

//--- Miner (document: S/R + break of last minor trend + 2-candle engulf + breakout quality)
input bool   InpUseMinerStrategy = true;
input double InpBreakoutAtrMult  = 1.2;
input int    InpAtrPeriod        = 14;
input double InpLevelTouchAtrFrac = 0.9;

//--- Trend filter (document: no counter-trend in strong trend; range both sides)
input bool   InpBlockCounterInStrongTrend = true;
input bool   InpMinerRequireTrendAgreement = false;

//--- Safety
input int    InpMaxOpenPositions = 1;
input int    InpMaxTradesPerDay  = 8;

//--- Indicator handles
int g_atrBiasHandle   = INVALID_HANDLE;
int g_atrSignalHandle = INVALID_HANDLE;

int      g_tradesToday       = 0;
int      g_lastTradeDay      = -1;
datetime g_lastRangeBuyBarTime  = 0;
datetime g_lastRangeSellBarTime = 0;
double   g_dayStartBalance      = 0.0;
double   g_sessionPeakEquity    = 0.0;

enum ENUM_MARKET_REGIME
{
   REGIME_RANGE = 0,
   REGIME_BULL_STRONG = 1,
   REGIME_BULL_WEAK = 2,
   REGIME_BEAR_STRONG = 3,
   REGIME_BEAR_WEAK = 4,
   REGIME_UNKNOWN = 5
};

struct SwingPoint
{
   datetime time;
   double   price;
   int      index;
};

bool isNewBar(const ENUM_TIMEFRAMES tf, datetime &storedTime)
{
   const datetime t = iTime(_Symbol, tf, 0);
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

double getPipSize()
{
   const int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(_Symbol != NULL && StringFind(_Symbol, "JPY", 0) >= 0)
   {
      return point * 10.0;
   }
   if(digits == 3 || digits == 5)
   {
      return point * 10.0;
   }
   return point * 10.0;
}

double priceToPips(const double distancePrice)
{
   const double pip = getPipSize();
   if(pip <= 0.0)
   {
      return 0.0;
   }
   return distancePrice / pip;
}

int barsSinceSignalBarTime(const datetime barOpenTime)
{
   if(barOpenTime <= 0)
   {
      return 999999;
   }
   const int sh = iBarShift(_Symbol, InpSignalTimeframe, barOpenTime, false);
   if(sh < 0)
   {
      return 999999;
   }
   return sh;
}

bool isWideRangeBox(const double rangeLow, const double rangeHigh, const double atrSignal, const double widthPips)
{
   const double w = rangeHigh - rangeLow;
   if(w <= 0.0)
   {
      return false;
   }
   if(widthPips > (double)InpRangeMaxPipsForSingleTp)
   {
      return true;
   }
   if(atrSignal > 0.0 && InpRangeWideWidthAtrMult > 0.0 && w > InpRangeWideWidthAtrMult * atrSignal)
   {
      return true;
   }
   return false;
}

bool getAtr(const int handle, const ENUM_TIMEFRAMES tf, const int shift, double &outAtr)
{
   double buf[];
   ArraySetAsSeries(buf, true);
   const int need = shift + 1;
   if(CopyBuffer(handle, 0, shift, need, buf) != need)
   {
      return false;
   }
   outAtr = buf[shift];
   return outAtr > 0.0;
}

bool isSwingHighRates(const MqlRates &rates[], const int i, const int left, const int right)
{
   const double h = rates[i].high;
   for(int k = 1; k <= left; k++)
   {
      if(rates[i - k].high >= h)
      {
         return false;
      }
   }
   for(int k = 1; k <= right; k++)
   {
      if(rates[i + k].high > h)
      {
         return false;
      }
   }
   return true;
}

bool isSwingLowRates(const MqlRates &rates[], const int i, const int left, const int right)
{
   const double l = rates[i].low;
   for(int k = 1; k <= left; k++)
   {
      if(rates[i - k].low <= l)
      {
         return false;
      }
   }
   for(int k = 1; k <= right; k++)
   {
      if(rates[i + k].low < l)
      {
         return false;
      }
   }
   return true;
}

void collectSwingsFromRates(MqlRates &rates[], SwingPoint &swingHighs[], SwingPoint &swingLows[])
{
   ArrayResize(swingHighs, 0);
   ArrayResize(swingLows, 0);
   const int total = ArraySize(rates);
   if(total < InpSwingLeft + InpSwingRight + 5)
   {
      return;
   }
   for(int i = InpSwingLeft; i < total - InpSwingRight; i++)
   {
      if(isSwingHighRates(rates, i, InpSwingLeft, InpSwingRight))
      {
         const int n = ArraySize(swingHighs);
         ArrayResize(swingHighs, n + 1);
         swingHighs[n].time = rates[i].time;
         swingHighs[n].price = rates[i].high;
         swingHighs[n].index = i;
      }
      if(isSwingLowRates(rates, i, InpSwingLeft, InpSwingRight))
      {
         const int n = ArraySize(swingLows);
         ArrayResize(swingLows, n + 1);
         swingLows[n].time = rates[i].time;
         swingLows[n].price = rates[i].low;
         swingLows[n].index = i;
      }
   }
}

bool hasHigherHighSequenceNewestFirst(const SwingPoint &highs[], const int countNeeded)
{
   const int n = ArraySize(highs);
   if(n < countNeeded)
   {
      return false;
   }
   for(int i = 0; i < countNeeded - 1; i++)
   {
      if(highs[i].price <= highs[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool hasHigherLowSequenceNewestFirst(const SwingPoint &lows[], const int countNeeded)
{
   const int n = ArraySize(lows);
   if(n < countNeeded)
   {
      return false;
   }
   for(int i = 0; i < countNeeded - 1; i++)
   {
      if(lows[i].price <= lows[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool hasLowerHighSequenceNewestFirst(const SwingPoint &highs[], const int countNeeded)
{
   const int n = ArraySize(highs);
   if(n < countNeeded)
   {
      return false;
   }
   for(int i = 0; i < countNeeded - 1; i++)
   {
      if(highs[i].price >= highs[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool hasLowerLowSequenceNewestFirst(const SwingPoint &lows[], const int countNeeded)
{
   const int n = ArraySize(lows);
   if(n < countNeeded)
   {
      return false;
   }
   for(int i = 0; i < countNeeded - 1; i++)
   {
      if(lows[i].price >= lows[i + 1].price)
      {
         return false;
      }
   }
   return true;
}

bool swingsOverlapBull(const SwingPoint &highs[], const SwingPoint &lows[], const double pip)
{
   const int nh = ArraySize(highs);
   const int nl = ArraySize(lows);
   if(nh < 2 || nl < 2 || pip <= 0.0)
   {
      return true;
   }
   const double penetration = MathMin(highs[0].price, highs[1].price) - MathMax(lows[0].price, lows[1].price);
   if(penetration > 0.0)
   {
      return true;
   }
   return false;
}

bool swingsOverlapBear(const SwingPoint &highs[], const SwingPoint &lows[], const double pip)
{
   const int nh = ArraySize(highs);
   const int nl = ArraySize(lows);
   if(nh < 2 || nl < 2 || pip <= 0.0)
   {
      return true;
   }
   const double penetration = MathMin(highs[0].price, highs[1].price) - MathMax(lows[0].price, lows[1].price);
   if(penetration > 0.0)
   {
      return true;
   }
   return false;
}

ENUM_MARKET_REGIME classifyRegimeOnTf(const ENUM_TIMEFRAMES tf)
{
   MqlRates rates[];
   const int copied = CopyRates(_Symbol, tf, 0, InpStructureLookback, rates);
   if(copied < InpStructureLookback)
   {
      return REGIME_UNKNOWN;
   }
   ArraySetAsSeries(rates, true);
   SwingPoint highs[];
   SwingPoint lows[];
   collectSwingsFromRates(rates, highs, lows);
   const double pip = getPipSize();
   const bool bullStruct = hasHigherHighSequenceNewestFirst(highs, 2) && hasHigherLowSequenceNewestFirst(lows, 2);
   const bool bearStruct = hasLowerLowSequenceNewestFirst(lows, 2) && hasLowerHighSequenceNewestFirst(highs, 2);
   if(bullStruct && !bearStruct)
   {
      if(!swingsOverlapBull(highs, lows, pip))
      {
         return REGIME_BULL_STRONG;
      }
      return REGIME_BULL_WEAK;
   }
   if(bearStruct && !bullStruct)
   {
      if(!swingsOverlapBear(highs, lows, pip))
      {
         return REGIME_BEAR_STRONG;
      }
      return REGIME_BEAR_WEAK;
   }
   if(!bullStruct && !bearStruct)
   {
      return REGIME_RANGE;
   }
   return REGIME_RANGE;
}

bool isRangeWidthCompressed(const double rangeLow, const double rangeHigh, const double atr)
{
   if(atr <= 0.0 || InpRangeMaxWidthAtrMult <= 0.0)
   {
      return false;
   }
   return (rangeHigh - rangeLow) <= InpRangeMaxWidthAtrMult * atr;
}

void getRangeBoxOnSignal(double &outLow, double &outHigh, bool &outValid)
{
   outValid = false;
   outLow = 0.0;
   outHigh = 0.0;
   MqlRates rates[];
   const int n = CopyRates(_Symbol, InpSignalTimeframe, 0, InpRangeBoxBars, rates);
   if(n < InpRangeBoxBars)
   {
      return;
   }
   ArraySetAsSeries(rates, true);
   double mn = rates[0].low;
   double mx = rates[0].high;
   for(int i = 0; i < InpRangeBoxBars; i++)
   {
      if(rates[i].low < mn)
      {
         mn = rates[i].low;
      }
      if(rates[i].high > mx)
      {
         mx = rates[i].high;
      }
   }
   outLow = mn;
   outHigh = mx;
   outValid = (mx > mn);
}

bool isPriceInMiddleOfRange(const double bid, const double rangeLow, const double rangeHigh)
{
   const double width = rangeHigh - rangeLow;
   if(width <= 0.0)
   {
      return true;
   }
   const double pos = (bid - rangeLow) / width;
   return (pos >= InpRangeMiddleMinRatio && pos <= InpRangeMiddleMaxRatio);
}

bool candleHasLongLowerWick(const MqlRates &c)
{
   const double body = MathAbs(c.close - c.open);
   const double lowerWick = MathMin(c.open, c.close) - c.low;
   if(body <= _Point * 0.1)
   {
      return lowerWick >= InpWickToBodyMinRatio * _Point;
   }
   return lowerWick >= InpWickToBodyMinRatio * body;
}

bool candleHasLongUpperWick(const MqlRates &c)
{
   const double body = MathAbs(c.close - c.open);
   const double upperWick = c.high - MathMax(c.open, c.close);
   if(body <= _Point * 0.1)
   {
      return upperWick >= InpWickToBodyMinRatio * _Point;
   }
   return upperWick >= InpWickToBodyMinRatio * body;
}

bool twoCandleBullEngulfBreak(const MqlRates &r0, const MqlRates &r1, const MqlRates &r2, const double atr, const bool isBuy)
{
   if(atr <= 0.0)
   {
      return false;
   }
   if(isBuy)
   {
      const double maxPrev = MathMax(r2.high, r1.high);
      const double minPrev = MathMin(r2.low, r1.low);
      const double body = MathAbs(r0.close - r0.open);
      if(r0.close <= r0.open)
      {
         return false;
      }
      if(r0.close <= maxPrev)
      {
         return false;
      }
      if(r0.open < minPrev)
      {
         return false;
      }
      if(body < InpBreakoutAtrMult * atr)
      {
         return false;
      }
      if(r0.close <= maxPrev + 0.15 * atr)
      {
         return false;
      }
      return true;
   }
   const double minPrev = MathMin(r2.low, r1.low);
   const double maxPrev = MathMax(r2.high, r1.high);
   const double body = MathAbs(r0.close - r0.open);
   if(r0.close >= r0.open)
   {
      return false;
   }
   if(r0.close >= minPrev)
   {
      return false;
   }
   if(r0.open > maxPrev)
   {
      return false;
   }
   if(body < InpBreakoutAtrMult * atr)
   {
      return false;
   }
   if(r0.close >= minPrev - 0.15 * atr)
   {
      return false;
   }
   return true;
}

bool findLastMinorSupportResistance(const bool wantSupport, double &outLevel)
{
   MqlRates rates[];
   const int need = InpStructureLookback;
   if(CopyRates(_Symbol, InpSignalTimeframe, 0, need, rates) != need)
   {
      return false;
   }
   ArraySetAsSeries(rates, true);
   SwingPoint highs[];
   SwingPoint lows[];
   collectSwingsFromRates(rates, highs, lows);
   if(wantSupport)
   {
      const int nl = ArraySize(lows);
      if(nl < 1)
      {
         return false;
      }
      outLevel = lows[0].price;
      return true;
   }
   const int nh = ArraySize(highs);
   if(nh < 1)
   {
      return false;
   }
   outLevel = highs[0].price;
   return true;
}

bool priceTouchesLevel(const double price, const double level, const double atr)
{
   const double tol = MathMax(_Point * 5.0, InpLevelTouchAtrFrac * atr);
   return MathAbs(price - level) <= tol;
}

double computeRiskPercent()
{
   if(InpTradeMode == 0)
   {
      return InpRiskPercentIdeal;
   }
   if(InpTradeMode == 2)
   {
      return 0.5;
   }
   return InpRiskPercentNormal;
}

double normalizeVolume(double lots)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(stepLot <= 0.0)
   {
      stepLot = 0.01;
   }
   lots = MathFloor(lots / stepLot) * stepLot;
   if(lots < minLot)
   {
      lots = minLot;
   }
   if(lots > maxLot)
   {
      lots = maxLot;
   }
   return lots;
}

double calculateLotsByRisk(const double entryPrice, const double slPrice, const double riskPercent, const double atrForSizing)
{
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * (riskPercent / 100.0);
   if(InpMaxRiskMoneyPerTrade > 0.0)
   {
      riskMoney = MathMin(riskMoney, InpMaxRiskMoneyPerTrade);
   }
   if(riskMoney <= 0.0)
   {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   const double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0.0 || tickValue <= 0.0)
   {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   double slDistance = MathAbs(entryPrice - slPrice);
   if(slDistance <= 0.0)
   {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   if(InpMinStopPointsForLotSizing > 0)
   {
      const double minByPoints = (double)InpMinStopPointsForLotSizing * _Point;
      if(slDistance < minByPoints)
      {
         slDistance = minByPoints;
      }
   }
   if(atrForSizing > 0.0 && InpMinStopAtrMultForLotSizing > 0.0)
   {
      const double minByAtr = InpMinStopAtrMultForLotSizing * atrForSizing;
      if(slDistance < minByAtr)
      {
         slDistance = minByAtr;
      }
   }
   const double lossPerLot = (slDistance / tickSize) * tickValue;
   if(lossPerLot <= 0.0)
   {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   double lots = riskMoney / lossPerLot;
   if(InpMaxLotsHardCap > 0.0)
   {
      lots = MathMin(lots, InpMaxLotsHardCap);
   }
   return normalizeVolume(lots);
}

bool isDailyLossGuardTriggered()
{
   if(InpMaxDailyLossPercent <= 0.0 || g_dayStartBalance <= 0.0)
   {
      return false;
   }
   const double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   const double floorBal = g_dayStartBalance * (1.0 - InpMaxDailyLossPercent / 100.0);
   return eq < floorBal;
}

void updateSessionEquityPeak()
{
   const double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq > g_sessionPeakEquity)
   {
      g_sessionPeakEquity = eq;
   }
}

bool isEquityDrawdownFromPeakTooDeep()
{
   if(InpMaxEquityDrawdownFromPeakPercent <= 0.0)
   {
      return false;
   }
   if(g_sessionPeakEquity <= 0.0)
   {
      return false;
   }
   const double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   const double ddPct = 100.0 * (g_sessionPeakEquity - eq) / g_sessionPeakEquity;
   return ddPct > InpMaxEquityDrawdownFromPeakPercent;
}

bool isNewRiskEntryBlocked()
{
   return isDailyLossGuardTriggered() || isEquityDrawdownFromPeakTooDeep();
}

int countOurPositions()
{
   int cnt = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
      {
         continue;
      }
      if(!PositionSelectByTicket(ticket))
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
      cnt++;
   }
   return cnt;
}

void resetDailyTradeCounterIfNeeded()
{
   const datetime t = iTime(_Symbol, InpSignalTimeframe, 0);
   if(t == 0)
   {
      return;
   }
   MqlDateTime dt;
   TimeToStruct(t, dt);
   const int dayId = dt.year * 10000 + dt.mon * 100 + dt.day;
   if(dayId != g_lastTradeDay)
   {
      g_lastTradeDay = dayId;
      g_tradesToday = 0;
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
   if(g_dayStartBalance <= 0.0)
   {
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
}

bool spreadOk()
{
   const long spreadPts = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return spreadPts <= InpMaxSpreadPoints;
}

int OnInit()
{
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(InpSlippagePoints);
   const int fillMode = (int)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((fillMode & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
   {
      g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   }
   else if((fillMode & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
   {
      g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   }
   else
   {
      g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }
   g_atrBiasHandle = iATR(_Symbol, InpBiasTimeframe, InpAtrPeriod);
   g_atrSignalHandle = iATR(_Symbol, InpSignalTimeframe, InpAtrPeriod);
   if(g_atrBiasHandle == INVALID_HANDLE || g_atrSignalHandle == INVALID_HANDLE)
   {
      Print("war.mq5: failed to create ATR handles");
      return INIT_FAILED;
   }
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_sessionPeakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(g_atrBiasHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atrBiasHandle);
   }
   if(g_atrSignalHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atrSignalHandle);
   }
}

bool tryOpenBuy(const double slPrice, const double tpPrice, const string tag, const double atrForLots)
{
   resetDailyTradeCounterIfNeeded();
   if(isNewRiskEntryBlocked())
   {
      return false;
   }
   if(g_tradesToday >= InpMaxTradesPerDay)
   {
      return false;
   }
   if(countOurPositions() >= InpMaxOpenPositions)
   {
      return false;
   }
   const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   const double rp = computeRiskPercent();
   const double lots = calculateLotsByRisk(ask, slPrice, rp, atrForLots);
   const string comment = "war|" + tag;
   if(!g_trade.Buy(lots, _Symbol, ask, slPrice, tpPrice, comment))
   {
      Print("war Buy failed: ", g_trade.ResultRetcodeDescription());
      return false;
   }
   g_tradesToday++;
   return true;
}

bool tryOpenSell(const double slPrice, const double tpPrice, const string tag, const double atrForLots)
{
   resetDailyTradeCounterIfNeeded();
   if(isNewRiskEntryBlocked())
   {
      return false;
   }
   if(g_tradesToday >= InpMaxTradesPerDay)
   {
      return false;
   }
   if(countOurPositions() >= InpMaxOpenPositions)
   {
      return false;
   }
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double rp = computeRiskPercent();
   const double lots = calculateLotsByRisk(bid, slPrice, rp, atrForLots);
   const string comment = "war|" + tag;
   if(!g_trade.Sell(lots, _Symbol, bid, slPrice, tpPrice, comment))
   {
      Print("war Sell failed: ", g_trade.ResultRetcodeDescription());
      return false;
   }
   g_tradesToday++;
   return true;
}

void OnTick()
{
   updateSessionEquityPeak();
   static datetime lastBarTimeSignal = 0;
   if(InpOneTradePerBar && !isNewBar(InpSignalTimeframe, lastBarTimeSignal))
   {
      return;
   }
   if(!spreadOk())
   {
      return;
   }
   MqlRates r[];
   const int needRates = 6;
   if(CopyRates(_Symbol, InpSignalTimeframe, 0, needRates, r) != needRates)
   {
      return;
   }
   ArraySetAsSeries(r, true);
   double atrSignal = 0.0;
   if(!getAtr(g_atrSignalHandle, InpSignalTimeframe, 1, atrSignal))
   {
      return;
   }
   const ENUM_MARKET_REGIME biasRegime = classifyRegimeOnTf(InpBiasTimeframe);
   const ENUM_MARKET_REGIME signalRegime = classifyRegimeOnTf(InpSignalTimeframe);
   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double rangeLow = 0.0;
   double rangeHigh = 0.0;
   bool rangeValid = false;
   getRangeBoxOnSignal(rangeLow, rangeHigh, rangeValid);
   const bool inMiddle = rangeValid && isPriceInMiddleOfRange(bid, rangeLow, rangeHigh);
   if(inMiddle)
   {
      return;
   }
   double levelBuy = 0.0;
   double levelSell = 0.0;
   const bool hasSupport = findLastMinorSupportResistance(true, levelBuy);
   const bool hasResistance = findLastMinorSupportResistance(false, levelSell);
   const double widthPips = rangeValid ? priceToPips(rangeHigh - rangeLow) : 0.0;
   double tpBuy = 0.0;
   double tpSell = 0.0;
   const double rangeMid = rangeValid ? 0.5 * (rangeLow + rangeHigh) : 0.0;
   const bool wideRangeForTp = rangeValid && isWideRangeBox(rangeLow, rangeHigh, atrSignal, widthPips);
   if(rangeValid)
   {
      if(wideRangeForTp)
      {
         tpBuy = rangeMid;
         tpSell = rangeMid;
      }
      else
      {
         tpBuy = rangeHigh;
         tpSell = rangeLow;
      }
   }
   const bool regimeSaysRange = (signalRegime == REGIME_RANGE || biasRegime == REGIME_RANGE);
   const bool compressedRange = rangeValid && isRangeWidthCompressed(rangeLow, rangeHigh, atrSignal);
   bool allowRangeLeg = false;
   if(InpRangeRequireBothTfRange)
   {
      allowRangeLeg = rangeValid && (signalRegime == REGIME_RANGE && biasRegime == REGIME_RANGE);
   }
   else
   {
      allowRangeLeg = rangeValid && (regimeSaysRange || compressedRange);
   }
   const bool allowBuyInTrend = (!InpBlockCounterInStrongTrend) ||
      (biasRegime != REGIME_BEAR_STRONG && signalRegime != REGIME_BEAR_STRONG);
   const bool allowSellInTrend = (!InpBlockCounterInStrongTrend) ||
      (biasRegime != REGIME_BULL_STRONG && signalRegime != REGIME_BULL_STRONG);
   if(allowRangeLeg)
   {
      const double rw = rangeHigh - rangeLow;
      const double pos = (rw > 0.0) ? (bid - rangeLow) / rw : 0.5;
      const bool touchBuyOk = !InpRangeRequireMinorTouch ||
         (hasSupport && priceTouchesLevel(r[1].low, levelBuy, atrSignal));
      const bool touchSellOk = !InpRangeRequireMinorTouch ||
         (hasResistance && priceTouchesLevel(r[1].high, levelSell, atrSignal));
      if(pos <= InpRangeMiddleMinRatio)
      {
         if(barsSinceSignalBarTime(g_lastRangeBuyBarTime) >= InpRangeCooldownBars &&
            allowBuyInTrend && candleHasLongLowerWick(r[1]) && touchBuyOk)
         {
            const double slBuf = InpRangeSlBufferAtrMult * atrSignal;
            const double sl = MathMin(MathMin(r[1].low, r[2].low), rangeLow) - MathMax(5.0 * _Point, slBuf);
            const double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            const double riskPx = ask - sl;
            const double rewPx = tpBuy - ask;
            const bool rrOk = (riskPx > 0.0 && rewPx > 0.0 && (rewPx / riskPx) >= InpRangeMinRewardToRisk);
            if(sl < ask && tpBuy > ask && rrOk)
            {
               if(tryOpenBuy(sl, tpBuy, "RANGE_FTB_BUY", atrSignal))
               {
                  g_lastRangeBuyBarTime = r[1].time;
               }
            }
         }
      }
      else if(pos >= InpRangeMiddleMaxRatio)
      {
         if(barsSinceSignalBarTime(g_lastRangeSellBarTime) >= InpRangeCooldownBars &&
            allowSellInTrend && candleHasLongUpperWick(r[1]) && touchSellOk)
         {
            const double slBuf = InpRangeSlBufferAtrMult * atrSignal;
            const double sl = MathMax(r[1].high, r[2].high) + MathMax(5.0 * _Point, slBuf);
            const double bidSell = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            const double riskPx = sl - bidSell;
            const double rewPx = bidSell - tpSell;
            const bool rrOk = (riskPx > 0.0 && rewPx > 0.0 && (rewPx / riskPx) >= InpRangeMinRewardToRisk);
            if(sl > bidSell && tpSell < bidSell && rrOk)
            {
               if(tryOpenSell(sl, tpSell, "RANGE_FTB_SELL", atrSignal))
               {
                  g_lastRangeSellBarTime = r[1].time;
               }
            }
         }
      }
   }
   if(!InpUseMinerStrategy)
   {
      return;
   }
   if(!hasSupport || !hasResistance)
   {
      return;
   }
   const bool minerBuyTrendOk = (!InpMinerRequireTrendAgreement) ||
      (biasRegime == REGIME_BULL_STRONG || biasRegime == REGIME_BULL_WEAK ||
      signalRegime == REGIME_BULL_STRONG || signalRegime == REGIME_BULL_WEAK);
   const bool minerSellTrendOk = (!InpMinerRequireTrendAgreement) ||
      (biasRegime == REGIME_BEAR_STRONG || biasRegime == REGIME_BEAR_WEAK ||
      signalRegime == REGIME_BEAR_STRONG || signalRegime == REGIME_BEAR_WEAK);
   if(twoCandleBullEngulfBreak(r[1], r[2], r[3], atrSignal, true))
   {
      if(!allowBuyInTrend || !minerBuyTrendOk)
      {
         return;
      }
      const double sl = MathMin(r[2].low, r[3].low) - 3.0 * _Point;
      double tp = levelSell;
      if(!rangeValid || tp <= bid)
      {
         tp = bid + MathMax(atrSignal * 2.0, (bid - sl) * 1.5);
      }
      if(sl < bid && tp > bid)
      {
         tryOpenBuy(sl, tp, "MINER_BUY", atrSignal);
      }
   }
   else if(twoCandleBullEngulfBreak(r[1], r[2], r[3], atrSignal, false))
   {
      if(!allowSellInTrend || !minerSellTrendOk)
      {
         return;
      }
      const double sl = MathMax(r[2].high, r[3].high) + 3.0 * _Point;
      double tp = levelBuy;
      if(!rangeValid || tp >= bid)
      {
         tp = bid - MathMax(atrSignal * 2.0, (sl - bid) * 1.5);
      }
      if(sl > bid && tp < bid)
      {
         tryOpenSell(sl, tp, "MINER_SELL", atrSignal);
      }
   }
}
