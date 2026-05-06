
#property strict

#include <Trade\Trade.mqh>

// توضیح فارسی
input int SwingPeriod = 3;     //  توضیح فارسی
input int ArrowGap = 60;       //  توضیح فارسی
input bool ShowOnlyConfirmed = false; //  توضیح فارسی
input int ConfirmationBars = 1; //  توضیح فارسی
input bool UltraFastMode = false; //  توضیح فارسی
input int MinPriceMove = 0;    //  توضیح فارسی
input bool ShowTrendLines = true;  //  توضیح فارسی
input bool ShowBreakoutAlerts = true; //  توضیح فارسی
input bool ShowFibonacci = false;     //  توضیح فارسی
input int MaxTrendLines = 3;          //  توضیح فارسی
input int MaxFibLevels = 2;           //  توضیح فارسی
input color TrendLineColor = clrGray; //  توضیح فارسی
input int TrendLineWidth = 1;         //  توضیح فارسی
input bool SendAlerts = false;        //  توضیح فارسی
input int MaxBarsToCalculate = 500;   //  توضیح فارسی
input bool OptimizeDrawing = true;    //  توضیح فارسی
input bool ShowPrevHighLow = true;    //  توضیح فارسی
input color PrevHighColor = clrRed;   //  توضیح فارسی
input color PrevLowColor = clrBlue;   //  توضیح فارسی
input int PrevLineWidth = 1;          //  توضیح فارسی
input ENUM_LINE_STYLE PrevLineStyle = STYLE_DASH; //  توضیح فارسی
input bool ShowHighTopLine = true;    //  توضیح فارسی
input bool ShowLowBottomLine = true;  //  توضیح فارسی
input color HighTopColor = clrOrange; //  توضیح فارسی
input color LowBottomColor = clrLime; //  توضیح فارسی
input int TopBottomLineWidth = 2;     //  توضیح فارسی
input ENUM_LINE_STYLE TopBottomLineStyle = STYLE_SOLID; //  توضیح فارسی
//  توضیح فارسی
input bool ShowSwingRelationLabels = true;  //  توضیح فارسی
input color HigherHighColor = clrLime;       //  توضیح فارسی
input color LowerHighColor = clrRed;         //  توضیح فارسی
input color HigherLowColor = clrGreen;       //  توضیح فارسی
input color LowerLowColor = clrMaroon;       //  توضیح فارسی
input int LabelFontSize = 8;                 //  توضیح فارسی
input string LabelFont = "Arial";            //  توضیح فارسی
//  توضیح فارسی
input bool ShowTrendAnalysis = true;         //  توضیح فارسی
input int TrendAnalysisPeriod = 4;           //  توضیح فارسی
input color UpTrendColor = clrLime;          //  توضیح فارسی
input color DownTrendColor = clrRed;         //  توضیح فارسی
input color RangeColor = clrYellow;          //  توضیح فارسی
input int TrendLabelFontSize = 12;           //  توضیح فارسی

// تنظیمات معامله‌گری متاتریدر ۵
input bool EnableTrading = true;              // فعال بودن منطق معامله
input double TradeLotSize = 0.01;             // حجم ثابت ورود
input int TradeTakeProfitPips = 100;          // حد سود (پیپ)
input int TradeStopLossPips = 90;             // حد ضرر پایه (پیپ)
input bool UseAdaptiveStopLoss = true;        // استفاده از حد ضرر تطبیقی با ATR
input double StopLossAtrMultiplier = 1.1;     // ضریب ATR برای حد ضرر تطبیقی
input int MaxSimultaneousTrades = 4;          // حداکثر معاملات همزمان
input int MaxTradesPerSide = 2;               // حداکثر معامله هم‌جهت همزمان
input int RangeTouchBufferPips = 12;          // بافر مجاز برخورد به سقف/کف رنج
input bool UseSwingLevelForEntry = true;      // ورود بر اساس آخرین سقف/کف سوئینگ
input int SwingTouchBufferPips = 6;           // بافر برخورد به سطح سوئینگ
input int SwingSignalMaxAgeBars = 12;         // حداکثر عمر سیگنال HH/LL برای ورود
input bool EnableSideReentry = true;          // فعال‌سازی ری‌اینتر سمت بسته‌شده
input int ReentryCooldownBars = 0;            // فاصله ری‌اینتر بر حسب کندل
input bool EnableAdaptiveReentryCooldown = true; // کول‌داون هوشمند بر اساس ATR
input int ReentryAtrPeriod = 14;              // دوره ATR برای کول‌داون
input int ReentryCooldownMinBars = 0;         // حداقل کول‌داون در بازار کم‌نوسان
input int ReentryCooldownMaxBars = 3;         // حداکثر کول‌داون در بازار پرنوسان
input double ReentryAtrLowPips = 15.0;        // آستانه ATR کم (پیپ)
input double ReentryAtrHighPips = 60.0;       // آستانه ATR زیاد (پیپ)
input bool EnableSpreadFilter = true;         // فعال‌سازی فیلتر اسپرد
input double MaxAllowedSpreadPips = 45.0;      // حداکثر اسپرد مجاز (پیپ)
input double PipSizeOverride = 0.0;           // اگر >0 باشد همین مقدار به‌عنوان pip استفاده می‌شود
input bool MarkClosedDealsOnChart = true;     // نمایش نتیجه بستن معامله روی چارت
input bool EnableCircuitBreaker = true;       // فعال‌سازی مدارشکن باخت‌های متوالی
input int CircuitBreakerConsecutiveSL = 2;    // تعداد SL متوالی برای فعال‌سازی
input int CircuitBreakerLockBars = 30;        // تعداد کندل توقف ورود پس از فعال‌سازی
input bool EnableRangeValidityFilter = true;  // فعال‌سازی اعتبارسنجی رنج
input double RangeWidthAtrMin = 1.0;          // حداقل عرض رنج نسبت به ATR
input double RangeWidthAtrMax = 5.0;          // حداکثر عرض رنج نسبت به ATR
input bool EnableMomentumBlock = true;        // فعال‌سازی بلاک در مومنتوم بالا
input int MomentumLookbackBars = 3;           // تعداد کندل برای سنجش مومنتوم
input double MomentumAtrThreshold = 0.9;      // آستانه مومنتوم بر حسب ATR
input bool EnableRecoveryMode = true;         // فعال‌سازی متد ریکاوری
input int RecoveryTriggerLossPips = 30;       // آستانه ضرر برای فعال شدن ریکاوری (پیپ)
input double RecoveryNetCloseUsd = 0.0;       // حداقل سود خالص برای بستن جفت ریکاوری
input bool EnableProfitLock = true;           // فعال‌سازی قفل سود
input int ProfitLockTriggerPips = 10;         // آستانه فعال‌سازی قفل سود (پیپ)
input int ProfitLockLevelPips = 10;           // سطح استاپ جدید پس از قفل سود (پیپ)
input ulong TradeMagicNumber = 2026050601;    // مجیک نامبر

// توضیح فارسی
double SwingHighBuffer[];
double SwingLowBuffer[];

CTrade trade;
datetime lastBuyTradeBarTime = 0;
datetime lastSellTradeBarTime = 0;
int reentryAtrHandle = INVALID_HANDLE;
int g_prevCalculated = 0;
int g_consecutiveSlCount = 0;
int g_circuitBreakerBarsLeft = 0;
datetime g_lastTickBarTime = 0;
ulong g_recoveryPrimaryTickets[];
ulong g_recoveryHedgeTickets[];

// توضیح فارسی
int lastSwingType = 0;    //  توضیح فارسی
int lastSwingIndex = -1;  //  توضیح فارسی
double lastSwingPrice = 0; //  توضیح فارسی
int secondLastSwingIndex = -1; //  توضیح فارسی
double secondLastSwingPrice = 0; //  توضیح فارسی
//  توضیح فارسی
int lastHighIndex = -1;   //  توضیح فارسی
double lastHighPrice = 0; //  توضیح فارسی
int lastLowIndex = -1;    //  توضیح فارسی
double lastLowPrice = 0;  //  توضیح فارسی
string trendLineName = "SwingTrendLine";
string fibLevelName = "SwingFibLevel";
int trendLineCounter = 0;  //  توضیح فارسی
int fibLevelCounter = 0;   //  توضیح فارسی
string lastCreatedTrendLine = ""; //  توضیح فارسی
string lastCreatedFibLevel = "";  //  توضیح فارسی
double effectiveArrowGap = 0;     //  توضیح فارسی
double effectiveMinPriceMove = 0; //  توضیح فارسی
bool newSwingPointFound = false;  //  توضیح فارسی
//  توضیح فارسی
double prevHighPrice = 0;         //  توضیح فارسی
double prevLowPrice = 0;          //  توضیح فارسی
int highPointsFound = 0;          //  توضیح فارسی
int lowPointsFound = 0;           //  توضیح فارسی
double recentHighs[2];            //  توضیح فارسی
double recentLows[2];             //  توضیح فارسی
string prevHighLineName = "PrevHighLine"; //  توضیح فارسی
string prevLowLineName = "PrevLowLine";   //  توضیح فارسی
//  توضیح فارسی
double allRecentHighs[4];         //  توضیح فارسی
double allRecentLows[4];          //  توضیح فارسی
int allRecentHighsIndices[4];     //  توضیح فارسی
int allRecentLowsIndices[4];      //  توضیح فارسی
int totalHighsFound = 0;          //  توضیح فارسی
int totalLowsFound = 0;           //  توضیح فارسی
string highTopLineName = "HighTopLine";   //  توضیح فارسی
string lowBottomLineName = "LowBottomLine"; //  توضیح فارسی

//  توضیح فارسی
struct SwingPointData
  {
   double price;         //  توضیح فارسی
   int index;           //  توضیح فارسی
   datetime time;       //  توضیح فارسی
   string relation;     //  توضیح فارسی
  };

SwingPointData lastHighPoint;      //  توضیح فارسی
SwingPointData lastLowPoint;       //  توضیح فارسی
SwingPointData secondLastHighPoint; //  توضیح فارسی
SwingPointData secondLastLowPoint;  //  توضیح فارسی
string relationLabelPrefix = "SwingRelation_"; //  توضیح فارسی
int labelCounter = 0;              //  توضیح فارسی

//  توضیح فارسی
enum TREND_STATE
  {
   TREND_UP,      //  توضیح فارسی
   TREND_DOWN,    //  توضیح فارسی
   TREND_RANGE    //  توضیح فارسی
  };

TREND_STATE currentTrend = TREND_RANGE;  //  توضیح فارسی
string trendLabelName = "TrendAnalysis"; //  توضیح فارسی
SwingPointData swingHistory[8];          //  توضیح فارسی
int swingHistoryCount = 0;               //  توضیح فارسی

double GetPipSize()
  {
   if(PipSizeOverride > 0.0)
      return PipSizeOverride;
   if(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "GOLD") >= 0)
      return _Point * 10.0;
   if(_Digits == 3 || _Digits == 5)
      return _Point * 10.0;
   return _Point;
  }

double NormalizeTradeLot(const double requestedLot)
  {
   double lot = requestedLot;
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(stepLot > 0.0)
      lot = MathFloor(lot / stepLot) * stepLot;
   if(lot < minLot)
      lot = minLot;
   if(lot > maxLot)
      lot = maxLot;
   return lot;
  }

int CountMyOpenPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      count++;
     }
   return count;
  }

bool HasOpenPositionType(const ENUM_POSITION_TYPE positionType)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == positionType)
         return true;
     }
   return false;
  }

int CountMyOpenPositionsByType(const ENUM_POSITION_TYPE positionType)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == positionType)
         count++;
     }
   return count;
  }

int BarsSinceTradeBar(const datetime barTime, const datetime &time[])
  {
   if(barTime <= 0)
      return 999999;
   int shift = iBarShift(_Symbol, _Period, barTime, false);
   if(shift < 0)
      return 999999;
   return shift;
  }

