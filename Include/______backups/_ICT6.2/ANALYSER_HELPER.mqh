//+------------------------------------------------------------------+
//|                                              ANALYSER_HELPER.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include "TYPES.mqh"
// #include <HELPER.mqh>

// FVG                  - NO CONFIRM
// PRICE ACTION         - CONFIRMED

// ANALYSER TIMEFRAME - CHECK FVG
bool H4_check_fvg(ANALYSER_FVG_RSI &analyser_fvg_, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4) {
   if (H4_has_bullish_fvg(analyser_fvg_,0,tf) == true) {
      // Print("OK - BULLISH");
      analyser_fvg_.last_fvg_type_ = FVG_NONE;
      analyser_fvg_.last_fvg_time_ = 0;
      return true;
   } else if (H4_has_bearish_fvg(analyser_fvg_,0,tf) == true) {
      // Print("OK - BEARISH");
      analyser_fvg_.last_fvg_type_ = FVG_NONE;
      analyser_fvg_.last_fvg_time_ = 0;
      return true;
   } else {
      datetime time_ = iTime(_Symbol, tf, 0);
      analyser_fvg_.type_ = FVG_NONE;
      analyser_fvg_.time_ = time_; // 0; // mininum datetime since 1972

      // SEEK 100 LOOPBACK
      LoopbackFVG(analyser_fvg_, tf);
      return false;
   }
}

// BULLISH FVG          - NO CONFIRM
bool H4_has_bullish_fvg(ANALYSER_FVG_RSI &analyser_fvg_, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4) {
   double high2Ago = iHigh(_Symbol, tf, 2 + shift);
   double lowNow = iLow(_Symbol, tf, 0 + shift);

   if (high2Ago < lowNow) {
      datetime time_ = iTime(_Symbol, tf, 0 + shift);
      analyser_fvg_.type_ = FVG_BULLISH;
      analyser_fvg_.time_ = time_;
      analyser_fvg_.top_ = lowNow;
      analyser_fvg_.bottom_ = high2Ago;
      /////////////////////////// analyser_fvg_.a t r_ = 0; // on demand copy request

      analyser_fvg_.last_fvg_type_ = FVG_BULLISH;
      analyser_fvg_.last_fvg_time_ = time_;
      return true;
   }

   return false;
}

// GENERIC HAS_BULLISH_FVG
bool HAS_BULLISH_FVG_(int shift=0, ENUM_TIMEFRAMES tf=PERIOD_H4) {
   double high2Ago = iHigh(_Symbol, tf, 2 + shift);
   double lowNow = iLow(_Symbol, tf, 0 + shift);
   if (high2Ago < lowNow) {
      return true;
   }
   return false;
}

// double H4_has_bullish_sweep_down() {}

// Pattern BULLISH ENGULFING
// bool H4_has_bullish_engulfing(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
//   {
//    double close1 = iClose(_Symbol,tf,1 + shift);
//    double close2 = iClose(_Symbol,tf,2 + shift);
//    double open1 = iOpen(_Symbol,tf,1 + shift);
//    double open2 = iOpen(_Symbol,tf,2 + shift);
//    datetime time_ = iTime(_Symbol,tf, 2 + shift);
//    time = time_;
//    return      open1 > close1       && close1 > open1    && close1 >= open2      && close2 >= open1      && close1 - open1 > open2 - close2;
//   }

// double has_3_white_soldiers() {}

// HAS BULLISH HARAMI
//  bool H4_has_bullish_harami(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
//    {
//     double close1 = iClose(_Symbol,tf,1 + shift);
//     double close2 = iClose(_Symbol,tf,2 + shift);
//     double open1 = iOpen(_Symbol,tf,1 + shift);
//     double open2 = iOpen(_Symbol,tf,2 + shift);
//     datetime time_ = iTime(_Symbol,tf, 2 + shift);
//     time = time_;
//     return open2 > close2 && close1 > open1 && close1 <= open2 && close2 <= open1 && close1 - open1 < open2 - close2;
//    }

// BEARISH FVG ============================================================================{

