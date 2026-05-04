//+------------------------------------------------------------------+
//|                                     Ahangari_Scalp_Fixed_V2.mq5  |
//|                                  Copyright 2026, Gemini Trading  |
//|                        Strategy: Scalp & Rapid Recovery (MQL5)   |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>

//--- تنظیمات ورودی
input double RiskPercent     = 2.0;      // ریسک در هر معامله
input int    TrailingStop    = 100;      // تریلینگ استاپ (پوینت)
input int    BreakevenProfit = 80;       // سود برای ریسک فری (پوینت)
input int    RangeCandles    = 20;       
input double MaxDailyLossPct = 5.0;      
input color  PanelColor      = clrCyan;
input int    EmaPeriod       = 200;
input int    AtrPeriod       = 14;
input double RiskReward      = 1.6;
input int    BreakoutBufferPoints = 30;
input int    MaxSpreadPoints = 40;
input int    MinAtrPoints    = 120;
input int    MinBarsBetweenEntries = 1;
input bool   UseSessionFilter = true;
input int    LondonSessionStartHour = 10;
input int    LondonSessionEndHour = 18;
input int    NewYorkSessionStartHour = 15;
input int    NewYorkSessionEndHour = 23;
input bool   UseNewsTimeFilter = true;
input string HighImpactNewsTimes = "15:30,17:00,21:30";
input int    NewsBlockMinutesBefore = 45;
input int    NewsBlockMinutesAfter = 30;
input int    MaxConsecutiveLosses = 2;
input int    MaxTradesPerDay = 8;
input double MaxDailyProfitPct = 0.0;
input bool   TradeOnMonday = true;
input bool   TradeOnTuesday = true;
input bool   TradeOnWednesday = true;
input bool   TradeOnThursday = true;
input bool   TradeOnFriday = true;
input int    MaxOpenPositions = 2;
input bool   AllowSecondPositionAfterOneToOne = true;
input double MinimumEntryScore = 58.0;
input double ScoreWeightBreakout = 35.0;
input double ScoreWeightTrend = 20.0;
input double ScoreWeightRsi = 15.0;
input double ScoreWeightAtr = 15.0;
input double ScoreWeightSpread = 15.0;
input bool   UseSmartMoneyFilter = true;
input bool   RequireLiquiditySweep = false;
input bool   RequireFairValueGap = false;
input double MinDisplacementAtrRatio = 0.8;
input double ScoreWeightSmartMoney = 25.0;
input double StrongSignalScoreBuffer = 15.0;
input double StrongSignalRiskRewardBoost = 0.4;
input bool   UseSmcReversalMode = true;
input bool   RequireMssForReversal = false;
input double ScoreWeightReversal = 30.0;
input double ReversalRiskReward = 1.3;
input double MinimumScoreGap = 3.0;
input int    MssLookbackBars = 8;
input double MinEmaSlopePoints = 15.0;
input bool   RequireDisplacementForBreakout = false;
input double ReversalMaxEmaDistanceAtr = 0.8;
input double BreakoutMinEmaDistanceAtr = 0.15;
input bool   EnableDynamicAntiLossMode = false;
input double EntryScorePenaltyPerLoss = 5.0;
input double MaxDynamicEntryScoreBoost = 20.0;
input bool   EnableFallbackEntryMode = true;
input bool   EnableSignalDebugPanel = true;
input bool   EnableDynamicLotScalingAfterLoss = true;
input double LotScalePerLoss = 0.20;
input double MinLotScaleFactor = 0.40;
input bool   EnablePartialTakeProfit = true;
input double PartialClosePercentAtOneToOne = 0.50;
input bool   UseDeadMarketHoursFilter = true;
input int    DeadMarketStartHour = 0;
input int    DeadMarketEndHour = 7;
input bool   EnableAdaptiveVolatilityFilter = true;
input bool   BlockVeryLowVolatility = true;
input double VeryLowVolatilityAtrMultiplier = 0.85;
input double LowVolatilityAtrMultiplier = 1.20;
input double ExtraEntryScoreInLowVolatility = 6.0;

//--- متغیرهای هندل اندیکاتور
const long ExpertMagicNumber = 202607;

int rsiHandle;
int emaHandle;
int atrHandle;
CTrade trade;
double DayInitialEquity;
int LastDailyBaselinePackedDate = 0;
ulong TrailRiskTickets[];
double TrailRiskInitialPrice[];
ulong PartialClosedTickets[];
datetime LastProcessedBarTime = 0;
int LastEntryBarIndex = -10000;
int NewsEventMinutes[];
int ConsecutiveLossesCount = 0;
datetime LastLossRefreshDayStart = 0;
int DailyClosedTradesCount = 0;
double DailyNetProfitAmount = 0.0;
string SignalDebugMessage = "Signal: waiting";

int findTrailRiskIndex(const ulong ticket) {
    for(int idx = 0; idx < ArraySize(TrailRiskTickets); idx++) {
        if(TrailRiskTickets[idx] == ticket) {
            return idx;
        }
    }
    return -1;
}
int findPartialClosedIndex(const ulong ticket) {
    for(int idx = 0; idx < ArraySize(PartialClosedTickets); idx++) {
        if(PartialClosedTickets[idx] == ticket) {
            return idx;
        }
    }
    return -1;
}
bool hasPartialCloseDoneForTicket(const ulong ticket) {
    return findPartialClosedIndex(ticket) >= 0;
}
void markPartialCloseDoneForTicket(const ulong ticket) {
    if(hasPartialCloseDoneForTicket(ticket)) {
        return;
    }
    const int n = ArraySize(PartialClosedTickets);
    ArrayResize(PartialClosedTickets, n + 1);
    PartialClosedTickets[n] = ticket;
}