int GetAdaptiveReentryCooldownBars()
  {
   if(!EnableAdaptiveReentryCooldown)
      return ReentryCooldownBars;
   if(reentryAtrHandle == INVALID_HANDLE)
      return ReentryCooldownBars;
   if(ReentryCooldownMaxBars < ReentryCooldownMinBars)
      return ReentryCooldownBars;
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   if(CopyBuffer(reentryAtrHandle, 0, 0, 1, atrBuffer) != 1)
      return ReentryCooldownBars;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return ReentryCooldownBars;
   double atrPips = atrBuffer[0] / pip;
   if(atrPips <= ReentryAtrLowPips)
      return ReentryCooldownMinBars;
   if(atrPips >= ReentryAtrHighPips)
      return ReentryCooldownMaxBars;
   double ratio = (atrPips - ReentryAtrLowPips) / (ReentryAtrHighPips - ReentryAtrLowPips);
   int adaptiveBars = (int)MathRound(ReentryCooldownMinBars + ratio * (ReentryCooldownMaxBars - ReentryCooldownMinBars));
   if(adaptiveBars < ReentryCooldownMinBars)
      adaptiveBars = ReentryCooldownMinBars;
   if(adaptiveBars > ReentryCooldownMaxBars)
      adaptiveBars = ReentryCooldownMaxBars;
   return adaptiveBars;
  }

double GetCurrentAtrPips()
  {
   if(reentryAtrHandle == INVALID_HANDLE)
      return 0.0;
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   if(CopyBuffer(reentryAtrHandle, 0, 0, 1, atrBuffer) != 1)
      return 0.0;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return 0.0;
   return atrBuffer[0] / pip;
  }

void UpdateCircuitBreakerOnNewBar()
  {
   datetime barTime = iTime(_Symbol, _Period, 0);
   if(barTime == 0)
      return;
   if(barTime == g_lastTickBarTime)
      return;
   g_lastTickBarTime = barTime;
   if(g_circuitBreakerBarsLeft > 0)
      g_circuitBreakerBarsLeft--;
  }

bool IsRangeValidForTrading(const double rangeLow, const double rangeHigh, const double atrPips)
  {
   if(!EnableRangeValidityFilter)
      return true;
   if(rangeHigh <= rangeLow || atrPips <= 0.0)
      return false;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return false;
   double rangeWidthPips = (rangeHigh - rangeLow) / pip;
   double widthAtrRatio = rangeWidthPips / atrPips;
   if(widthAtrRatio < RangeWidthAtrMin || widthAtrRatio > RangeWidthAtrMax)
      return false;
   return true;
  }

bool IsMomentumTooHigh(const double atrPips)
  {
   if(!EnableMomentumBlock)
      return false;
   if(atrPips <= 0.0)
      return false;
   int lookback = MathMax(1, MomentumLookbackBars);
   double closeNow = iClose(_Symbol, _Period, 0);
   double closePast = iClose(_Symbol, _Period, lookback);
   if(closeNow <= 0.0 || closePast <= 0.0)
      return false;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return false;
   double momentumPips = MathAbs(closeNow - closePast) / pip;
   double momentumAtrRatio = momentumPips / atrPips;
   return (momentumAtrRatio >= MomentumAtrThreshold);
  }

int FindRecoveryByPrimary(const ulong primaryTicket)
  {
   int n = ArraySize(g_recoveryPrimaryTickets);
   for(int i = 0; i < n; i++)
     {
      if(g_recoveryPrimaryTickets[i] == primaryTicket)
         return i;
     }
   return -1;
  }

int FindRecoveryByHedge(const ulong hedgeTicket)
  {
   int n = ArraySize(g_recoveryHedgeTickets);
   for(int i = 0; i < n; i++)
     {
      if(g_recoveryHedgeTickets[i] == hedgeTicket)
         return i;
     }
   return -1;
  }

void AddRecoveryPair(const ulong primaryTicket, const ulong hedgeTicket)
  {
   int n = ArraySize(g_recoveryPrimaryTickets);
   ArrayResize(g_recoveryPrimaryTickets, n + 1);
   ArrayResize(g_recoveryHedgeTickets, n + 1);
   g_recoveryPrimaryTickets[n] = primaryTicket;
   g_recoveryHedgeTickets[n] = hedgeTicket;
  }

void RemoveRecoveryAt(const int idx)
  {
   int n = ArraySize(g_recoveryPrimaryTickets);
   if(idx < 0 || idx >= n)
      return;
   int last = n - 1;
   if(idx != last)
     {
      g_recoveryPrimaryTickets[idx] = g_recoveryPrimaryTickets[last];
      g_recoveryHedgeTickets[idx] = g_recoveryHedgeTickets[last];
     }
   ArrayResize(g_recoveryPrimaryTickets, last);
   ArrayResize(g_recoveryHedgeTickets, last);
  }

void CleanupRecoveryPairs()
  {
   for(int i = ArraySize(g_recoveryPrimaryTickets) - 1; i >= 0; i--)
     {
      bool hasPrimary = PositionSelectByTicket(g_recoveryPrimaryTickets[i]);
      bool hasHedge = PositionSelectByTicket(g_recoveryHedgeTickets[i]);
      if(!hasPrimary || !hasHedge)
         RemoveRecoveryAt(i);
     }
  }

void ManageRecoveryPairsClose()
  {
   if(!EnableRecoveryMode)
      return;
   CleanupRecoveryPairs();
   for(int i = ArraySize(g_recoveryPrimaryTickets) - 1; i >= 0; i--)
     {
      ulong primaryTicket = g_recoveryPrimaryTickets[i];
      ulong hedgeTicket = g_recoveryHedgeTickets[i];
      if(!PositionSelectByTicket(primaryTicket))
        {
         RemoveRecoveryAt(i);
         continue;
        }
      double primaryProfit = PositionGetDouble(POSITION_PROFIT);
      if(!PositionSelectByTicket(hedgeTicket))
        {
         RemoveRecoveryAt(i);
         continue;
        }
      double hedgeProfit = PositionGetDouble(POSITION_PROFIT);
      double netProfit = primaryProfit + hedgeProfit;
      if(netProfit >= RecoveryNetCloseUsd)
        {
         trade.PositionClose(primaryTicket);
         trade.PositionClose(hedgeTicket);
         RemoveRecoveryAt(i);
        }
     }
  }

ulong FindLatestUnpairedRecoveryHedgeTicket(const ENUM_POSITION_TYPE expectedType)
  {
   ulong latestTicket = 0;
   long latestTimeMs = -1;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != expectedType)
         continue;
      if(FindRecoveryByHedge(ticket) >= 0)
         continue;
      string comment = PositionGetString(POSITION_COMMENT);
      if(StringFind(comment, "RecoveryHedge") < 0)
         continue;
      long positionTimeMs = (long)PositionGetInteger(POSITION_TIME_MSC);
      if(positionTimeMs > latestTimeMs)
        {
         latestTimeMs = positionTimeMs;
         latestTicket = ticket;
        }
     }
   return latestTicket;
  }

void TryOpenRecoveryHedge()
  {
   if(!EnableRecoveryMode)
      return;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      if(FindRecoveryByPrimary(ticket) >= 0 || FindRecoveryByHedge(ticket) >= 0)
         continue;
      string comment = PositionGetString(POSITION_COMMENT);
      if(StringFind(comment, "RecoveryHedge") >= 0)
         continue;
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double vol = PositionGetDouble(POSITION_VOLUME);
      double lossPips = 0.0;
      if(type == POSITION_TYPE_BUY)
        {
         lossPips = (openPrice - bid) / pip;
        }
      else if(type == POSITION_TYPE_SELL)
        {
         lossPips = (ask - openPrice) / pip;
        }
      else
        {
         continue;
        }
      if(lossPips < RecoveryTriggerLossPips)
         continue;
      bool opened = false;
      ENUM_POSITION_TYPE hedgeType = POSITION_TYPE_BUY;
      if(type == POSITION_TYPE_BUY)
        {
         hedgeType = POSITION_TYPE_SELL;
         opened = trade.Sell(vol, _Symbol, bid, 0.0, 0.0, "RecoveryHedge_Sell");
        }
      else
        {
         hedgeType = POSITION_TYPE_BUY;
         opened = trade.Buy(vol, _Symbol, ask, 0.0, 0.0, "RecoveryHedge_Buy");
        }
      if(opened)
        {
         ulong hedgeTicket = FindLatestUnpairedRecoveryHedgeTicket(hedgeType);
         if(hedgeTicket != 0)
            AddRecoveryPair(ticket, hedgeTicket);
        }
     }
  }

void ManageProfitLockStops()
  {
   if(!EnableProfitLock)
      return;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return;
   double triggerDistance = ProfitLockTriggerPips * pip;
   double lockDistance = ProfitLockLevelPips * pip;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != TradeMagicNumber)
         continue;
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSl = PositionGetDouble(POSITION_SL);
      double currentTp = PositionGetDouble(POSITION_TP);
      if(type == POSITION_TYPE_BUY)
        {
         if((bid - openPrice) < triggerDistance)
            continue;
         double newSl = openPrice + lockDistance;
         if(currentSl == 0.0 || currentSl < newSl)
            trade.PositionModify(ticket, newSl, currentTp);
        }
      else if(type == POSITION_TYPE_SELL)
        {
         if((openPrice - ask) < triggerDistance)
            continue;
         double newSl = openPrice - lockDistance;
         if(currentSl == 0.0 || currentSl > newSl)
            trade.PositionModify(ticket, newSl, currentTp);
        }
     }
  }