// HAS BEARISH FVG
bool H4_has_bearish_fvg(ANALYSER_FVG_RSI &analyser_fvg_, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4) {
   double low2Ago = iLow(_Symbol, tf, 2 + shift);
   double highNow = iHigh(_Symbol, tf, 0 + shift);
   double openNow = iOpen(_Symbol, tf, 0 + shift);

   if (low2Ago > highNow) {
      datetime time_ = iTime(_Symbol, tf, 0 + shift);
      analyser_fvg_.type_ = FVG_BEARISH;
      analyser_fvg_.time_ = time_;
      analyser_fvg_.top_ = low2Ago;
      analyser_fvg_.bottom_ = highNow;
      ///////////////////////////////analyser_fvg_.a t r_ = 0; // on demand copy request

      analyser_fvg_.last_fvg_type_ = FVG_BEARISH;
      analyser_fvg_.last_fvg_time_ = time_;
      return true;
   }

   return false;
}

// GENERIC HAS BEARISH FVG
bool HAS_BEARISH_FVG_(int shift=0, ENUM_TIMEFRAMES tf=PERIOD_H4) {
   double low2Ago=iLow(_Symbol, tf, 2+shift);
   double highNow=iHigh(_Symbol, tf, 0+shift);
   if (low2Ago>highNow) {
      return(true);
   }
   return(false);
}


// bool H4_has_3_black_crows() {}

// HAS BEARISH HARAMI
// bool H4_has_bearish_harami(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
//   {
//    double close1 = iClose(_Symbol,tf,1 + shift);
//    double close2 = iClose(_Symbol,tf,2 + shift);
//    double open1 = iOpen(_Symbol,tf,1 + shift);
//    double open2 = iOpen(_Symbol,tf,2 + shift);
//    datetime time_ = iTime(_Symbol,tf, 2 + shift);
//    time = time_;
//    return close2 > open2 && open1 > close1 && open1 <= close2 && open2 <= close1 && open1 - close1 < close2 - open2;
//   }

// HAS BEARISH ENGULFING
// bool H4_has_bearish_engulfing(datetime& time, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
//   {
//    double close1 = iClose(_Symbol,tf,1 + shift);
//    double close2 = iClose(_Symbol,tf,2 + shift);
//    double open1 = iOpen(_Symbol,tf,1 + shift);
//    double open2 = iOpen(_Symbol,tf,2 + shift);
//    datetime time_ = iTime(_Symbol,tf, 2 + shift);
//    time = time_;
//    return close2 > open2 && open1 > close1 && open1 >= close2 && open2 >= close1 && open1 - close1 > close2 - open2;
//   }

// UTILITIE FUNCTION

double lowest_ = 999999;
double highest_ = -1;

//Loopback FVG
bool LoopbackFVG(ANALYSER_FVG_RSI &analyser_fvg_, ENUM_TIMEFRAMES tf = PERIOD_H4) {
   bool res=false;
   int i = 0;

   lowest_ = 999999;
   highest_ = -1;

   for (i = 0; i < 100; i++) {
      bool is_bullish = IsLoopbackFoundBullishFVG(analyser_fvg_, i, tf);
      bool is_bearish = IsLoopbackFoundBearishFVG(analyser_fvg_, i, tf);

      if (is_bearish || is_bullish) {
         res=true;
         break;
      }
   }

   if (i > 50) {
      PrintFormat("NOT FOUND ANALYSE FVG IN LOOPBACK 50");
      Alert("NOT FOUND ANALYSE FVG IN LOOPBACK 50");
   }
   return(res);
}

// CHECK LOOPBACK FOUND BULLISH FVG
bool IsLoopbackFoundBullishFVG(ANALYSER_FVG_RSI &analyser_fvg_, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_CURRENT) {
   double high2Ago = iHigh(_Symbol, tf, 2 + shift);
   double lowNow = iLow(_Symbol, tf, 0 + shift);

   if (iLow(_Symbol, tf, shift) < lowest_) {
      lowest_ = iLow(_Symbol, tf, shift);
   }
   if (iHigh(_Symbol, tf, shift) > highest_) {
      highest_ = iHigh(_Symbol, tf, shift);
   }

   if (high2Ago < lowNow && high2Ago < lowest_) {
      datetime time_ = iTime(_Symbol, tf, 0 + shift);
      analyser_fvg_.last_fvg_type_ = FVG_BULLISH;
      analyser_fvg_.last_fvg_time_ = time_;

      return true;
   }
   return false;
}