void setTrailInitialRiskForTicket(const ulong ticket, const double riskPrice) {
    const int existingIdx = findTrailRiskIndex(ticket);
    if(existingIdx >= 0) {
        TrailRiskInitialPrice[existingIdx] = riskPrice;
        return;
    }
    const int n = ArraySize(TrailRiskTickets);
    ArrayResize(TrailRiskTickets, n + 1);
    ArrayResize(TrailRiskInitialPrice, n + 1);
    TrailRiskTickets[n] = ticket;
    TrailRiskInitialPrice[n] = riskPrice;
}

double getTrailInitialRiskForTicket(const ulong ticket) {
    const int idx = findTrailRiskIndex(ticket);
    if(idx < 0) {
        return 0.0;
    }
    return TrailRiskInitialPrice[idx];
}

void pruneStaleTrailRiskEntries() {
    for(int idx = ArraySize(TrailRiskTickets) - 1; idx >= 0; idx--) {
        if(!PositionSelectByTicket(TrailRiskTickets[idx])) {
            const int last = ArraySize(TrailRiskTickets) - 1;
            if(idx != last) {
                TrailRiskTickets[idx] = TrailRiskTickets[last];
                TrailRiskInitialPrice[idx] = TrailRiskInitialPrice[last];
            }
            ArrayResize(TrailRiskTickets, last);
            ArrayResize(TrailRiskInitialPrice, last);
        }
    }
}
void pruneStalePartialCloseEntries() {
    for(int idx = ArraySize(PartialClosedTickets) - 1; idx >= 0; idx--) {
        if(!PositionSelectByTicket(PartialClosedTickets[idx])) {
            const int last = ArraySize(PartialClosedTickets) - 1;
            if(idx != last) {
                PartialClosedTickets[idx] = PartialClosedTickets[last];
            }
            ArrayResize(PartialClosedTickets, last);
        }
    }
}

void registerTrailRiskForNewestOurPosition() {
    ulong bestTicket = 0;
    datetime bestTime = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        const ulong t = PositionGetTicket(i);
        if(t == 0) {
            continue;
        }
        if(!PositionSelectByTicket(t)) {
            continue;
        }
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
            continue;
        }
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        const datetime tm = (datetime)PositionGetInteger(POSITION_TIME);
        if(tm >= bestTime) {
            bestTime = tm;
            bestTicket = t;
        }
    }
    if(bestTicket == 0) {
        return;
    }
    if(!PositionSelectByTicket(bestTicket)) {
        return;
    }
    const double open = PositionGetDouble(POSITION_PRICE_OPEN);
    const double slp = PositionGetDouble(POSITION_SL);
    const double risk = MathAbs(open - slp);
    if(risk < _Point) {
        return;
    }
    setTrailInitialRiskForTicket(bestTicket, risk);
}