void ExecuteRangeTrading(const datetime &time[])
  {
   if(!EnableTrading)
      return;
   double rangeLow = GetSupportResistance(true);
   double rangeHigh = GetSupportResistance(false);
   if(rangeLow <= 0.0 || rangeHigh <= 0.0 || rangeHigh <= rangeLow)
      return;
   double atrPips = GetCurrentAtrPips();
   ManageRecoveryPairsClose();
   TryOpenRecoveryHedge();
   if(currentTrend != TREND_RANGE)
      return;
   if(EnableCircuitBreaker && g_circuitBreakerBarsLeft > 0)
      return;
   double pip = GetPipSize();
   if(pip <= 0.0)
      return;
   double buffer = RangeTouchBufferPips * pip;
   if(!IsRangeValidForTrading(rangeLow, rangeHigh, atrPips))
      return;
   if(IsMomentumTooHigh(atrPips))
      return;
   double slPips = TradeStopLossPips;
   if(UseAdaptiveStopLoss && atrPips > 0.0)
      slPips = MathMax(slPips, atrPips * StopLossAtrMultiplier);
   double slDistance = slPips * pip;
   double tpDistance = TradeTakeProfitPips * pip;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(EnableSpreadFilter)
     {
      double currentSpreadPips = (ask - bid) / pip;
      if(currentSpreadPips > MaxAllowedSpreadPips)
         return;
     }
   double lot = NormalizeTradeLot(TradeLotSize);
   double entryBuyLevel = rangeLow;
   double entrySellLevel = rangeHigh;
   if(UseSwingLevelForEntry)
     {
      // برای جلوگیری از ورود اشتباه جهت، خرید فقط با آخرین کف معتبر و فروش فقط با آخرین سقف معتبر
      if(lastLowPrice > 0.0)
         entryBuyLevel = lastLowPrice;
      if(lastHighPrice > 0.0)
         entrySellLevel = lastHighPrice;
     }
   // اطمینان از اینکه سطح خرید پایین‌تر از سطح فروش است
   if(entryBuyLevel >= entrySellLevel)
     {
      entryBuyLevel = rangeLow;
      entrySellLevel = rangeHigh;
     }
   double entryBuffer = (UseSwingLevelForEntry ? SwingTouchBufferPips : RangeTouchBufferPips) * pip;
   double rangeMid = 0.5 * (rangeLow + rangeHigh);
   bool isInLowerHalf = (bid <= rangeMid);
   bool isInUpperHalf = (ask >= rangeMid);
   double distToBuyLevel = MathAbs(bid - entryBuyLevel);
   double distToSellLevel = MathAbs(ask - entrySellLevel);
   int openTotal = CountMyOpenPositions();
   int openBuy = CountMyOpenPositionsByType(POSITION_TYPE_BUY);
   int openSell = CountMyOpenPositionsByType(POSITION_TYPE_SELL);
   const int hardMaxTradesPerSide = 1;
   bool canOpenMore = (openTotal < MaxSimultaneousTrades);
   int effectiveReentryCooldownBars = GetAdaptiveReentryCooldownBars();
   bool canReenterBuy = (!EnableSideReentry) ? false : (BarsSinceTradeBar(lastBuyTradeBarTime, time) >= effectiveReentryCooldownBars);
   bool canReenterSell = (!EnableSideReentry) ? false : (BarsSinceTradeBar(lastSellTradeBarTime, time) >= effectiveReentryCooldownBars);
   // قانون ساختاری مهم:
   // فقط روی LL خرید و فقط روی HH فروش
   int latestBarIndex = ArraySize(time) - 1;
   int barsFromLastSwing = (lastSwingIndex >= 0 && latestBarIndex >= lastSwingIndex) ? (latestBarIndex - lastSwingIndex) : 999999;
   bool isFreshSwingSignal = (barsFromLastSwing <= SwingSignalMaxAgeBars);
   bool allowBuyBySwingRelation = (lastSwingType == -1 &&
                                   lastLowPoint.relation == "LL" &&
                                   lastLowPoint.index == lastSwingIndex &&
                                   isFreshSwingSignal);
   bool allowSellBySwingRelation = (lastSwingType == 1 &&
                                    lastHighPoint.relation == "HH" &&
                                    lastHighPoint.index == lastSwingIndex &&
                                    isFreshSwingSignal);
   if(isInLowerHalf && distToBuyLevel <= entryBuffer && distToBuyLevel <= distToSellLevel && allowBuyBySwingRelation)
     {
      if(canOpenMore && openBuy < hardMaxTradesPerSide && (lastBuyTradeBarTime == 0 || canReenterBuy))
        {
         double sl = ask - slDistance;
         double tp = ask + tpDistance;
         if(trade.Buy(lot, _Symbol, ask, sl, tp, "SwingRange_Buy"))
           {
            lastBuyTradeBarTime = time[0];
            openTotal++;
            canOpenMore = (openTotal < MaxSimultaneousTrades);
           }
        }
     }
   if(isInUpperHalf && distToSellLevel <= entryBuffer && distToSellLevel <= distToBuyLevel && allowSellBySwingRelation)
     {
      if(canOpenMore && openSell < hardMaxTradesPerSide && (lastSellTradeBarTime == 0 || canReenterSell))
        {
         double sl = bid + slDistance;
         double tp = bid - tpDistance;
         if(trade.Sell(lot, _Symbol, bid, sl, tp, "SwingRange_Sell"))
            lastSellTradeBarTime = time[0];
        }
     }
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(!MarkClosedDealsOnChart)
      return;
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;
   ulong dealTicket = trans.deal;
   if(dealTicket == 0 || !HistoryDealSelect(dealTicket))
      return;
   if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != _Symbol)
      return;
   if((ulong)HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != TradeMagicNumber)
      return;
   ENUM_DEAL_ENTRY entryType = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
   if(entryType != DEAL_ENTRY_OUT && entryType != DEAL_ENTRY_OUT_BY)
      return;
   double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
   ENUM_DEAL_REASON reason = (ENUM_DEAL_REASON)HistoryDealGetInteger(dealTicket, DEAL_REASON);
   if(EnableCircuitBreaker)
     {
      bool isStopLossDeal = (reason == DEAL_REASON_SL) || (dealProfit < 0.0);
      if(isStopLossDeal)
        {
         g_consecutiveSlCount++;
         if(g_consecutiveSlCount >= CircuitBreakerConsecutiveSL)
           {
            g_circuitBreakerBarsLeft = CircuitBreakerLockBars;
            g_consecutiveSlCount = 0;
           }
        }
      else if(dealProfit > 0.0)
        {
         g_consecutiveSlCount = 0;
        }
     }
   datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
   double dealPrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
   string objName = "DealMark_" + IntegerToString((int)dealTicket);
   string txt = ((dealProfit >= 0.0) ? "+" : "") + DoubleToString(dealProfit, 2) + "$";
   color txtColor = (dealProfit >= 0.0) ? clrLime : clrRed;
   double y = dealPrice - 20.0 * _Point;
   if(ObjectFind(0, objName) >= 0)
      ObjectDelete(0, objName);
   if(ObjectCreate(0, objName, OBJ_TEXT, 0, dealTime, y))
     {
      ObjectSetString(0, objName, OBJPROP_TEXT, txt);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, txtColor);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber((long)TradeMagicNumber);
   trade.SetDeviationInPoints(20);
   reentryAtrHandle = iATR(_Symbol, _Period, ReentryAtrPeriod);
   
   //  توضیح فارسی
   CalculateEffectiveValues();
   
   //  توضیح فارسی
   InitializeSwingPointData(lastHighPoint);
   InitializeSwingPointData(lastLowPoint);
   InitializeSwingPointData(secondLastHighPoint);
   InitializeSwingPointData(secondLastLowPoint);
   labelCounter = 0;
   
   //  توضیح فارسی
   currentTrend = TREND_RANGE;
   swingHistoryCount = 0;
   for(int i = 0; i < 8; i++)
     {
      InitializeSwingPointData(swingHistory[i]);
     }
   
   //  توضیح فارسی
   if(!ShowOnlyConfirmed || UltraFastMode)
     {
      EventSetTimer(1); //  توضیح فارسی
     }
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CalculateEffectiveValues()
  {
   //  توضیح فارسی
   string symbol = _Symbol;
   double point = _Point;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   //  توضیح فارسی
   Print("品种: ", symbol, ", 小数位数: ", digits, ", Point: ", point);
   Print("最大计算K线数: ", MaxBarsToCalculate);
   
   //  توضیح فارسی
   if(StringFind(symbol, "XAU") >= 0 || StringFind(symbol, "GOLD") >= 0) //  توضیح فارسی
     {
      //  توضیح فارسی
      effectiveArrowGap = ArrowGap * 0.01; //  توضیح فارسی
      effectiveMinPriceMove = (MinPriceMove > 0) ? MinPriceMove * 0.01 : 0;
      Print("检测到黄金品种，调整参数 - ArrowGap: ", effectiveArrowGap, ", MinPriceMove: ", effectiveMinPriceMove);
     }
   else if(StringFind(symbol, "JPY") >= 0) //  توضیح فارسی
     {
      //  توضیح فارسی
      effectiveArrowGap = ArrowGap * 0.1; //  توضیح فارسی
      effectiveMinPriceMove = (MinPriceMove > 0) ? MinPriceMove * 0.1 : 0;
      Print("检测到日元品种，调整参数 - ArrowGap: ", effectiveArrowGap, ", MinPriceMove: ", effectiveMinPriceMove);
     }
   else //  توضیح فارسی
     {
      //  توضیح فارسی
      effectiveArrowGap = ArrowGap * point;
      effectiveMinPriceMove = (MinPriceMove > 0) ? MinPriceMove * point : 0;
      Print("标准货币对，使用原始参数 - ArrowGap: ", effectiveArrowGap, ", MinPriceMove: ", effectiveMinPriceMove);
     }
  }