// IS LOOPBACK FOUND BEARISH FVG
bool IsLoopbackFoundBearishFVG(ANALYSER_FVG_RSI &analyser_fvg_, int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_CURRENT) {
   double low2Ago = iLow(_Symbol, tf, 2 + shift);
   double highNow = iHigh(_Symbol, tf, 0 + shift);

   if (iLow(_Symbol, tf, shift) < lowest_) {
      lowest_ = iLow(_Symbol, tf, shift);
   }
   if (iHigh(_Symbol, tf, shift) > highest_) {
      highest_ = iHigh(_Symbol, tf, shift);
   }

   if (low2Ago > highNow && low2Ago > highest_) {
      datetime time_ = iTime(_Symbol, tf, 0 + shift);
      analyser_fvg_.last_fvg_type_ = FVG_BEARISH;
      analyser_fvg_.last_fvg_time_ = time_;

      return true;
   }

   return false;
}

//// Draw FVG to chart
// void DrawFVGMarker(int shift, bool bullish)
//   {
//    color markerColor = bullish ? clrYellow : clrBlue;
//    string markerName = bullish ? "BullishFVG_" : "BearishFVG_";//
//    int total_object = ObjectsTotal(0, 0, -1) + 1;
//    markerName += IntegerToString(total_object);//
//    double startPrice = bullish == false ? iLow(_Symbol, PERIOD_CURRENT, 2 + shift) : iHigh(_Symbol, PERIOD_CURRENT, 2 + shift);
//    double endPrice = bullish == false ? iHigh(_Symbol, PERIOD_CURRENT, 0 + shift) : iLow(_Symbol, PERIOD_CURRENT, 0 + shift);
//    ObjectCreate(0, markerName, OBJ_RECTANGLE, 0,
//                 iTime(_Symbol, PERIOD_CURRENT, 2 + shift),
//                 startPrice,
//                 iTime(_Symbol, PERIOD_CURRENT, 0 + shift),
//                 endPrice);
//    ObjectSetInteger(0, markerName, OBJPROP_COLOR, markerColor);
//    ObjectSetInteger(0, markerName, OBJPROP_WIDTH, 1);

// INIT ANALYSER ATR
//bool InitAnalyseATR(ANALYSER_FVG &analyser_fvg_)
//bool InitAnalyseATR(ANALYSER_FVG &analyser_fvg_)
//{
//  if (CopyBuffer(ATR_handle, 0, 0, 100, ATR_buffer) < 0)
//  {
//    Print("Error?");
//    // ResetLastError();
//  }
//  else
//  {
//    analyser_fvg_.a t r_ = ATR_buffer[1];
//    // ObjectSetString(0, buttonATR, OBJPROP_TEXT, StringFormat("ATR: %.3f", NormalizeDouble(analyser_fvg.a t r _, _Digits)));
//  }
//
//  ZeroMemory(ATR_buffer);
//
//  int err_ = GetLastError();
//  if (err_ > 0)
//  {
//    // ResetLastError();
//    Print(err_);
//  }
//
//  return true;
//}

// IN TIME RANGE
bool InTimeRange(int hour_start_, int hour_end_, int &bar_hour_) {
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime tm;
   TimeToStruct(time, tm);
   bar_hour_ = tm.hour;
   if (tm.hour >= hour_start_ && tm.hour <= hour_end_) {
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+


//// ADD/UPDATE/DELETE STRUCTS OF ARRAY IN MEMORY
//void PositionDataAdd(POSITION_DATA[] &position_data, ulong position_, double profit_)
//   {
//      // int size = ArraySize(position_data);
//   }