bool hasReachedOneToOneForTrail(const long positionType, const double priceOpen,
                                const double priceCurrent, const double initialRiskPrice) {
    if(initialRiskPrice < _Point) {
        return false;
    }
    if(positionType == POSITION_TYPE_BUY) {
        return (priceCurrent - priceOpen) >= initialRiskPrice;
    }
    if(positionType == POSITION_TYPE_SELL) {
        return (priceOpen - priceCurrent) >= initialRiskPrice;
    }
    return false;
}
bool isNewBar() {
    const datetime currentBarTime = iTime(_Symbol, _Period, 0);
    if(currentBarTime == LastProcessedBarTime) {
        return false;
    }
    LastProcessedBarTime = currentBarTime;
    return true;
}
double getRsiValue(const int shift) {
    double buffer[];
    ArraySetAsSeries(buffer, true);
    if(CopyBuffer(rsiHandle, 0, shift, 1, buffer) < 1) {
        return 50.0;
    }
    return buffer[0];
}
double getEmaValue(const int shift) {
    double buffer[];
    ArraySetAsSeries(buffer, true);
    if(CopyBuffer(emaHandle, 0, shift, 1, buffer) < 1) {
        return 0.0;
    }
    return buffer[0];
}
double getAtrValue(const int shift) {
    double buffer[];
    ArraySetAsSeries(buffer, true);
    if(CopyBuffer(atrHandle, 0, shift, 1, buffer) < 1) {
        return 0.0;
    }
    return buffer[0];
}
bool hasOpenPositionForSymbolMagic() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        const ulong ticket = PositionGetTicket(i);
        if(ticket == 0) {
            continue;
        }
        if(!PositionSelectByTicket(ticket)) {
            continue;
        }
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
            continue;
        }
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        return true;
    }
    return false;
}
int getOpenPositionsCountForSymbolMagic() {
    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        const ulong ticket = PositionGetTicket(i);
        if(ticket == 0) {
            continue;
        }
        if(!PositionSelectByTicket(ticket)) {
            continue;
        }
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
            continue;
        }
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        count++;
    }
    return count;
}
bool hasAnyOpenPositionReachedOneToOne() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        const ulong ticket = PositionGetTicket(i);
        if(ticket == 0) {
            continue;
        }
        if(!PositionSelectByTicket(ticket)) {
            continue;
        }
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
            continue;
        }
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        const double priceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
        const double priceCurrent = PositionGetDouble(POSITION_PRICE_CURRENT);
        const long positionType = PositionGetInteger(POSITION_TYPE);
        const double initialRiskPrice = getTrailInitialRiskForTicket(ticket);
        if(hasReachedOneToOneForTrail(positionType, priceOpen, priceCurrent, initialRiskPrice)) {
            return true;
        }
    }
    return false;
}
bool canOpenNewPosition() {
    const int openCount = getOpenPositionsCountForSymbolMagic();
    if(openCount <= 0) {
        return true;
    }
    if(openCount >= MaxOpenPositions) {
        return false;
    }
    if(openCount == 1 && AllowSecondPositionAfterOneToOne) {
        return hasAnyOpenPositionReachedOneToOne();
    }
    return !AllowSecondPositionAfterOneToOne;
}
double calculateAtrScore(const double atr) {
    const double minAtrPrice = MinAtrPoints * _Point;
    if(minAtrPrice <= 0.0 || atr <= minAtrPrice) {
        return 0.0;
    }
    const double atrRatio = atr / minAtrPrice;
    if(atrRatio >= 2.0) {
        return ScoreWeightAtr;
    }
    return ScoreWeightAtr * (atrRatio - 1.0);
}
double calculateSpreadScore(const double spreadPoints) {
    if(MaxSpreadPoints <= 0 || spreadPoints >= MaxSpreadPoints) {
        return 0.0;
    }
    const double scoreRatio = 1.0 - (spreadPoints / MaxSpreadPoints);
    return ScoreWeightSpread * scoreRatio;
}
double calculateSmartMoneyScore(const bool hasSweep, const bool hasDisplacement, const bool hasFvg) {
    if(!UseSmartMoneyFilter) {
        return 0.0;
    }
    double score = 0.0;
    if(hasSweep) {
        score += ScoreWeightSmartMoney * 0.4;
    }
    if(hasDisplacement) {
        score += ScoreWeightSmartMoney * 0.4;
    }
    if(hasFvg) {
        score += ScoreWeightSmartMoney * 0.2;
    }
    return score;
}
double getCandleBodySize(const int shift) {
    return MathAbs(iClose(_Symbol, _Period, shift) - iOpen(_Symbol, _Period, shift));
}
bool hasBullishDisplacement(const double atr) {
    if(atr <= 0.0) {
        return false;
    }
    const double body = getCandleBodySize(1);
    const bool isBullishCandle = iClose(_Symbol, _Period, 1) > iOpen(_Symbol, _Period, 1);
    return isBullishCandle && body >= atr * MinDisplacementAtrRatio;
}
bool hasBearishDisplacement(const double atr) {
    if(atr <= 0.0) {
        return false;
    }
    const double body = getCandleBodySize(1);
    const bool isBearishCandle = iClose(_Symbol, _Period, 1) < iOpen(_Symbol, _Period, 1);
    return isBearishCandle && body >= atr * MinDisplacementAtrRatio;
}
bool hasBullishLiquiditySweep() {
    const int lowestBeforeSweepIdx = iLowest(_Symbol, _Period, MODE_LOW, RangeCandles, 3);
    const double lowestBeforeSweep = iLow(_Symbol, _Period, lowestBeforeSweepIdx);
    const double low2 = iLow(_Symbol, _Period, 2);
    const double close1 = iClose(_Symbol, _Period, 1);
    const double high2 = iHigh(_Symbol, _Period, 2);
    return low2 < lowestBeforeSweep && close1 > high2;
}
bool hasBearishLiquiditySweep() {
    const int highestBeforeSweepIdx = iHighest(_Symbol, _Period, MODE_HIGH, RangeCandles, 3);
    const double highestBeforeSweep = iHigh(_Symbol, _Period, highestBeforeSweepIdx);
    const double high2 = iHigh(_Symbol, _Period, 2);
    const double close1 = iClose(_Symbol, _Period, 1);
    const double low2 = iLow(_Symbol, _Period, 2);
    return high2 > highestBeforeSweep && close1 < low2;
}
bool hasBullishFairValueGap() {
    return iLow(_Symbol, _Period, 1) > iHigh(_Symbol, _Period, 3);
}
bool hasBearishFairValueGap() {
    return iHigh(_Symbol, _Period, 1) < iLow(_Symbol, _Period, 3);
}
double getEmaSlopePoints() {
    const double ema1 = getEmaValue(1);
    const double ema5 = getEmaValue(5);
    return (ema1 - ema5) / _Point;
}
bool isBuyTrendAligned(const double close1, const double ema1, const double emaSlopePoints) {
    return close1 > ema1 && emaSlopePoints >= MinEmaSlopePoints;
}
bool isSellTrendAligned(const double close1, const double ema1, const double emaSlopePoints) {
    return close1 < ema1 && emaSlopePoints <= -MinEmaSlopePoints;
}
bool hasBullishMss() {
    const double close1 = iClose(_Symbol, _Period, 1);
    const int lookbackBars = MathMax(4, MssLookbackBars);
    const int highestIdx = iHighest(_Symbol, _Period, MODE_HIGH, lookbackBars, 2);
    const double structureHigh = iHigh(_Symbol, _Period, highestIdx);
    return close1 > structureHigh;
}
bool hasBearishMss() {
    const double close1 = iClose(_Symbol, _Period, 1);
    const int lookbackBars = MathMax(4, MssLookbackBars);
    const int lowestIdx = iLowest(_Symbol, _Period, MODE_LOW, lookbackBars, 2);
    const double structureLow = iLow(_Symbol, _Period, lowestIdx);
    return close1 < structureLow;
}
bool passesSmartMoneyHardRules(const bool isBuy, const bool hasSweep, const bool hasFvg) {
    if(!UseSmartMoneyFilter) {
        return true;
    }
    if(RequireLiquiditySweep && !hasSweep) {
        return false;
    }
    if(RequireFairValueGap && !hasFvg) {
        return false;
    }
    return true;
}
double calculateBuyReversalScore(const double close1, const double ema1, const double rsi1, const double atr,
                                 const double spreadPoints, const bool hasSweep, const bool hasMss, const bool hasFvg) {
    if(!UseSmcReversalMode || !hasSweep) {
        return 0.0;
    }
    if(RequireMssForReversal && !hasMss) {
        return 0.0;
    }
    const double emaDistance = MathAbs(close1 - ema1);
    if(atr > 0.0 && emaDistance > atr * ReversalMaxEmaDistanceAtr) {
        return 0.0;
    }
    double score = ScoreWeightReversal;
    if(hasMss) {
        score += ScoreWeightReversal * 0.35;
    }
    if(close1 > ema1) {
        score += ScoreWeightTrend * 0.5;
    }
    if(rsi1 >= 35.0 && rsi1 <= 55.0) {
        score += ScoreWeightRsi * 0.7;
    }
    score += calculateAtrScore(atr);
    score += calculateSpreadScore(spreadPoints);
    score += calculateSmartMoneyScore(hasSweep, hasMss, hasFvg);
    return score;
}
double calculateSellReversalScore(const double close1, const double ema1, const double rsi1, const double atr,
                                  const double spreadPoints, const bool hasSweep, const bool hasMss, const bool hasFvg) {
    if(!UseSmcReversalMode || !hasSweep) {
        return 0.0;
    }
    if(RequireMssForReversal && !hasMss) {
        return 0.0;
    }
    const double emaDistance = MathAbs(close1 - ema1);
    if(atr > 0.0 && emaDistance > atr * ReversalMaxEmaDistanceAtr) {
        return 0.0;
    }
    double score = ScoreWeightReversal;
    if(hasMss) {
        score += ScoreWeightReversal * 0.35;
    }
    if(close1 < ema1) {
        score += ScoreWeightTrend * 0.5;
    }
    if(rsi1 <= 65.0 && rsi1 >= 45.0) {
        score += ScoreWeightRsi * 0.7;
    }
    score += calculateAtrScore(atr);
    score += calculateSpreadScore(spreadPoints);
    score += calculateSmartMoneyScore(hasSweep, hasMss, hasFvg);
    return score;
}
double calculateBuyEntryScore(const bool isBreakoutBuy, const double close1, const double rangeHigh,
                              const double rsi1, const double ema1, const double atr, const double spreadPoints,
                              const bool hasSweep, const bool hasDisplacement, const bool hasFvg) {
    if(!isBreakoutBuy) {
        return 0.0;
    }
    double score = 0.0;
    score += ScoreWeightBreakout;
    if(close1 > ema1) {
        score += ScoreWeightTrend;
    }
    if(rsi1 >= 50.0 && rsi1 <= 70.0) {
        score += ScoreWeightRsi;
    }
    if(isBreakoutBuy && rangeHigh > 0.0) {
        const double breakoutStrength = (close1 - rangeHigh) / _Point;
        if(breakoutStrength > BreakoutBufferPoints * 1.5) {
            score += ScoreWeightBreakout * 0.2;
        }
    }
    score += calculateAtrScore(atr);
    score += calculateSpreadScore(spreadPoints);
    score += calculateSmartMoneyScore(hasSweep, hasDisplacement, hasFvg);
    return score;
}
double calculateSellEntryScore(const bool isBreakoutSell, const double close1, const double rangeLow,
                               const double rsi1, const double ema1, const double atr, const double spreadPoints,
                               const bool hasSweep, const bool hasDisplacement, const bool hasFvg) {
    if(!isBreakoutSell) {
        return 0.0;
    }
    double score = 0.0;
    score += ScoreWeightBreakout;
    if(close1 < ema1) {
        score += ScoreWeightTrend;
    }
    if(rsi1 <= 50.0 && rsi1 >= 30.0) {
        score += ScoreWeightRsi;
    }
    if(isBreakoutSell && rangeLow > 0.0) {
        const double breakoutStrength = (rangeLow - close1) / _Point;
        if(breakoutStrength > BreakoutBufferPoints * 1.5) {
            score += ScoreWeightBreakout * 0.2;
        }
    }
    score += calculateAtrScore(atr);
    score += calculateSpreadScore(spreadPoints);
    score += calculateSmartMoneyScore(hasSweep, hasDisplacement, hasFvg);
    return score;
}
bool isHourInsideSession(const int hour, const int startHour, const int endHour) {
    if(startHour == endHour) {
        return true;
    }
    if(startHour < endHour) {
        return hour >= startHour && hour < endHour;
    }
    return hour >= startHour || hour < endHour;
}
bool isInsideDeadMarketHours() {
    if(!UseDeadMarketHoursFilter) {
        return false;
    }
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    return isHourInsideSession(serverDate.hour, DeadMarketStartHour, DeadMarketEndHour);
}
bool isInsideTradingSession() {
    if(!UseSessionFilter) {
        return true;
    }
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    if(serverDate.day_of_week == 0 || serverDate.day_of_week == 6) {
        return false;
    }
    const bool isInsideLondon = isHourInsideSession(serverDate.hour, LondonSessionStartHour, LondonSessionEndHour);
    const bool isInsideNewYork = isHourInsideSession(serverDate.hour, NewYorkSessionStartHour, NewYorkSessionEndHour);
    return isInsideLondon || isInsideNewYork;
}
bool isAllowedTradingDay() {
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    if(serverDate.day_of_week == 1) {
        return TradeOnMonday;
    }
    if(serverDate.day_of_week == 2) {
        return TradeOnTuesday;
    }
    if(serverDate.day_of_week == 3) {
        return TradeOnWednesday;
    }
    if(serverDate.day_of_week == 4) {
        return TradeOnThursday;
    }
    if(serverDate.day_of_week == 5) {
        return TradeOnFriday;
    }
    return false;
}
void parseNewsTimeFilter() {
    ArrayResize(NewsEventMinutes, 0);
    if(!UseNewsTimeFilter || StringLen(HighImpactNewsTimes) == 0) {
        return;
    }
    string events[];
    const int eventCount = StringSplit(HighImpactNewsTimes, ',', events);
    if(eventCount <= 0) {
        return;
    }
    for(int i = 0; i < eventCount; i++) {
        string eventText = events[i];
        StringTrimLeft(eventText);
        StringTrimRight(eventText);
        string parts[];
        const int partCount = StringSplit(eventText, ':', parts);
        if(partCount != 2) {
            continue;
        }
        const int hour = (int)StringToInteger(parts[0]);
        const int minute = (int)StringToInteger(parts[1]);
        if(hour < 0 || hour > 23 || minute < 0 || minute > 59) {
            continue;
        }
        const int n = ArraySize(NewsEventMinutes);
        ArrayResize(NewsEventMinutes, n + 1);
        NewsEventMinutes[n] = hour * 60 + minute;
    }
}
bool isInsideNewsBlockWindow() {
    if(!UseNewsTimeFilter || ArraySize(NewsEventMinutes) == 0) {
        return false;
    }
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    const int currentMinuteOfDay = serverDate.hour * 60 + serverDate.min;
    for(int i = 0; i < ArraySize(NewsEventMinutes); i++) {
        const int eventMinute = NewsEventMinutes[i];
        int minutesFromEvent = currentMinuteOfDay - eventMinute;
        if(minutesFromEvent > 720) {
            minutesFromEvent -= 1440;
        }
        else if(minutesFromEvent < -720) {
            minutesFromEvent += 1440;
        }
        if(minutesFromEvent >= -NewsBlockMinutesBefore && minutesFromEvent <= NewsBlockMinutesAfter) {
            return true;
        }
    }
    return false;
}
datetime getServerDayStartTime() {
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    serverDate.hour = 0;
    serverDate.min = 0;
    serverDate.sec = 0;
    return StructToTime(serverDate);
}
void refreshConsecutiveLossesCount() {
    const datetime dayStart = getServerDayStartTime();
    if(dayStart != LastLossRefreshDayStart) {
        LastLossRefreshDayStart = dayStart;
    }
    if(!HistorySelect(dayStart, TimeTradeServer())) {
        return;
    }
    ConsecutiveLossesCount = 0;
    const int dealsCount = HistoryDealsTotal();
    for(int i = dealsCount - 1; i >= 0; i--) {
        const ulong dealTicket = HistoryDealGetTicket(i);
        if(dealTicket == 0) {
            continue;
        }
        if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != _Symbol) {
            continue;
        }
        if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT) {
            continue;
        }
        const double netProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT)
                               + HistoryDealGetDouble(dealTicket, DEAL_SWAP)
                               + HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
        if(netProfit < 0.0) {
            ConsecutiveLossesCount++;
            continue;
        }
        if(netProfit > 0.0) {
            break;
        }
    }
}
bool hasReachedConsecutiveLossLimit() {
    if(MaxConsecutiveLosses <= 0) {
        return false;
    }
    return ConsecutiveLossesCount >= MaxConsecutiveLosses;
}
void refreshDailyTradeStats() {
    const datetime dayStart = getServerDayStartTime();
    if(!HistorySelect(dayStart, TimeTradeServer())) {
        DailyClosedTradesCount = 0;
        DailyNetProfitAmount = 0.0;
        return;
    }
    DailyClosedTradesCount = 0;
    DailyNetProfitAmount = 0.0;
    const int dealsCount = HistoryDealsTotal();
    for(int i = dealsCount - 1; i >= 0; i--) {
        const ulong dealTicket = HistoryDealGetTicket(i);
        if(dealTicket == 0) {
            continue;
        }
        if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != _Symbol) {
            continue;
        }
        if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT) {
            continue;
        }
        DailyClosedTradesCount++;
        DailyNetProfitAmount += HistoryDealGetDouble(dealTicket, DEAL_PROFIT)
                             + HistoryDealGetDouble(dealTicket, DEAL_SWAP)
                             + HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
    }
}
bool hasReachedDailyTradesLimit() {
    if(MaxTradesPerDay <= 0) {
        return false;
    }
    return DailyClosedTradesCount >= MaxTradesPerDay;
}
bool hasReachedDailyProfitTarget() {
    if(MaxDailyProfitPct <= 0.0 || DayInitialEquity <= 0.0) {
        return false;
    }
    const double targetAmount = DayInitialEquity * MaxDailyProfitPct / 100.0;
    return DailyNetProfitAmount >= targetAmount;
}
double getDynamicMinimumEntryScore() {
    if(!EnableDynamicAntiLossMode) {
        return MinimumEntryScore;
    }
    if(ConsecutiveLossesCount <= 0) {
        return MinimumEntryScore;
    }
    const double scoreBoost = MathMin(MaxDynamicEntryScoreBoost, ConsecutiveLossesCount * EntryScorePenaltyPerLoss);
    return MinimumEntryScore + scoreBoost;
}
double getAdaptiveVolatilityEntryScoreBoost(const double atr) {
    if(!EnableAdaptiveVolatilityFilter) {
        return 0.0;
    }
    const double minimumAtrPrice = MinAtrPoints * _Point;
    if(minimumAtrPrice <= 0.0) {
        return 0.0;
    }
    if(atr >= minimumAtrPrice * LowVolatilityAtrMultiplier) {
        return 0.0;
    }
    const double ratio = 1.0 - (atr / (minimumAtrPrice * LowVolatilityAtrMultiplier));
    return MathMax(0.0, ExtraEntryScoreInLowVolatility * ratio);
}
double getDynamicLotScaleFactor() {
    if(!EnableDynamicLotScalingAfterLoss) {
        return 1.0;
    }
    if(ConsecutiveLossesCount <= 0) {
        return 1.0;
    }
    const double rawScale = 1.0 - (ConsecutiveLossesCount * LotScalePerLoss);
    return MathMax(MinLotScaleFactor, rawScale);
}
void setSignalDebugMessage(const string message) {
    SignalDebugMessage = message;
}