//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reentryAtrHandle != INVALID_HANDLE)
     {
      IndicatorRelease(reentryAtrHandle);
      reentryAtrHandle = INVALID_HANDLE;
     }
   //  توضیح فارسی
   EventKillTimer();
   
   //  توضیح فارسی
   CleanupOldObjects();
   
   //  توضیح فارسی
   switch(reason)
     {
      case REASON_REMOVE:
         Print("指标被手动移除，清理所有对象");
         break;
      case REASON_RECOMPILE:
         Print("指标重新编译，清理所有对象");
         break;
      case REASON_CHARTCHANGE:
         Print("图表切换，清理所有对象");
         break;
      case REASON_PARAMETERS:
         Print("参数修改，重新计算有效值");
         //  توضیح فارسی
         CalculateEffectiveValues();
         break;
      default:
         Print("指标卸载，清理所有对象");
         break;
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void OnTimer()
  {
   //  توضیح فارسی
   if(!ShowOnlyConfirmed || UltraFastMode)
     {
      ChartRedraw(0);
     }
  }

void OnTick()
  {
   ManageProfitLockStops();
   UpdateCircuitBreakerOnNewBar();
   static datetime lastProcessedBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == 0)
      return;
   if(currentBarTime == lastProcessedBarTime)
      return;
   lastProcessedBarTime = currentBarTime;

   int rates_total = Bars(_Symbol, _Period);
   if(rates_total <= SwingPeriod * 2 + 2)
      return;
   MqlRates rates[];
   if(CopyRates(_Symbol, _Period, 0, rates_total, rates) != rates_total)
      return;
   ArraySetAsSeries(rates, false);
   datetime time[];
   double open[];
   double high[];
   double low[];
   double close[];
   long tick_volume[];
   long volume[];
   int spread[];
   ArrayResize(time, rates_total);
   ArrayResize(open, rates_total);
   ArrayResize(high, rates_total);
   ArrayResize(low, rates_total);
   ArrayResize(close, rates_total);
   ArrayResize(tick_volume, rates_total);
   ArrayResize(volume, rates_total);
   ArrayResize(spread, rates_total);
   ArraySetAsSeries(time, false);
   ArraySetAsSeries(open, false);
   ArraySetAsSeries(high, false);
   ArraySetAsSeries(low, false);
   ArraySetAsSeries(close, false);
   ArraySetAsSeries(tick_volume, false);
   ArraySetAsSeries(volume, false);
   ArraySetAsSeries(spread, false);
   for(int i = 0; i < rates_total; i++)
     {
      time[i] = rates[i].time;
      open[i] = rates[i].open;
      high[i] = rates[i].high;
      low[i] = rates[i].low;
      close[i] = rates[i].close;
      tick_volume[i] = rates[i].tick_volume;
      volume[i] = rates[i].real_volume;
      spread[i] = (int)rates[i].spread;
     }
   g_prevCalculated = ProcessSwingLogic(rates_total, g_prevCalculated, time, open, high, low, close, tick_volume, volume, spread);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
int ProcessSwingLogic(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   // در حالت EA باید سایز بافرها را دستی مدیریت کنیم (برخلاف اندیکاتور)
   if(ArraySize(SwingHighBuffer) != rates_total)
     {
      ArrayResize(SwingHighBuffer, rates_total);
      ArraySetAsSeries(SwingHighBuffer, false);
     }
   if(ArraySize(SwingLowBuffer) != rates_total)
     {
      ArrayResize(SwingLowBuffer, rates_total);
      ArraySetAsSeries(SwingLowBuffer, false);
     }

   if(rates_total < SwingPeriod*2+1)
      return(0);

   //  توضیح فارسی
   int effectiveStart;
   int limit;
   
   if(prev_calculated == 0)
     {
      //  توضیح فارسی
      int maxStart = MathMax(0, rates_total - MaxBarsToCalculate);
      effectiveStart = MathMax(maxStart, SwingPeriod * 2);
      //  توضیح فارسی
      if(UltraFastMode)
         limit = rates_total; //  توضیح فارسی
      else
         limit = rates_total - 1; //  توضیح فارسی
      
      //  توضیح فارسی
      for(int i = effectiveStart; i < rates_total; i++)
        {
         SwingHighBuffer[i] = EMPTY_VALUE;
         SwingLowBuffer[i] = EMPTY_VALUE;
        }
      
      Print("完全重新计算，范围: ", effectiveStart, " 到 ", limit, " (共 ", (limit - effectiveStart), " 根K线)");
     }
   else
     {
      //  توضیح فارسی
      int maxStart = MathMax(0, rates_total - MaxBarsToCalculate);
      effectiveStart = MathMax(maxStart, prev_calculated - 2); //  توضیح فارسی
      //  توضیح فارسی
      if(UltraFastMode)
         limit = rates_total; //  توضیح فارسی
      else
         limit = rates_total - 1; //  توضیح فارسی
      
      //  توضیح فارسی
      for(int i = 0; i < maxStart && i < effectiveStart; i++)
        {
         SwingHighBuffer[i] = EMPTY_VALUE;
         SwingLowBuffer[i] = EMPTY_VALUE;
        }
        
      //  توضیح فارسی
      for(int i = MathMax(0, prev_calculated - 3); i < rates_total; i++)
        {
         if(i >= effectiveStart)
           {
            SwingHighBuffer[i] = EMPTY_VALUE;
            SwingLowBuffer[i] = EMPTY_VALUE;
           }
        }
     }
   
   //  توضیح فارسی
   if(prev_calculated == 0)
     {
      ArrayInitialize(SwingHighBuffer, EMPTY_VALUE);
      ArrayInitialize(SwingLowBuffer, EMPTY_VALUE);
      lastSwingType = 0;
      lastSwingIndex = -1;
      lastSwingPrice = 0;
      secondLastSwingIndex = -1;
      secondLastSwingPrice = 0;
      lastHighIndex = -1;
      lastHighPrice = 0;
      lastLowIndex = -1;
      lastLowPrice = 0;
      trendLineCounter = 0;
      fibLevelCounter = 0;
      lastCreatedTrendLine = "";
      lastCreatedFibLevel = "";
      newSwingPointFound = false;
      //  توضیح فارسی
      prevHighPrice = 0;
      prevLowPrice = 0;
      highPointsFound = 0;
      lowPointsFound = 0;
      ArrayInitialize(recentHighs, 0);
      ArrayInitialize(recentLows, 0);
      //  توضیح فارسی
      totalHighsFound = 0;
      totalLowsFound = 0;
      ArrayInitialize(allRecentHighs, 0);
      ArrayInitialize(allRecentLows, 0);
      ArrayInitialize(allRecentHighsIndices, -1);
      ArrayInitialize(allRecentLowsIndices, -1);
      //  توضیح فارسی
      InitializeSwingPointData(lastHighPoint);
      InitializeSwingPointData(lastLowPoint);
      InitializeSwingPointData(secondLastHighPoint);
      InitializeSwingPointData(secondLastLowPoint);
      labelCounter = 0;
      
      //  توضیح فارسی
      currentTrend = TREND_RANGE;
      swingHistoryCount = 0;
      for(int i = 0; i < 8; i++)
        {
         InitializeSwingPointData(swingHistory[i]);
        }
      
      //  توضیح فارسی
      CalculateEffectiveValues();
      
      //  توضیح فارسی
      CleanupOldObjects();
      
      //  توضیح فارسی
      FindRecentSwingPoints(effectiveStart, rates_total, high, low);
     }
   
   //  توضیح فارسی
   int processedBars = 0;
   datetime startTime = TimeCurrent();
   newSwingPointFound = false; //  توضیح فارسی
   
   for(int i = effectiveStart; i < limit; i++)
     {
      //  توضیح فارسی
      if(i < SwingPeriod * 2)
         continue;
      
      processedBars++;
      
      //  توضیح فارسی
      int checkIndex;
      if(ShowOnlyConfirmed)
        {
         //  توضیح فارسی
         checkIndex = i - ConfirmationBars;
         if(checkIndex < SwingPeriod)
            continue;
        }
      else if(UltraFastMode)
        {
         //  توضیح فارسی
         checkIndex = i;
         if(checkIndex < SwingPeriod)
            continue;
        }
      else
        {
         //  توضیح فارسی
         checkIndex = i - 1;
         if(checkIndex < SwingPeriod)
            continue;
        }
      
      bool isHigh = true;
      bool isLow = true;
      double curHigh = high[checkIndex];
      double curLow = low[checkIndex];

      //  توضیح فارسی
      for(int j = 1; j <= SwingPeriod; j++)
        {
         //  توضیح فارسی
         if(checkIndex - j >= 0)
           {
            if(high[checkIndex - j] >= curHigh)
               isHigh = false;
            if(low[checkIndex - j] <= curLow)
               isLow = false;
           }
            
         //  توضیح فارسی
         if(ShowOnlyConfirmed)
           {
            //  توضیح فارسی
            if(checkIndex + j < rates_total)
              {
               if(high[checkIndex + j] >= curHigh)
                  isHigh = false;
               if(low[checkIndex + j] <= curLow)
                  isLow = false;
              }
           }
         else if(UltraFastMode)
           {
            //  توضیح فارسی
            //  توضیح فارسی
            }
         else
           {
            //  توضیح فارسی
            int rightCheckLimit = MathMin(j, i - checkIndex - 1);
            if(rightCheckLimit > 0 && checkIndex + rightCheckLimit < rates_total)
              {
               if(high[checkIndex + rightCheckLimit] >= curHigh)
                  isHigh = false;
               if(low[checkIndex + rightCheckLimit] <= curLow)
                  isLow = false;
              }
           }
        }

      //  توضیح فارسی
      if(effectiveMinPriceMove > 0)
        {
         if(isHigh)
           {
            double minHighAround = curHigh;
            for(int j = 1; j <= SwingPeriod; j++)
              {
               if(checkIndex - j >= 0 && high[checkIndex - j] < minHighAround) 
                  minHighAround = high[checkIndex - j];
               
               if(ShowOnlyConfirmed)
                 {
                  if(checkIndex + j < rates_total && high[checkIndex + j] < minHighAround) 
                     minHighAround = high[checkIndex + j];
                 }
               else if(UltraFastMode)
                 {
                  //  توضیح فارسی
                  }
               else
                 {
                  int rightCheckLimit = MathMin(j, i - checkIndex - 1);
                  if(rightCheckLimit > 0 && checkIndex + rightCheckLimit < rates_total && 
                     high[checkIndex + rightCheckLimit] < minHighAround)
                     minHighAround = high[checkIndex + rightCheckLimit];
                 }
              }
            if((curHigh - minHighAround) < effectiveMinPriceMove)
               isHigh = false;
           }
         
         if(isLow)
           {
            double maxLowAround = curLow;
            for(int j = 1; j <= SwingPeriod; j++)
              {
               if(checkIndex - j >= 0 && low[checkIndex - j] > maxLowAround) 
                  maxLowAround = low[checkIndex - j];
               
               if(ShowOnlyConfirmed)
                 {
                  if(checkIndex + j < rates_total && low[checkIndex + j] > maxLowAround) 
                     maxLowAround = low[checkIndex + j];
                 }
               else if(UltraFastMode)
                 {
                  //  توضیح فارسی
                  }
               else
                 {
                  int rightCheckLimit = MathMin(j, i - checkIndex - 1);
                  if(rightCheckLimit > 0 && checkIndex + rightCheckLimit < rates_total && 
                     low[checkIndex + rightCheckLimit] > maxLowAround)
                     maxLowAround = low[checkIndex + rightCheckLimit];
                 }
              }
            if((maxLowAround - curLow) < effectiveMinPriceMove)
               isLow = false;
           }
        }

      //  توضیح فارسی
      if(isHigh && isLow)
        {
         //  توضیح فارسی
         if(lastSwingType == 1) //  توضیح فارسی
           {
            isHigh = false;
           }
         else if(lastSwingType == -1) //  توضیح فارسی
           {
            isLow = false;
           }
         else //  توضیح فارسی
           {
            double highStrength = 0;
            double lowStrength = 0;
            
            //  توضیح فارسی
            for(int j = 1; j <= SwingPeriod; j++)
              {
               highStrength += (curHigh - high[checkIndex - j]) + (curHigh - high[checkIndex + j]);
              }
            
            //  توضیح فارسی  
            for(int j = 1; j <= SwingPeriod; j++)
              {
               lowStrength += (low[checkIndex - j] - curLow) + (low[checkIndex + j] - curLow);
              }
            
            if(highStrength > lowStrength)
               isLow = false;
            else
               isHigh = false;
           }
        }
      
      //=================================================================
      //  توضیح فارسی
      //  توضیح فارسی
      //  توضیح فارسی
      //  توضیح فارسی
      //  توضیح فارسی
      //  توضیح فارسی
      //=================================================================
      
      //  توضیح فارسی
      if(isHigh && lastSwingType == 1)
        {
         //  توضیح فارسی
         if(ProcessConsecutiveHighPoints(curHigh, checkIndex))
           {
            //  توضیح فارسی
            //  توضیح فارسی
            if(swingHistoryCount > 0 && swingHistory[0].relation == "H")
              {
               swingHistory[0].price = curHigh;
               swingHistory[0].index = checkIndex;
               swingHistory[0].time = time[checkIndex];
               
               if(ShowTrendAnalysis)
                 {
                  AnalyzeTrend();
                  UpdateTrendLabel();
                 }
              }
           }
         else
           {
            //  توضیح فارسی
            isHigh = false;
           }
        }
      
      //  توضیح فارسی
      if(isLow && lastSwingType == -1)
        {
         //  توضیح فارسی
         if(ProcessConsecutiveLowPoints(curLow, checkIndex))
           {
            //  توضیح فارسی
            //  توضیح فارسی
            if(swingHistoryCount > 0 && swingHistory[0].relation == "L")
              {
               swingHistory[0].price = curLow;
               swingHistory[0].index = checkIndex;
               swingHistory[0].time = time[checkIndex];
               
               if(ShowTrendAnalysis)
                 {
                  AnalyzeTrend();
                  UpdateTrendLabel();
                 }
              }
           }
         else
           {
            //  توضیح فارسی
            isLow = false;
           }
        }

      //  توضیح فارسی
      if(isHigh)
        {
         SwingHighBuffer[checkIndex] = curHigh + effectiveArrowGap;
         
         //  توضیح فارسی
         bool isConsecutiveHighReplacement = (lastSwingType == 1);
         
         //  توضیح فارسی
         string highRelation = "";
         if(ShowSwingRelationLabels)
           {
            highRelation = CalculateHighRelation(curHigh, checkIndex, time);
           }
         
         //  توضیح فارسی
         if(!isConsecutiveHighReplacement)
           {
            secondLastSwingIndex = lastSwingIndex;
            secondLastSwingPrice = lastSwingPrice;
           }
         
         lastSwingType = 1;
         lastSwingIndex = checkIndex;
         lastSwingPrice = curHigh;
         
         //  توضیح فارسی
         lastHighIndex = checkIndex;
         lastHighPrice = curHigh;
         newSwingPointFound = true;
         
         //  توضیح فارسی
         UpdatePrevHighPoints(curHigh);
         
         //  توضیح فارسی
         if(!isConsecutiveHighReplacement)
           {
            UpdateAllHighPoints(curHigh, checkIndex);
           }
         
         //  توضیح فارسی
         if(!isConsecutiveHighReplacement)
           {
            AddToSwingHistory(curHigh, checkIndex, time[checkIndex], true);
            if(ShowTrendAnalysis)
              {
               AnalyzeTrend();
               UpdateTrendLabel();
              }
           }
        }
      else if(isLow)
        {
         SwingLowBuffer[checkIndex] = curLow - effectiveArrowGap;
         
         //  توضیح فارسی
         bool isConsecutiveLowReplacement = (lastSwingType == -1);
         
         //  توضیح فارسی
         string lowRelation = "";
         if(ShowSwingRelationLabels)
           {
            lowRelation = CalculateLowRelation(curLow, checkIndex, time);
           }
         
         //  توضیح فارسی
         if(!isConsecutiveLowReplacement)
           {
            secondLastSwingIndex = lastSwingIndex;
            secondLastSwingPrice = lastSwingPrice;
           }
         
         lastSwingType = -1;
         lastSwingIndex = checkIndex;
         lastSwingPrice = curLow;
         
         //  توضیح فارسی
         lastLowIndex = checkIndex;
         lastLowPrice = curLow;
         newSwingPointFound = true;
         
         //  توضیح فارسی
         UpdatePrevLowPoints(curLow);
         
         //  توضیح فارسی
         if(!isConsecutiveLowReplacement)
           {
            UpdateAllLowPoints(curLow, checkIndex);
           }
         
         //  توضیح فارسی
         if(!isConsecutiveLowReplacement)
           {
            AddToSwingHistory(curLow, checkIndex, time[checkIndex], false);
            if(ShowTrendAnalysis)
              {
               AnalyzeTrend();
               UpdateTrendLabel();
              }
           }
        }
     }

   //  توضیح فارسی
   datetime endTime = TimeCurrent();
   if(processedBars > 0)
     {
      Print("处理了 ", processedBars, " 根K线，用时 ", (endTime - startTime), " 秒");
     }

   //  توضیح فارسی
   //  توضیح فارسی
   if(newSwingPointFound && lastSwingIndex >= 0 && secondLastSwingIndex >= 0)
     {
      DrawTradingTools(lastSwingIndex, lastSwingPrice, secondLastSwingIndex, secondLastSwingPrice, (lastSwingType == 1), time);
     }
   
   //  توضیح فارسی
   if(newSwingPointFound || processedBars > 0)
     {
      ChartRedraw(0);
     }

   // اجرای منطق معامله‌گری رنج بر اساس سقف/کف تشخیص‌داده‌شده
   ExecuteRangeTrading(time);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void FindRecentSwingPoints(int startIndex, int endIndex, const double &high[], const double &low[])
  {
   //  توضیح فارسی
   int foundCount = 0;
   int foundIndices[2];
   int foundTypes[2]; //  توضیح فارسی
   double foundPrices[2];
   
   //  توضیح فارسی
   for(int i = endIndex - SwingPeriod - 1; i >= startIndex + SwingPeriod && foundCount < 2; i--)
     {
      bool isHigh = true;
      bool isLow = true;
      double curHigh = high[i];
      double curLow = low[i];

      //  توضیح فارسی
      for(int j = 1; j <= SwingPeriod; j++)
        {
         if(i - j >= 0 && high[i - j] >= curHigh) isHigh = false;
         if(i - j >= 0 && low[i - j] <= curLow) isLow = false;
         if(i + j < endIndex && high[i + j] >= curHigh) isHigh = false;
         if(i + j < endIndex && low[i + j] <= curLow) isLow = false;
        }

      //  توضیح فارسی
      if(isHigh || isLow)
        {
         foundIndices[foundCount] = i;
         if(isHigh && !isLow)
           {
            foundTypes[foundCount] = 1;
            foundPrices[foundCount] = curHigh;
           }
         else if(isLow && !isHigh)
           {
            foundTypes[foundCount] = -1;
            foundPrices[foundCount] = curLow;
           }
         else if(isHigh && isLow)
           {
            //  توضیح فارسی
            double highStrength = 0;
            double lowStrength = 0;
            
            for(int j = 1; j <= SwingPeriod; j++)
              {
               if(i - j >= 0) highStrength += (curHigh - high[i - j]);
               if(i + j < endIndex) highStrength += (curHigh - high[i + j]);
               if(i - j >= 0) lowStrength += (low[i - j] - curLow);
               if(i + j < endIndex) lowStrength += (low[i + j] - curLow);
              }
            
            if(highStrength > lowStrength)
              {
               foundTypes[foundCount] = 1;
               foundPrices[foundCount] = curHigh;
              }
            else
              {
               foundTypes[foundCount] = -1;
               foundPrices[foundCount] = curLow;
              }
           }
         foundCount++;
        }
     }
   
   //  توضیح فارسی
   if(foundCount >= 1)
     {
      lastSwingIndex = foundIndices[0];
      lastSwingType = foundTypes[0];
      lastSwingPrice = foundPrices[0];
      
      //  توضیح فارسی
      if(foundTypes[0] == 1) //  توضیح فارسی
        {
         lastHighIndex = foundIndices[0];
         lastHighPrice = foundPrices[0];
        }
      else //  توضیح فارسی
        {
         lastLowIndex = foundIndices[0];
         lastLowPrice = foundPrices[0];
        }
      
      if(foundCount >= 2)
        {
         secondLastSwingIndex = foundIndices[1];
         secondLastSwingPrice = foundPrices[1];
         
         //  توضیح فارسی
         if(foundTypes[1] == 1) //  توضیح فارسی
           {
            lastHighIndex = foundIndices[1];
            lastHighPrice = foundPrices[1];
           }
         else //  توضیح فارسی
           {
            lastLowIndex = foundIndices[1];
            lastLowPrice = foundPrices[1];
           }
        }
      
      Print("找到最近波段点 - 最后: 索引", lastSwingIndex, ", 类型", lastSwingType, ", 价格", lastSwingPrice,
            foundCount >= 2 ? StringFormat(", 倒数第二: 索引%d, 价格%.5f", secondLastSwingIndex, secondLastSwingPrice) : "");
      Print("高点跟踪: 索引", lastHighIndex, ", 价格", lastHighPrice);
      Print("低点跟踪: 索引", lastLowIndex, ", 价格", lastLowPrice);
      
      //  توضیح فارسی
      InitializePrevHighLowFromFound(foundCount, foundTypes, foundPrices);
     }
   else
     {
      Print("在指定范围内未找到波段点，将从头开始计算");
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void InitializePrevHighLowFromFound(int foundCount, int &foundTypes[], double &foundPrices[])
  {
   //  توضیح فارسی
   highPointsFound = 0;
   lowPointsFound = 0;
   ArrayInitialize(recentHighs, 0);
   ArrayInitialize(recentLows, 0);
   
   //  توضیح فارسی
   totalHighsFound = 0;
   totalLowsFound = 0;
   ArrayInitialize(allRecentHighs, 0);
   ArrayInitialize(allRecentLows, 0);
   ArrayInitialize(allRecentHighsIndices, -1);
   ArrayInitialize(allRecentLowsIndices, -1);
   
   //  توضیح فارسی
   for(int i = 0; i < foundCount; i++)
     {
      if(foundTypes[i] == 1) //  توضیح فارسی
        {
         if(highPointsFound < 2)
           {
            recentHighs[highPointsFound] = foundPrices[i];
            highPointsFound++;
           }
        }
      else if(foundTypes[i] == -1) //  توضیح فارسی
        {
         if(lowPointsFound < 2)
           {
            recentLows[lowPointsFound] = foundPrices[i];
            lowPointsFound++;
           }
        }
     }
   
   //  توضیح فارسی
   if(highPointsFound >= 1)
     {
      prevHighPrice = recentHighs[0];
      if(highPointsFound == 2)
        {
         prevHighPrice = MathMax(recentHighs[0], recentHighs[1]);
        }
     }
   
   if(lowPointsFound >= 1)
     {
      prevLowPrice = recentLows[0];
      if(lowPointsFound == 2)
        {
         prevLowPrice = MathMin(recentLows[0], recentLows[1]);
        }
     }
   
   Print("初始化前期高低点 - 高点数:", highPointsFound, ", 前期高点:", prevHighPrice, 
         ", 低点数:", lowPointsFound, ", 前期低点:", prevLowPrice);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DrawTradingTools(int currentIndex, double currentPrice, int lastIndex, double lastPrice, bool isHigh, const datetime &time[])
  {
   //  توضیح فارسی
   datetime currentTime = time[currentIndex];
   datetime lastTime = time[lastIndex];
   
   //  توضیح فارسی
   if(ShowTrendLines)
     {
      DrawTrendLine(currentIndex, currentPrice, lastIndex, lastPrice, currentTime, lastTime);
     }
   
   //  توضیح فارسی
   if(ShowBreakoutAlerts)
     {
      CheckBreakout(currentIndex, currentPrice, lastIndex, lastPrice, isHigh);
     }
   
   //  توضیح فارسی
   if(ShowFibonacci)
     {
      DrawFibonacci(time);
     }
   
   //  توضیح فارسی
   if(ShowPrevHighLow)
     {
      DrawPrevHighLowLines();
     }
   
   //  توضیح فارسی
   if(ShowHighTopLine || ShowLowBottomLine)
     {
      DrawTopBottomLines(time);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DrawTrendLine(int currentIndex, double currentPrice, int lastIndex, double lastPrice, datetime currentTime, datetime lastTime)
  {
   //  توضیح فارسی
   string lineName = trendLineName + "_" + IntegerToString(lastIndex) + "_" + IntegerToString(currentIndex);
   
   //  توضیح فارسی
   if(ObjectFind(0, lineName) < 0)
     {
      if(ObjectCreate(0, lineName, OBJ_TREND, 0, lastTime, lastPrice, currentTime, currentPrice))
        {
         ObjectSetInteger(0, lineName, OBJPROP_COLOR, TrendLineColor);
         ObjectSetInteger(0, lineName, OBJPROP_WIDTH, TrendLineWidth);
         ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
         
         //  توضیح فارسی
         if(lastCreatedTrendLine != "" && lastCreatedTrendLine != lineName)
           {
            ObjectDelete(0, lastCreatedTrendLine);
           }
         
         lastCreatedTrendLine = lineName;
         trendLineCounter++;
         
         //  توضیح فارسی
         if(trendLineCounter > MaxTrendLines)
           {
            CleanupOldTrendLines();
           }
           
         Print("绘制趋势线：从[", lastIndex, "] ", lastPrice, " 到[", currentIndex, "] ", currentPrice);
        }
     }
   else
     {
      //  توضیح فارسی
      ObjectSetInteger(0, lineName, OBJPROP_TIME, 0, lastTime);
      ObjectSetDouble(0, lineName, OBJPROP_PRICE, 0, lastPrice);
      ObjectSetInteger(0, lineName, OBJPROP_TIME, 1, currentTime);
      ObjectSetDouble(0, lineName, OBJPROP_PRICE, 1, currentPrice);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CheckBreakout(int currentIndex, double currentPrice, int lastIndex, double lastPrice, bool isHigh)
  {
   //  توضیح فارسی
   double currentClose = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //  توضیح فارسی
   double trendLinePrice = CalculateTrendLinePrice(lastIndex, lastPrice, currentIndex, currentPrice, 0);
   
   bool breakout = false;
   string message = "";
   
   if(isHigh) //  توضیح فارسی
     {
      if(currentClose > trendLinePrice)
        {
         breakout = true;
         message = "突破下降趋势线 - 看涨信号";
        }
     }
   else //  توضیح فارسی
     {
      if(currentClose < trendLinePrice)
        {
         breakout = true;
         message = "跌破上升趋势线 - 看跌信号";
        }
     }
   
   if(breakout && SendAlerts)
     {
      Alert(message + " - " + _Symbol);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
double CalculateTrendLinePrice(int x1, double y1, int x2, double y2, int targetIndex)
  {
   if(x1 == x2) return y1;
   
   double slope = (y2 - y1) / (x2 - x1);
   return y1 + slope * (targetIndex - x1);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DrawFibonacci(const datetime &time[])
  {
   //  توضیح فارسی
   if(lastHighIndex < 0 || lastLowIndex < 0)
      return;
   
   //  توضیح فارسی
   string fibName = fibLevelName + "_" + IntegerToString(lastHighIndex) + "_" + IntegerToString(lastLowIndex);
   
   //  توضیح فارسی
   if(lastCreatedFibLevel == fibName && ObjectFind(0, fibName) >= 0)
     {
      return;
     }
   
   datetime highTime = time[lastHighIndex];
   datetime lowTime = time[lastLowIndex];
   
   //  توضیح فارسی
   if(ObjectFind(0, fibName) < 0)
     {
      //  توضیح فارسی
      if(ObjectCreate(0, fibName, OBJ_FIBO, 0, highTime, lastHighPrice, lowTime, lastLowPrice))
        {
         ObjectSetInteger(0, fibName, OBJPROP_COLOR, clrGoldenrod);
         ObjectSetInteger(0, fibName, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, fibName, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, fibName, OBJPROP_RAY_LEFT, false);
         ObjectSetInteger(0, fibName, OBJPROP_BACK, false);
         
         //  توضیح فارسی
         ObjectSetInteger(0, fibName, OBJPROP_LEVELS, 5);
         
         //  توضیح فارسی
         double levels[5] = {0.0, 0.5, 1, 1.5, 2.0};
         string texts[5] = {"0", "0.5", "1", "1.5", "2"};
         
         for(int i = 0; i < 5; i++)
           {
            ObjectSetDouble(0, fibName, OBJPROP_LEVELVALUE, i, levels[i]);
            ObjectSetString(0, fibName, OBJPROP_LEVELTEXT, i, texts[i]);
            ObjectSetInteger(0, fibName, OBJPROP_LEVELCOLOR, i, clrGoldenrod);
            ObjectSetInteger(0, fibName, OBJPROP_LEVELSTYLE, i, STYLE_DOT);
            ObjectSetInteger(0, fibName, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, fibName, OBJPROP_ALIGN, i, ALIGN_LEFT);
           }
         
         //  توضیح فارسی
         if(lastCreatedFibLevel != "" && lastCreatedFibLevel != fibName)
           {
            ObjectDelete(0, lastCreatedFibLevel);
           }
         
         lastCreatedFibLevel = fibName;
         fibLevelCounter++;
         
         //  توضیح فارسی
         if(fibLevelCounter > MaxFibLevels)
           {
            CleanupOldFibLevels();
           }
           
         Print("绘制斐波那契回调：高点[", lastHighIndex, "] ", lastHighPrice, " -> 低点[", lastLowIndex, "] ", lastLowPrice);
        }
     }
   else
     {
      //  توضیح فارسی
      ObjectSetInteger(0, fibName, OBJPROP_TIME, 0, highTime);
      ObjectSetDouble(0, fibName, OBJPROP_PRICE, 0, lastHighPrice);
      ObjectSetInteger(0, fibName, OBJPROP_TIME, 1, lowTime);
      ObjectSetDouble(0, fibName, OBJPROP_PRICE, 1, lastLowPrice);
      
      //  توضیح فارسی
      if(lastCreatedFibLevel != "" && lastCreatedFibLevel != fibName)
        {
         ObjectDelete(0, lastCreatedFibLevel);
        }
      
      lastCreatedFibLevel = fibName;
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
int GetTrendDirection()
  {
   if(lastSwingIndex >= 0 && secondLastSwingIndex >= 0)
     {
      if(lastSwingType == 1) //  توضیح فارسی
        {
         return (lastSwingPrice > secondLastSwingPrice) ? 1 : -1; //  توضیح فارسی
        }
      else //  توضیح فارسی
        {
         return (lastSwingPrice < secondLastSwingPrice) ? -1 : 1; //  توضیح فارسی
        }
     }
   return 0; //  توضیح فارسی
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
double GetSupportResistance(bool getSupport)
  {
   if(lastSwingIndex >= 0)
     {
      if(getSupport)
        {
         return (lastSwingType == -1) ? lastSwingPrice : secondLastSwingPrice;
        }
      else
        {
         return (lastSwingType == 1) ? lastSwingPrice : secondLastSwingPrice;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CleanupOldObjects()
  {
   //  توضیح فارسی
   int totalObjects = ObjectsTotal(0);
   string objectsToDelete[];
   int deleteCount = 0;
   
   //  توضیح فارسی
   for(int i = 0; i < totalObjects; i++)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, trendLineName) >= 0 || 
         StringFind(objName, fibLevelName) >= 0 ||
         StringFind(objName, prevHighLineName) >= 0 ||
         StringFind(objName, prevLowLineName) >= 0 ||
         StringFind(objName, highTopLineName) >= 0 ||
         StringFind(objName, lowBottomLineName) >= 0 ||
         StringFind(objName, relationLabelPrefix) >= 0 ||
         StringFind(objName, trendLabelName) >= 0)
        {
         ArrayResize(objectsToDelete, deleteCount + 1);
         objectsToDelete[deleteCount] = objName;
         deleteCount++;
        }
     }
   
   //  توضیح فارسی
   for(int i = 0; i < deleteCount; i++)
     {
      ObjectDelete(0, objectsToDelete[i]);
     }
   
   //  توضیح فارسی
   if(deleteCount > 0)
     {
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CleanupOldTrendLines()
  {
   int totalObjects = ObjectsTotal(0);
   string trendLineObjects[];
   int trendLineCount = 0;
   
   //  توضیح فارسی
   for(int i = 0; i < totalObjects; i++)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, trendLineName) >= 0)
        {
         ArrayResize(trendLineObjects, trendLineCount + 1);
         trendLineObjects[trendLineCount] = objName;
         trendLineCount++;
        }
     }
   
   //  توضیح فارسی
   if(trendLineCount > MaxTrendLines)
     {
      int deleteCount = trendLineCount - MaxTrendLines;
      for(int i = 0; i < deleteCount; i++)
        {
         ObjectDelete(0, trendLineObjects[i]);
        }
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CleanupOldFibLevels()
  {
   int totalObjects = ObjectsTotal(0);
   string fibObjects[];
   int fibCount = 0;
   
   //  توضیح فارسی
   for(int i = 0; i < totalObjects; i++)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, fibLevelName) >= 0)
        {
         ArrayResize(fibObjects, fibCount + 1);
         fibObjects[fibCount] = objName;
         fibCount++;
        }
     }
   
   //  توضیح فارسی
   if(fibCount > MaxFibLevels)
     {
      int deleteCount = fibCount - MaxFibLevels;
      for(int i = 0; i < deleteCount; i++)
        {
         ObjectDelete(0, fibObjects[i]);
        }
     }
  }
//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void UpdatePrevHighPoints(double newHigh)
  {
   if(highPointsFound == 0)
     {
      //  توضیح فارسی
      recentHighs[0] = newHigh;
      highPointsFound = 1;
      prevHighPrice = newHigh;
     }
   else if(highPointsFound == 1)
     {
      //  توضیح فارسی
      recentHighs[1] = newHigh;
      highPointsFound = 2;
      //  توضیح فارسی
      prevHighPrice = MathMax(recentHighs[0], recentHighs[1]);
     }
   else
     {
      //  توضیح فارسی
      recentHighs[0] = recentHighs[1];
      recentHighs[1] = newHigh;
      //  توضیح فارسی
      prevHighPrice = MathMax(recentHighs[0], recentHighs[1]);
     }
   
   Print("更新前期高点：新高点=", newHigh, ", 前期高点=", prevHighPrice);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void UpdatePrevLowPoints(double newLow)
  {
   if(lowPointsFound == 0)
     {
      //  توضیح فارسی
      recentLows[0] = newLow;
      lowPointsFound = 1;
      prevLowPrice = newLow;
     }
   else if(lowPointsFound == 1)
     {
      //  توضیح فارسی
      recentLows[1] = newLow;
      lowPointsFound = 2;
      //  توضیح فارسی
      prevLowPrice = MathMin(recentLows[0], recentLows[1]);
     }
   else
     {
      //  توضیح فارسی
      recentLows[0] = recentLows[1];
      recentLows[1] = newLow;
      //  توضیح فارسی
      prevLowPrice = MathMin(recentLows[0], recentLows[1]);
     }
   
   Print("更新前期低点：新低点=", newLow, ", 前期低点=", prevLowPrice);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DrawPrevHighLowLines()
  {
   //  توضیح فارسی
   if(prevHighPrice > 0)
     {
      if(ObjectFind(0, prevHighLineName) < 0)
        {
         //  توضیح فارسی
         if(ObjectCreate(0, prevHighLineName, OBJ_HLINE, 0, 0, prevHighPrice))
           {
            ObjectSetInteger(0, prevHighLineName, OBJPROP_COLOR, PrevHighColor);
            ObjectSetInteger(0, prevHighLineName, OBJPROP_WIDTH, PrevLineWidth);
            ObjectSetInteger(0, prevHighLineName, OBJPROP_STYLE, PrevLineStyle);
            ObjectSetInteger(0, prevHighLineName, OBJPROP_BACK, false);
            ObjectSetString(0, prevHighLineName, OBJPROP_TEXT, "Prev High: " + DoubleToString(prevHighPrice, _Digits));
           }
        }
      else
        {
         //  توضیح فارسی
         ObjectSetDouble(0, prevHighLineName, OBJPROP_PRICE, 0, prevHighPrice);
         ObjectSetString(0, prevHighLineName, OBJPROP_TEXT, "Prev High: " + DoubleToString(prevHighPrice, _Digits));
        }
     }
   
   //  توضیح فارسی
   if(prevLowPrice > 0)
     {
      if(ObjectFind(0, prevLowLineName) < 0)
        {
         //  توضیح فارسی
         if(ObjectCreate(0, prevLowLineName, OBJ_HLINE, 0, 0, prevLowPrice))
           {
            ObjectSetInteger(0, prevLowLineName, OBJPROP_COLOR, PrevLowColor);
            ObjectSetInteger(0, prevLowLineName, OBJPROP_WIDTH, PrevLineWidth);
            ObjectSetInteger(0, prevLowLineName, OBJPROP_STYLE, PrevLineStyle);
            ObjectSetInteger(0, prevLowLineName, OBJPROP_BACK, false);
            ObjectSetString(0, prevLowLineName, OBJPROP_TEXT, "Prev Low: " + DoubleToString(prevLowPrice, _Digits));
           }
        }
      else
        {
         //  توضیح فارسی
         ObjectSetDouble(0, prevLowLineName, OBJPROP_PRICE, 0, prevLowPrice);
         ObjectSetString(0, prevLowLineName, OBJPROP_TEXT, "Prev Low: " + DoubleToString(prevLowPrice, _Digits));
        }
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void UpdateAllHighPoints(double newHigh, int newIndex)
  {
   //  توضیح فارسی
   for(int i = 3; i > 0; i--)
     {
      allRecentHighs[i] = allRecentHighs[i-1];
      allRecentHighsIndices[i] = allRecentHighsIndices[i-1];
     }
   
   //  توضیح فارسی
   allRecentHighs[0] = newHigh;
   allRecentHighsIndices[0] = newIndex;
   
   if(totalHighsFound < 4)
      totalHighsFound++;
   
   //  توضیح فارسی
   CleanupInvalidHighPoints();
   
   Print("更新有箭头的高点：新高点[", newIndex, "]=", newHigh, ", 总高点数=", totalHighsFound);
   
   //  توضیح فارسی
   string debugStr = "高点数组状态: ";
   for(int i = 0; i < totalHighsFound; i++)
     {
      debugStr += StringFormat("[%d]:%.5f@%d ", i, allRecentHighs[i], allRecentHighsIndices[i]);
     }
   Print(debugStr);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void UpdateAllLowPoints(double newLow, int newIndex)
  {
   //  توضیح فارسی
   for(int i = 3; i > 0; i--)
     {
      allRecentLows[i] = allRecentLows[i-1];
      allRecentLowsIndices[i] = allRecentLowsIndices[i-1];
     }
   
   //  توضیح فارسی
   allRecentLows[0] = newLow;
   allRecentLowsIndices[0] = newIndex;
   
   if(totalLowsFound < 4)
      totalLowsFound++;
   
   //  توضیح فارسی
   CleanupInvalidLowPoints();
   
   Print("更新有箭头的低点：新低点[", newIndex, "]=", newLow, ", 总低点数=", totalLowsFound);
   
   //  توضیح فارسی
   string debugStr = "低点数组状态: ";
   for(int i = 0; i < totalLowsFound; i++)
     {
      debugStr += StringFormat("[%d]:%.5f@%d ", i, allRecentLows[i], allRecentLowsIndices[i]);
     }
   Print(debugStr);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DrawTopBottomLines(const datetime &time[])
  {
   //  توضیح فارسی
   if(ShowHighTopLine && totalHighsFound >= 3)
     {
      //  توضیح فارسی
      int validHighIndices[2];
      double validHighPrices[2];
      int validCount = 0;
      
      //  توضیح فارسی
      for(int i = 1; i < totalHighsFound && validCount < 2; i++)
        {
         int index = allRecentHighsIndices[i];
         if(index >= 0 && SwingHighBuffer[index] != EMPTY_VALUE)
           {
            //  توضیح فارسی
            bool isDuplicate = false;
            for(int j = 0; j < validCount; j++)
              {
               if(validHighIndices[j] == index)
                 {
                  isDuplicate = true;
                  break;
                 }
              }
            
            //  توضیح فارسی
            if(!isDuplicate)
              {
               validHighIndices[validCount] = index;
               validHighPrices[validCount] = allRecentHighs[i];
               validCount++;
              }
           }
        }
      
      //  توضیح فارسی
      if(validCount >= 2)
        {
         int index2 = validHighIndices[0]; //  توضیح فارسی
         int index3 = validHighIndices[1]; //  توضیح فارسی
         double price2 = validHighPrices[0];
         double price3 = validHighPrices[1];
         
         datetime time2 = time[index2];
         datetime time3 = time[index3];
         
         //  توضیح فارسی
         if(index2 != index3)
           {
            if(ObjectFind(0, highTopLineName) < 0)
              {
               //  توضیح فارسی
               if(ObjectCreate(0, highTopLineName, OBJ_TREND, 0, time3, price3, time2, price2))
                 {
                  ObjectSetInteger(0, highTopLineName, OBJPROP_COLOR, HighTopColor);
                  ObjectSetInteger(0, highTopLineName, OBJPROP_WIDTH, TopBottomLineWidth);
                  ObjectSetInteger(0, highTopLineName, OBJPROP_STYLE, TopBottomLineStyle);
                  ObjectSetInteger(0, highTopLineName, OBJPROP_RAY_RIGHT, true);
                  ObjectSetInteger(0, highTopLineName, OBJPROP_RAY_LEFT, false);
                  ObjectSetInteger(0, highTopLineName, OBJPROP_BACK, false);
                  
                  Print("创建高点顶部射线：从[", index3, "] ", price3, " 到[", index2, "] ", price2, " (找到", validCount, "个有效高点)");
                 }
              }
            else
              {
               //  توضیح فارسی
               ObjectSetInteger(0, highTopLineName, OBJPROP_TIME, 0, time3);
               ObjectSetDouble(0, highTopLineName, OBJPROP_PRICE, 0, price3);
               ObjectSetInteger(0, highTopLineName, OBJPROP_TIME, 1, time2);
               ObjectSetDouble(0, highTopLineName, OBJPROP_PRICE, 1, price2);
              }
           }
         else
           {
            Print("错误：倒数第2个和倒数第3个高点索引相同 [", index2, "], 跳过射线绘制");
           }
        }
      else
        {
         Print("高点顶部射线跳过：只找到", validCount, "个有效且不重复的高点，需要至少2个");
        }
     }
   
   //  توضیح فارسی
   if(ShowLowBottomLine && totalLowsFound >= 3)
     {
      //  توضیح فارسی
      int validLowIndices[3];
      double validLowPrices[3];
      int validCount = 0;
      
      //  توضیح فارسی
      for(int i = 0; i < totalLowsFound && validCount < 3; i++)
        {
         int index = allRecentLowsIndices[i];
         if(index >= 0 && SwingLowBuffer[index] != EMPTY_VALUE)
           {
            //  توضیح فارسی
            bool isDuplicate = false;
            for(int j = 0; j < validCount; j++)
              {
               if(validLowIndices[j] == index)
                 {
                  isDuplicate = true;
                  break;
                 }
              }
            
            //  توضیح فارسی
            if(!isDuplicate)
              {
               validLowIndices[validCount] = index;
               validLowPrices[validCount] = allRecentLows[i];
               validCount++;
              }
           }
        }
      
      //  توضیح فارسی
      if(validCount >= 3)
        {
         int index2 = validLowIndices[1]; //  توضیح فارسی
         int index3 = validLowIndices[2]; //  توضیح فارسی
         double price2 = validLowPrices[1];
         double price3 = validLowPrices[2];
         
         datetime time2 = time[index2];
         datetime time3 = time[index3];
         
         //  توضیح فارسی
         Print("低点底部射线连接：倒数第3个低点[", index3, "] ", price3, " -> 倒数第2个低点[", index2, "] ", price2);
         Print("当前低点数组状态 - 总数:", totalLowsFound, ", 有效不重复数:", validCount);
         Print("最新3个有效低点: [", validLowIndices[0], "]", validLowPrices[0], ", [", validLowIndices[1], "]", validLowPrices[1], ", [", validLowIndices[2], "]", validLowPrices[2]);
         
         //  توضیح فارسی
         if(index2 != index3)
           {
            if(ObjectFind(0, lowBottomLineName) < 0)
              {
               //  توضیح فارسی
               if(ObjectCreate(0, lowBottomLineName, OBJ_TREND, 0, time3, price3, time2, price2))
                 {
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_COLOR, LowBottomColor);
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_WIDTH, TopBottomLineWidth);
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_STYLE, TopBottomLineStyle);
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_RAY_RIGHT, true);
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_RAY_LEFT, false);
                  ObjectSetInteger(0, lowBottomLineName, OBJPROP_BACK, false);
                  
                  Print("成功创建低点底部射线：从倒数第3个[", index3, "] ", price3, " 到倒数第2个[", index2, "] ", price2);
                 }
              }
            else
              {
               //  توضیح فارسی
               ObjectSetInteger(0, lowBottomLineName, OBJPROP_TIME, 0, time3);
               ObjectSetDouble(0, lowBottomLineName, OBJPROP_PRICE, 0, price3);
               ObjectSetInteger(0, lowBottomLineName, OBJPROP_TIME, 1, time2);
               ObjectSetDouble(0, lowBottomLineName, OBJPROP_PRICE, 1, price2);
               
               Print("成功更新低点底部射线：从倒数第3个[", index3, "] ", price3, " 到倒数第2个[", index2, "] ", price2);
              }
           }
         else
           {
            Print("错误：倒数第2个和倒数第3个低点索引相同 [", index2, "], 跳过射线绘制");
           }
        }
      else
        {
         Print("低点底部射线跳过：只找到", validCount, "个有效且不重复的低点，需要至少3个");
        }
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CleanupInvalidHighPoints()
  {
   //  توضیح فارسی
   int validCount = 0;
   double tempHighs[4];
   int tempIndices[4];
   
   for(int i = 0; i < totalHighsFound; i++)
     {
      int index = allRecentHighsIndices[i];
      if(index >= 0 && SwingHighBuffer[index] != EMPTY_VALUE)
        {
         tempHighs[validCount] = allRecentHighs[i];
         tempIndices[validCount] = allRecentHighsIndices[i];
         validCount++;
        }
     }
   
   //  توضیح فارسی
   if(validCount != totalHighsFound)
     {
      Print("清理高点数组：移除了", (totalHighsFound - validCount), "个无效点，剩余", validCount, "个有效点");
      
      //  توضیح فارسی
      for(int i = 0; i < 4; i++)
        {
         if(i < validCount)
           {
            allRecentHighs[i] = tempHighs[i];
            allRecentHighsIndices[i] = tempIndices[i];
           }
         else
           {
            allRecentHighs[i] = 0;
            allRecentHighsIndices[i] = -1;
           }
        }
      
      totalHighsFound = validCount;
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CleanupInvalidLowPoints()
  {
   //  توضیح فارسی
   int validCount = 0;
   double tempLows[4];
   int tempIndices[4];
   
   for(int i = 0; i < totalLowsFound; i++)
     {
      int index = allRecentLowsIndices[i];
      if(index >= 0 && SwingLowBuffer[index] != EMPTY_VALUE)
        {
         tempLows[validCount] = allRecentLows[i];
         tempIndices[validCount] = allRecentLowsIndices[i];
         validCount++;
        }
     }
   
   //  توضیح فارسی
   if(validCount != totalLowsFound)
     {
      Print("清理低点数组：移除了", (totalLowsFound - validCount), "个无效点，剩余", validCount, "个有效点");
      
      //  توضیح فارسی
      for(int i = 0; i < 4; i++)
        {
         if(i < validCount)
           {
            allRecentLows[i] = tempLows[i];
            allRecentLowsIndices[i] = tempIndices[i];
           }
         else
           {
            allRecentLows[i] = 0;
            allRecentLowsIndices[i] = -1;
           }
        }
      
      totalLowsFound = validCount;
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//+------------------------------------------------------------------+
bool ProcessConsecutiveHighPoints(double currentHigh, int currentIndex)
  {
   //  توضیح فارسی
   if(currentHigh > lastSwingPrice)
     {
      //  توضیح فارسی
      Print("连续高点去重：当前高点", currentHigh, "[", currentIndex, "] 高于上一个", lastSwingPrice, "[", lastSwingIndex, "]，替换上一个");
      
      //  توضیح فارسی
      if(lastSwingIndex >= 0)
        {
         SwingHighBuffer[lastSwingIndex] = EMPTY_VALUE;
         
         //  توضیح فارسی
         if(ShowSwingRelationLabels)
           {
            DeleteRelationLabelsAtIndex(lastSwingIndex);
           }
        }
      
      //  توضیح فارسی
      if(totalHighsFound > 0)
        {
         //  توضیح فارسی
         allRecentHighs[0] = currentHigh;
         allRecentHighsIndices[0] = currentIndex;
         Print("更新扩展高点数组：替换最新高点为", currentHigh, "@", currentIndex);
        }
      
      return true; //  توضیح فارسی
     }
   else
     {
      //  توضیح فارسی
      Print("连续高点去重：当前高点", currentHigh, "[", currentIndex, "] 低于上一个", lastSwingPrice, "[", lastSwingIndex, "]，忽略当前");
      return false; //  توضیح فارسی
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//| توضیح فارسی
//+------------------------------------------------------------------+
bool ProcessConsecutiveLowPoints(double currentLow, int currentIndex)
  {
   //  توضیح فارسی
   if(currentLow < lastSwingPrice)
     {
      //  توضیح فارسی
      Print("连续低点去重：当前低点", currentLow, "[", currentIndex, "] 低于上一个", lastSwingPrice, "[", lastSwingIndex, "]，替换上一个");
      
      //  توضیح فارسی
      if(lastSwingIndex >= 0)
        {
         SwingLowBuffer[lastSwingIndex] = EMPTY_VALUE;
         
         //  توضیح فارسی
         if(ShowSwingRelationLabels)
           {
            DeleteRelationLabelsAtIndex(lastSwingIndex);
           }
        }
      
      //  توضیح فارسی
      if(totalLowsFound > 0)
        {
         //  توضیح فارسی
         allRecentLows[0] = currentLow;
         allRecentLowsIndices[0] = currentIndex;
         Print("更新扩展低点数组：替换最新低点为", currentLow, "@", currentIndex);
        }
      
      return true; //  توضیح فارسی
     }
   else
     {
      //  توضیح فارسی
      Print("连续低点去重：当前低点", currentLow, "[", currentIndex, "] 高于上一个", lastSwingPrice, "[", lastSwingIndex, "]，忽略当前");
      return false; //  توضیح فارسی
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void InitializeSwingPointData(SwingPointData &point)
  {
   point.price = 0;
   point.index = -1;
   point.time = 0;
   point.relation = "";
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
string CalculateHighRelation(double currentHigh, int currentIndex, const datetime &time[])
  {
   string relation = "";
   
   //  توضیح فارسی
   if(lastHighPoint.index == -1)
     {
      //  توضیح فارسی
      secondLastHighPoint = lastHighPoint;
      lastHighPoint.price = currentHigh;
      lastHighPoint.index = currentIndex;
      lastHighPoint.time = time[currentIndex];
      lastHighPoint.relation = "First High";
      return ""; //  توضیح فارسی
     }
   
   //  توضیح فارسی
   if(currentHigh > lastHighPoint.price)
     {
      relation = "HH"; //  توضیح فارسی
     }
   else
     {
      relation = "LH"; //  توضیح فارسی
     }
   
   //  توضیح فارسی
   CreateSwingRelationLabel(currentHigh, currentIndex, time[currentIndex], relation, true);
   
   //  توضیح فارسی
   secondLastHighPoint = lastHighPoint;
   lastHighPoint.price = currentHigh;
   lastHighPoint.index = currentIndex;
   lastHighPoint.time = time[currentIndex];
   lastHighPoint.relation = relation;
   
   Print("高点关系计算：当前高点 ", currentHigh, " [", currentIndex, "] 相对于前一个高点 ", 
         secondLastHighPoint.price, " [", secondLastHighPoint.index, "] 的关系是：", relation);
   
   return relation;
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
string CalculateLowRelation(double currentLow, int currentIndex, const datetime &time[])
  {
   string relation = "";
   
   //  توضیح فارسی
   if(lastLowPoint.index == -1)
     {
      //  توضیح فارسی
      secondLastLowPoint = lastLowPoint;
      lastLowPoint.price = currentLow;
      lastLowPoint.index = currentIndex;
      lastLowPoint.time = time[currentIndex];
      lastLowPoint.relation = "First Low";
      return ""; //  توضیح فارسی
     }
   
   //  توضیح فارسی
   if(currentLow > lastLowPoint.price)
     {
      relation = "HL"; //  توضیح فارسی
     }
   else
     {
      relation = "LL"; //  توضیح فارسی
     }
   
   //  توضیح فارسی
   CreateSwingRelationLabel(currentLow, currentIndex, time[currentIndex], relation, false);
   
   //  توضیح فارسی
   secondLastLowPoint = lastLowPoint;
   lastLowPoint.price = currentLow;
   lastLowPoint.index = currentIndex;
   lastLowPoint.time = time[currentIndex];
   lastLowPoint.relation = relation;
   
   Print("低点关系计算：当前低点 ", currentLow, " [", currentIndex, "] 相对于前一个低点 ", 
         secondLastLowPoint.price, " [", secondLastLowPoint.index, "] 的关系是：", relation);
   
   return relation;
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void CreateSwingRelationLabel(double price, int barIndex, datetime barTime, string relation, bool isHigh)
  {
   //  توضیح فارسی
   string labelName = relationLabelPrefix + IntegerToString(labelCounter) + "_" + relation + "_" + IntegerToString(barIndex);
   labelCounter++;
   
   //  توضیح فارسی
   double labelPrice;
   ENUM_ANCHOR_POINT anchor;
   color labelColor;
   
   if(isHigh)
     {
      labelPrice = price + effectiveArrowGap * 2; //  توضیح فارسی
      anchor = ANCHOR_LOWER;
      
      if(relation == "HH")
         labelColor = HigherHighColor;
      else
         labelColor = LowerHighColor;
     }
   else
     {
      labelPrice = price - effectiveArrowGap * 2; //  توضیح فارسی
      anchor = ANCHOR_UPPER;
      
      if(relation == "HL")
         labelColor = HigherLowColor;
      else
         labelColor = LowerLowColor;
     }
   
   //  توضیح فارسی
   if(ObjectCreate(0, labelName, OBJ_TEXT, 0, barTime, labelPrice))
     {
      ObjectSetString(0, labelName, OBJPROP_TEXT, relation);
      ObjectSetString(0, labelName, OBJPROP_FONT, LabelFont);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, LabelFontSize);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, labelColor);
      ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, labelName, OBJPROP_BACK, false);
      ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
      
      Print("创建关系标签：", relation, " 在 [", barIndex, "] ", price, " 时间：", TimeToString(barTime));
     }
   else
     {
      Print("创建关系标签失败：", relation, " 在 [", barIndex, "] ", price);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void DeleteRelationLabelsAtIndex(int barIndex)
  {
   int totalObjects = ObjectsTotal(0);
   string labelsToDelete[];
   int deleteCount = 0;
   
   //  توضیح فارسی
   for(int i = 0; i < totalObjects; i++)
     {
      string objName = ObjectName(0, i);
      if(StringFind(objName, relationLabelPrefix) >= 0 && 
         StringFind(objName, "_" + IntegerToString(barIndex)) >= 0)
        {
         ArrayResize(labelsToDelete, deleteCount + 1);
         labelsToDelete[deleteCount] = objName;
         deleteCount++;
        }
     }
   
   //  توضیح فارسی
   for(int i = 0; i < deleteCount; i++)
     {
      ObjectDelete(0, labelsToDelete[i]);
      Print("删除关系标签：", labelsToDelete[i]);
     }
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void AddToSwingHistory(double price, int index, datetime time, bool isHigh)
  {
   //  توضیح فارسی
   for(int i = 7; i > 0; i--)
     {
      swingHistory[i] = swingHistory[i-1];
     }
   
   //  توضیح فارسی
   swingHistory[0].price = price;
   swingHistory[0].index = index;
   swingHistory[0].time = time;
   swingHistory[0].relation = isHigh ? "H" : "L";
   
   if(swingHistoryCount < 8)
      swingHistoryCount++;
   
   Print("添加摆动点到历史：", (isHigh ? "高点" : "低点"), " 价格=", price, " 索引=", index, " 总数=", swingHistoryCount);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void AnalyzeTrend()
  {
   if(swingHistoryCount < TrendAnalysisPeriod)
     {
      currentTrend = TREND_RANGE;
      Print("趋势分析：摆动点数量不足，当前=", swingHistoryCount, ", 需要=", TrendAnalysisPeriod);
      return;
     }
   
   //  توضیح فارسی
   double highs[];
   double lows[];
   int highCount = 0;
   int lowCount = 0;
   
   for(int i = 0; i < TrendAnalysisPeriod && i < swingHistoryCount; i++)
     {
      if(swingHistory[i].relation == "H")
        {
         ArrayResize(highs, highCount + 1);
         highs[highCount] = swingHistory[i].price;
         highCount++;
        }
      else if(swingHistory[i].relation == "L")
        {
         ArrayResize(lows, lowCount + 1);
         lows[lowCount] = swingHistory[i].price;
         lowCount++;
        }
     }
   
   //  توضیح فارسی
   if(highCount < 2 || lowCount < 2)
     {
      currentTrend = TREND_RANGE;
      Print("趋势分析：高低点数量不足 - 高点=", highCount, ", 低点=", lowCount, " (各需要>=2)");
      return;
     }
   
   //  توضیح فارسی
   bool highsRising = true;
   bool highsFalling = true;
   for(int i = 0; i < highCount - 1; i++)
     {
      //  توضیح فارسی
      if(highs[i] <= highs[i+1]) highsRising = false;  //  توضیح فارسی
      if(highs[i] >= highs[i+1]) highsFalling = false; //  توضیح فارسی
     }
   
   //  توضیح فارسی
   bool lowsRising = true;
   bool lowsFalling = true;
   for(int i = 0; i < lowCount - 1; i++)
     {
      //  توضیح فارسی
      if(lows[i] <= lows[i+1]) lowsRising = false;   //  توضیح فارسی
      if(lows[i] >= lows[i+1]) lowsFalling = false;  //  توضیح فارسی
     }
   
   //  توضیح فارسی
   if(highsRising && lowsRising)
     {
      currentTrend = TREND_UP;
      Print("趋势分析：上升趋势 (HH + HL) - 高点上升:", highsRising, ", 低点上升:", lowsRising);
     }
   else if(highsFalling && lowsFalling)
     {
      currentTrend = TREND_DOWN;
      Print("趋势分析：下降趋势 (LH + LL) - 高点下降:", highsFalling, ", 低点下降:", lowsFalling);
     }
   else
     {
      currentTrend = TREND_RANGE;
      Print("趋势分析：交易区间 (混合模式) - 高点上升:", highsRising, ", 高点下降:", highsFalling, ", 低点上升:", lowsRising, ", 低点下降:", lowsFalling);
     }
   
   //  توضیح فارسی
   string debugStr = "最近" + IntegerToString(highCount) + "个高点序列(新->老): ";
   for(int i = 0; i < highCount; i++)
     {
      debugStr += DoubleToString(highs[i], 5);
      if(i < highCount - 1) debugStr += " -> ";
     }
   Print(debugStr);
   
   debugStr = "最近" + IntegerToString(lowCount) + "个低点序列(新->老): ";
   for(int i = 0; i < lowCount; i++)
     {
      debugStr += DoubleToString(lows[i], 5);
      if(i < lowCount - 1) debugStr += " -> ";
     }
   Print(debugStr);
  }

//+------------------------------------------------------------------+
//| توضیح فارسی
//+------------------------------------------------------------------+
void UpdateTrendLabel()
  {
   //  توضیح فارسی
   ObjectDelete(0, trendLabelName);
   
   //  توضیح فارسی
   string trendText = "";
   color trendColor = clrWhite;
   
   switch(currentTrend)
     {
      case TREND_UP:
         trendText = "趋势：上升 ↗";
         trendColor = UpTrendColor;
         break;
      case TREND_DOWN:
         trendText = "趋势：下降 ↘";
         trendColor = DownTrendColor;
         break;
      case TREND_RANGE:
         trendText = "趋势：区间 ↔";
         trendColor = RangeColor;
         break;
     }
   
   //  توضیح فارسی
   trendText += " (" + IntegerToString(swingHistoryCount) + "点)";
   
   //  توضیح فارسی
   long chartWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long chartHeight = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   //  توضیح فارسی
   int labelX = (int)(chartWidth - 200); //  توضیح فارسی
   int labelY = 30; //  توضیح فارسی
   
   //  توضیح فارسی
   if(labelX < 10) labelX = 10;
   
   //  توضیح فارسی
   if(ObjectCreate(0, trendLabelName, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetString(0, trendLabelName, OBJPROP_TEXT, trendText);
      ObjectSetString(0, trendLabelName, OBJPROP_FONT, LabelFont);
      ObjectSetInteger(0, trendLabelName, OBJPROP_FONTSIZE, TrendLabelFontSize);
      ObjectSetInteger(0, trendLabelName, OBJPROP_COLOR, trendColor);
      ObjectSetInteger(0, trendLabelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, trendLabelName, OBJPROP_XDISTANCE, labelX);
      ObjectSetInteger(0, trendLabelName, OBJPROP_YDISTANCE, labelY);
      ObjectSetInteger(0, trendLabelName, OBJPROP_BACK, false);
      ObjectSetInteger(0, trendLabelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, trendLabelName, OBJPROP_HIDDEN, true);
      
      Print("更新趋势标签：", trendText, " 位置：(", labelX, ",", labelY, ")");
     }
   else
     {
      Print("创建趋势标签失败：", trendText);
     }
  }