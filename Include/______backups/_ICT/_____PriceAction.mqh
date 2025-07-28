//+------------------------------------------------------------------+
//|                                                   OrderBlock.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


//// TEST
//double get_ob_price()
//  {
//   double high_ = iHigh(_Symbol, PERIOD_CURRENT, 0);
//   return high_;
//  }

// TODO: UTILITY FOR ANALYSE TIMEFRAME (H4 ?)

// FVG                  - NO CONFIRM
// PRICE ACTION         - CONFIRMED

// BULLISH FVG          - NO CONFIRM
bool has_bullish_fvg(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {  
   double high2Ago = iHigh(_Symbol, tf, 2 + shift); 
   double lowNow = iLow(_Symbol, tf, 0 + shift); 
   datetime time_ = iTime(_Symbol,tf, 0 + shift);
   time = time_;
   return (high2Ago < lowNow);
  }

// TODO
//double has_bullish_sweep_down()
//  {
//
//  }

// Pattern BULLISH ENGULFING
bool has_bullish_engulfing(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1 + shift);
   double close2 = iClose(_Symbol,tf,2 + shift);
   double open1 = iOpen(_Symbol,tf,1 + shift);
   double open2 = iOpen(_Symbol,tf,2 + shift);
   datetime time_ = iTime(_Symbol,tf, 2 + shift);
   time = time_;
   return      open1 > close1       && close1 > open1    && close1 >= open2      && close2 >= open1      && close1 - open1 > open2 - close2;
  }

//double has_3_white_soldiers()
//  {
//
//  }

//HAS BULLISH HARAMI
bool has_bullish_harami(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1 + shift);
   double close2 = iClose(_Symbol,tf,2 + shift);
   double open1 = iOpen(_Symbol,tf,1 + shift);
   double open2 = iOpen(_Symbol,tf,2 + shift);
   datetime time_ = iTime(_Symbol,tf, 2 + shift);
   time = time_;
   return open2 > close2 && close1 > open1 && close1 <= open2 && close2 <= open1 && close1 - open1 < open2 - close2;
  }






// BEARISH FVG ============================================================================{

// HAS BEARISH FVG
bool has_bearish_fvg(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {  
   double low2Ago = iLow(_Symbol, tf, 2 + shift);
   double highNow = iHigh(_Symbol, tf, 0 + shift);
   datetime time_ = iTime(_Symbol,tf, 2 + shift);
   time = time_;
   return (low2Ago > highNow);
  }


//bool has_3_black_crows()
//  {
//
//  }

// HAS BEARISH HARAMI
bool has_bearish_harami(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1 + shift);
   double close2 = iClose(_Symbol,tf,2 + shift);
   double open1 = iOpen(_Symbol,tf,1 + shift);
   double open2 = iOpen(_Symbol,tf,2 + shift);
   datetime time_ = iTime(_Symbol,tf, 2 + shift);
   time = time_;
   return close2 > open2 && open1 > close1 && open1 <= close2 && open2 <= close1 && open1 - close1 < close2 - open2;
  }

// HAS BEARISH ENGULFING
bool has_bearish_engulfing(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1 + shift);
   double close2 = iClose(_Symbol,tf,2 + shift);
   double open1 = iOpen(_Symbol,tf,1 + shift);
   double open2 = iOpen(_Symbol,tf,2 + shift);
datetime time_ = iTime(_Symbol,tf, 2 + shift);
   time = time_;
   
   return close2 > open2 && open1 > close1 && open1 >= close2 && open2 >= close1 && open1 - close1 > close2 - open2;
  }




//// UTILITIES
//
//// Draw FVG to chart
//void DrawFVGMarker(int shift, bool bullish)
//  {
//   color markerColor = bullish ? clrYellow : clrBlue;
//   string markerName = bullish ? "BullishFVG_" : "BearishFVG_";
//
//   int total_object = ObjectsTotal(0, 0, -1) + 1;
//   markerName += IntegerToString(total_object);
//
//   double startPrice = bullish == false ? iLow(_Symbol, PERIOD_CURRENT, 2 + shift) : iHigh(_Symbol, PERIOD_CURRENT, 2 + shift);
//   double endPrice = bullish == false ? iHigh(_Symbol, PERIOD_CURRENT, 0 + shift) : iLow(_Symbol, PERIOD_CURRENT, 0 + shift);
//
//   ObjectCreate(0, markerName, OBJ_RECTANGLE, 0,
//                iTime(_Symbol, PERIOD_CURRENT, 2 + shift),
//                startPrice,
//                iTime(_Symbol, PERIOD_CURRENT, 0 + shift),
//                endPrice);
//
//   ObjectSetInteger(0, markerName, OBJPROP_COLOR, markerColor);
//   ObjectSetInteger(0, markerName, OBJPROP_WIDTH, 1);
//  }