/**
 * Resets the daily equity baseline on the first tick of a new server trading day.
 * Without this, DayInitialEquity stays fixed from attach time and the daily loss
 * guard can block new entries indefinitely after one bad day.
 */
void resetDailyEquityBaselineIfNewDay() {
    MqlDateTime serverDate;
    TimeToStruct(TimeTradeServer(), serverDate);
    const int packedDate = serverDate.year * 10000 + serverDate.mon * 100 + serverDate.day;
    if(packedDate == LastDailyBaselinePackedDate) {
        return;
    }
    LastDailyBaselinePackedDate = packedDate;
    DayInitialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
}

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit() {
    DayInitialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    MqlDateTime initDate;
    TimeToStruct(TimeTradeServer(), initDate);
    LastDailyBaselinePackedDate = initDate.year * 10000 + initDate.mon * 100 + initDate.day;
    trade.SetExpertMagicNumber(ExpertMagicNumber);
    
    // تعریف صحیح هندل RSI در MQL5
    rsiHandle = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
    emaHandle = iMA(_Symbol, _Period, EmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
    atrHandle = iATR(_Symbol, _Period, AtrPeriod);
    if(rsiHandle == INVALID_HANDLE || emaHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE) return(INIT_FAILED);
    parseNewsTimeFilter();
    CreateUI();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| توابع کمکی برای دریافت مقدار RSI                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ایجاد و آپدیت پنل                                                 |
//+------------------------------------------------------------------+
void CreateUI() {
    string labels[] = {"lbl_Profit", "lbl_DD", "lbl_Equity"};
    for(int i=0; i<3; i++) {
        ObjectCreate(0, labels[i], OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, labels[i], OBJPROP_XDISTANCE, 25);
        ObjectSetInteger(0, labels[i], OBJPROP_YDISTANCE, 35 + (i*25));
        ObjectSetInteger(0, labels[i], OBJPROP_COLOR, PanelColor);
        ObjectSetString(0, labels[i], OBJPROP_TEXT, 0, "Wait...");
    }
    if(EnableSignalDebugPanel) {
        ObjectCreate(0, "lbl_SignalDebug", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "lbl_SignalDebug", OBJPROP_XDISTANCE, 25);
        ObjectSetInteger(0, "lbl_SignalDebug", OBJPROP_YDISTANCE, 35 + (3 * 25));
        ObjectSetInteger(0, "lbl_SignalDebug", OBJPROP_COLOR, PanelColor);
        ObjectSetString(0, "lbl_SignalDebug", OBJPROP_TEXT, 0, "Signal: waiting");
    }
}

void UpdateUI() {
    double curEq = AccountInfoDouble(ACCOUNT_EQUITY);
    double pnl = curEq - DayInitialEquity;
    double dd = (DayInitialEquity > curEq) ? (DayInitialEquity - curEq) / DayInitialEquity * 100.0 : 0;
    ObjectSetString(0, "lbl_Profit", OBJPROP_TEXT, 0, "Daily PnL: $" + DoubleToString(pnl, 2));
    ObjectSetString(0, "lbl_DD", OBJPROP_TEXT, 0, "Max DD: " + DoubleToString(dd, 2) + "%");
    ObjectSetString(0, "lbl_Equity", OBJPROP_TEXT, 0, "Equity: $" + DoubleToString(curEq, 2));
    if(EnableSignalDebugPanel) {
        ObjectSetString(0, "lbl_SignalDebug", OBJPROP_TEXT, 0, SignalDebugMessage);
    }
}

//+------------------------------------------------------------------+
//| OnTick اصلی                                                      |
//+------------------------------------------------------------------+
void OnTick() {
    resetDailyEquityBaselineIfNewDay();
    refreshConsecutiveLossesCount();
    refreshDailyTradeStats();
    ManagePositions(); // مدیریت هوشمند خروج
    const double curEq = AccountInfoDouble(ACCOUNT_EQUITY);
    if(DayInitialEquity <= 0.0) {
        setSignalDebugMessage("Blocked: invalid daily equity baseline");
        UpdateUI();
        return;
    }
    if((DayInitialEquity - curEq) / DayInitialEquity * 100.0 >= MaxDailyLossPct) {
        setSignalDebugMessage("Blocked: max daily loss reached");
        UpdateUI();
        return;
    }
    if(hasReachedDailyProfitTarget()) {
        setSignalDebugMessage("Blocked: daily profit target reached");
        UpdateUI();
        return;
    }
    if(hasReachedConsecutiveLossLimit()) {
        setSignalDebugMessage("Blocked: consecutive loss limit reached");
        UpdateUI();
        return;
    }
    if(!isNewBar()) {
        setSignalDebugMessage("Waiting: next bar");
        UpdateUI();
        return;
    }
    if(!isAllowedTradingDay()) {
        setSignalDebugMessage("Blocked: trading day disabled");
        UpdateUI();
        return;
    }
    if(!isInsideTradingSession()) {
        setSignalDebugMessage("Blocked: outside trading session");
        UpdateUI();
        return;
    }
    if(isInsideDeadMarketHours()) {
        setSignalDebugMessage("Blocked: dead market hours");
        UpdateUI();
        return;
    }
    if(isInsideNewsBlockWindow()) {
        setSignalDebugMessage("Blocked: news time window");
        UpdateUI();
        return;
    }
    if(hasReachedDailyTradesLimit()) {
        setSignalDebugMessage("Blocked: daily trades limit reached");
        UpdateUI();
        return;
    }
    if(!canOpenNewPosition()) {
        setSignalDebugMessage("Blocked: open position rules");
        UpdateUI();
        return;
    }
    const int currentBarIndex = iBars(_Symbol, _Period);
    if(currentBarIndex - LastEntryBarIndex < MinBarsBetweenEntries) {
        setSignalDebugMessage("Blocked: min bars between entries");
        UpdateUI();
        return;
    }
    const double spreadPoints = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    if(spreadPoints > MaxSpreadPoints) {
        setSignalDebugMessage("Blocked: spread too high");
        UpdateUI();
        return;
    }
    const double atr = getAtrValue(1);
    if(atr <= 0.0 || atr < MinAtrPoints * _Point) {
        setSignalDebugMessage("Blocked: ATR too low");
        UpdateUI();
        return;
    }
    if(EnableAdaptiveVolatilityFilter && BlockVeryLowVolatility && atr < MinAtrPoints * _Point * VeryLowVolatilityAtrMultiplier) {
        setSignalDebugMessage("Blocked: very low volatility regime");
        UpdateUI();
        return;
    }
    const int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, RangeCandles, 2);
    const int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, RangeCandles, 2);
    const double rangeHigh = iHigh(_Symbol, _Period, highestIndex);
    const double rangeLow = iLow(_Symbol, _Period, lowestIndex);
    const double close1 = iClose(_Symbol, _Period, 1);
    const double rsi1 = getRsiValue(1);
    const double ema1 = getEmaValue(1);
    const double emaSlopePoints = getEmaSlopePoints();
    const double breakoutBuffer = BreakoutBufferPoints * _Point;
    const double stopDistance = MathMax(atr * 1.2, MinAtrPoints * _Point);
    const bool buyTrendAligned = isBuyTrendAligned(close1, ema1, emaSlopePoints);
    const bool sellTrendAligned = isSellTrendAligned(close1, ema1, emaSlopePoints);
    const double emaDistance = MathAbs(close1 - ema1);
    const bool hasBreakoutDistance = (atr > 0.0 && emaDistance >= atr * BreakoutMinEmaDistanceAtr);
    const bool isBreakoutBuy = close1 > rangeHigh + breakoutBuffer && rsi1 < 72.0 && buyTrendAligned && hasBreakoutDistance;
    const bool isBreakoutSell = close1 < rangeLow - breakoutBuffer && rsi1 > 28.0 && sellTrendAligned && hasBreakoutDistance;
    const bool buySweep = hasBullishLiquiditySweep();
    const bool sellSweep = hasBearishLiquiditySweep();
    const bool buyDisplacement = hasBullishDisplacement(atr);
    const bool sellDisplacement = hasBearishDisplacement(atr);
    const bool buyFvg = hasBullishFairValueGap();
    const bool sellFvg = hasBearishFairValueGap();
    const bool buyMss = hasBullishMss();
    const bool sellMss = hasBearishMss();
    const double buyBreakoutScore = calculateBuyEntryScore(isBreakoutBuy, close1, rangeHigh, rsi1, ema1, atr, spreadPoints, buySweep, buyDisplacement, buyFvg);
    const double sellBreakoutScore = calculateSellEntryScore(isBreakoutSell, close1, rangeLow, rsi1, ema1, atr, spreadPoints, sellSweep, sellDisplacement, sellFvg);
    const double buyReversalScore = calculateBuyReversalScore(close1, ema1, rsi1, atr, spreadPoints, buySweep, buyMss, buyFvg);
    const double sellReversalScore = calculateSellReversalScore(close1, ema1, rsi1, atr, spreadPoints, sellSweep, sellMss, sellFvg);
    const double adaptiveScoreBoost = getAdaptiveVolatilityEntryScoreBoost(atr);
    const double dynamicMinimumEntryScore = getDynamicMinimumEntryScore() + adaptiveScoreBoost;
    int bestSignal = 0;
    double bestScore = -1.0;
    double bestRiskReward = RiskReward;
    if(isBreakoutBuy
       && (!RequireDisplacementForBreakout || buyDisplacement)
       && passesSmartMoneyHardRules(true, buySweep, buyFvg)
       && buyBreakoutScore >= dynamicMinimumEntryScore) {
        bestSignal = 1;
        bestScore = buyBreakoutScore;
        bestRiskReward = RiskReward;
    }
    if(isBreakoutSell
       && (!RequireDisplacementForBreakout || sellDisplacement)
       && passesSmartMoneyHardRules(false, sellSweep, sellFvg)
       && sellBreakoutScore >= dynamicMinimumEntryScore
       && sellBreakoutScore > bestScore) {
        bestSignal = -1;
        bestScore = sellBreakoutScore;
        bestRiskReward = RiskReward;
    }
    if(UseSmcReversalMode && buyReversalScore >= dynamicMinimumEntryScore && buyReversalScore > bestScore) {
        bestSignal = 2;
        bestScore = buyReversalScore;
        bestRiskReward = ReversalRiskReward;
    }
    if(UseSmcReversalMode && sellReversalScore >= dynamicMinimumEntryScore && sellReversalScore > bestScore) {
        bestSignal = -2;
        bestScore = sellReversalScore;
        bestRiskReward = ReversalRiskReward;
    }
    if(bestSignal == 0) {
        if(!EnableFallbackEntryMode) {
            setSignalDebugMessage("Blocked: no valid signal");
            UpdateUI();
            return;
        }
        const bool fallbackBuy = close1 > rangeHigh + breakoutBuffer * 0.5 && close1 > ema1 && rsi1 < 74.0;
        const bool fallbackSell = close1 < rangeLow - breakoutBuffer * 0.5 && close1 < ema1 && rsi1 > 26.0;
        const double fallbackRiskReward = MathMax(1.2, RiskReward - 0.2);
        if(fallbackBuy && !fallbackSell) {
            const double sl = NormalizeDouble(close1 - stopDistance, _Digits);
            const double tp = NormalizeDouble(close1 + stopDistance * fallbackRiskReward, _Digits);
            if(Execute(ORDER_TYPE_BUY, close1, sl, tp)) {
                LastEntryBarIndex = currentBarIndex;
                setSignalDebugMessage("Entry: BUY fallback");
                UpdateUI();
                return;
            }
        }
        if(fallbackSell && !fallbackBuy) {
            const double sl = NormalizeDouble(close1 + stopDistance, _Digits);
            const double tp = NormalizeDouble(close1 - stopDistance * fallbackRiskReward, _Digits);
            if(Execute(ORDER_TYPE_SELL, close1, sl, tp)) {
                LastEntryBarIndex = currentBarIndex;
                setSignalDebugMessage("Entry: SELL fallback");
                UpdateUI();
                return;
            }
        }
        setSignalDebugMessage("Blocked: fallback not triggered");
        UpdateUI();
        return;
    }
    const double validSellBreakoutScore = isBreakoutSell ? sellBreakoutScore : 0.0;
    const double validSellReversalScore = (UseSmcReversalMode && sellReversalScore >= dynamicMinimumEntryScore) ? sellReversalScore : 0.0;
    const double validBuyBreakoutScore = isBreakoutBuy ? buyBreakoutScore : 0.0;
    const double validBuyReversalScore = (UseSmcReversalMode && buyReversalScore >= dynamicMinimumEntryScore) ? buyReversalScore : 0.0;
    const double bestOppositeScore = (bestSignal > 0)
        ? MathMax(validSellBreakoutScore, validSellReversalScore)
        : MathMax(validBuyBreakoutScore, validBuyReversalScore);
    if(bestOppositeScore >= dynamicMinimumEntryScore && (bestScore - bestOppositeScore) < MinimumScoreGap) {
        setSignalDebugMessage("Blocked: score gap too small");
        UpdateUI();
        return;
    }
    if(bestScore >= dynamicMinimumEntryScore + StrongSignalScoreBuffer) {
        bestRiskReward += StrongSignalRiskRewardBoost;
    }
    if(bestSignal > 0) {
        const double sl = NormalizeDouble(close1 - stopDistance, _Digits);
        const double tp = NormalizeDouble(close1 + stopDistance * bestRiskReward, _Digits);
        if(Execute(ORDER_TYPE_BUY, close1, sl, tp)) {
            LastEntryBarIndex = currentBarIndex;
            setSignalDebugMessage("Entry: BUY score " + DoubleToString(bestScore, 1));
            UpdateUI();
            return;
        }
        setSignalDebugMessage("Blocked: BUY execution failed");
        UpdateUI();
        return;
    }
    const double sl = NormalizeDouble(close1 + stopDistance, _Digits);
    const double tp = NormalizeDouble(close1 - stopDistance * bestRiskReward, _Digits);
    if(Execute(ORDER_TYPE_SELL, close1, sl, tp)) {
        LastEntryBarIndex = currentBarIndex;
        setSignalDebugMessage("Entry: SELL score " + DoubleToString(bestScore, 1));
        UpdateUI();
        return;
    }
    setSignalDebugMessage("Blocked: SELL execution failed");
    UpdateUI();
}

//+------------------------------------------------------------------+
//| مدیریت معاملات باز (Trailing & Breakeven)                          |
//+------------------------------------------------------------------+
void ManagePositions() {
    pruneStaleTrailRiskEntries();
    pruneStalePartialCloseEntries();
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        const ulong ticket = PositionGetTicket(i);
        if(ticket == 0) {
            continue;
        }
        if(!PositionSelectByTicket(ticket)) {
            continue;
        }
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
            continue;
        }
        if(PositionGetInteger(POSITION_MAGIC) != ExpertMagicNumber) {
            continue;
        }
        const double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
        const double price_current = PositionGetDouble(POSITION_PRICE_CURRENT);
        double sl = PositionGetDouble(POSITION_SL);
        const double tp = PositionGetDouble(POSITION_TP);
        double volume = PositionGetDouble(POSITION_VOLUME);
        const long posType = PositionGetInteger(POSITION_TYPE);
        const double initialRiskPrice = getTrailInitialRiskForTicket(ticket);
        const bool canUseTrailing = hasReachedOneToOneForTrail(posType, price_open, price_current, initialRiskPrice);
        if(EnablePartialTakeProfit && canUseTrailing && !hasPartialCloseDoneForTicket(ticket)) {
            const double minVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            const double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            double closeVolume = volume * PartialClosePercentAtOneToOne;
            if(lotStep > 0.0) {
                closeVolume = MathFloor(closeVolume / lotStep) * lotStep;
                closeVolume = NormalizeDouble(closeVolume, 2);
            }
            if(closeVolume >= minVolume && (volume - closeVolume) >= minVolume) {
                if(trade.PositionClosePartial(ticket, closeVolume)) {
                    markPartialCloseDoneForTicket(ticket);
                    if(!PositionSelectByTicket(ticket)) {
                        continue;
                    }
                    sl = PositionGetDouble(POSITION_SL);
                    volume = PositionGetDouble(POSITION_VOLUME);
                }
            }
            else {
                markPartialCloseDoneForTicket(ticket);
            }
        }
        if(posType == POSITION_TYPE_BUY) {
            if(price_current - price_open > BreakevenProfit * _Point && sl < price_open) {
                trade.PositionModify(ticket, price_open + (5 * _Point), tp);
            }
            if(!PositionSelectByTicket(ticket)) {
                continue;
            }
            sl = PositionGetDouble(POSITION_SL);
            if(canUseTrailing && price_current - sl > TrailingStop * _Point) {
                const double newSL = NormalizeDouble(price_current - TrailingStop * _Point, _Digits);
                if(newSL > sl) {
                    trade.PositionModify(ticket, newSL, tp);
                }
            }
        }
        else {
            if(price_open - price_current > BreakevenProfit * _Point && (sl > price_open || sl == 0)) {
                trade.PositionModify(ticket, price_open - (5 * _Point), tp);
            }
            if(!PositionSelectByTicket(ticket)) {
                continue;
            }
            sl = PositionGetDouble(POSITION_SL);
            if(canUseTrailing && (sl - price_current > TrailingStop * _Point || sl == 0)) {
                const double newSL = NormalizeDouble(price_current + TrailingStop * _Point, _Digits);
                if(sl == 0 || newSL < sl) {
                    trade.PositionModify(ticket, newSL, tp);
                }
            }
        }
    }
}

bool Execute(ENUM_ORDER_TYPE type, double price, double sl, double tp) {
    const double lotScale = getDynamicLotScaleFactor();
    double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100.0 * lotScale;
    double tickVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double points = MathAbs(price - sl) / _Point;
    if(points <= 0 || tickVal <= 0.0) return false;
    double lot = NormalizeDouble(riskMoney / (points * tickVal), 2);
    double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    if(lot < minL) lot = minL;
    if(lot > maxL) lot = maxL;
    if(lotStep > 0.0) {
        lot = MathFloor(lot / lotStep) * lotStep;
        lot = NormalizeDouble(lot, 2);
    }
    bool opened = false;
    if(type == ORDER_TYPE_BUY) {
        opened = trade.Buy(lot, _Symbol, price, sl, tp);
    }
    else {
        opened = trade.Sell(lot, _Symbol, price, sl, tp);
    }
    if(opened) {
        registerTrailRiskForNewestOurPosition();
    }
    return opened;
}

void OnDeinit(const int reason) {
    IndicatorRelease(rsiHandle);
    IndicatorRelease(emaHandle);
    IndicatorRelease(atrHandle);
    ObjectsDeleteAll(0, "lbl_");
}