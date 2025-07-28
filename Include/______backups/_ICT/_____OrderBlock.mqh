//+------------------------------------------------------------------+
//|                                                   OrderBlock.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


// TEST
double get_ob_price()
  {
   double high_ = iHigh(_Symbol, PERIOD_CURRENT, 0);
   return high_;
  }

// TODO: UTILITY FOR ANALYSE TIMEFRAME (H4 ?)

// FVG                  - NO CONFIRM
// PRICE ACTION         - CONFIRMED

// BULLISH FVG          - NO CONFIRM
bool has_bullish_fvg(int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {  
   double high2Ago = iHigh(_Symbol, tf, 2 + shift); 
   double lowNow = iLow(_Symbol, tf, 0 + shift); 

   return (high2Ago < lowNow);
  }

// TODO
//double has_bullish_sweep_down()
//  {
//
//  }

// Pattern BULLISH ENGULFING
bool has_bullish_engulfing(ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1);
   double close2 = iClose(_Symbol,tf,2);
   double open1 = iOpen(_Symbol,tf,1);
   double open2 = iOpen(_Symbol,tf,2);
   return      open1 > close1       && close1 > open1    && close1 >= open2      && close2 >= open1      && close1 - open1 > open[2] - close[2];
  }

//double has_3_white_soldiers()
//  {
//
//  }

//HAS BULLISH HARAMI
bool has_bullish_harami(ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1);
   double close2 = iClose(_Symbol,tf,2);
   double open1 = iOpen(_Symbol,tf,1);
   double open2 = iOpen(_Symbol,tf,2);
   return open2 > close2 && close1 > open1 && close1 <= open2 && close2 <= open1 && close1 - open1 < open2 - close2;
  }






// BEARISH FVG ============================================================================{

// HAS BEARISH FVG
bool has_bearish_fvg(int shift = 0, ENUM_TIMEFRAMES tf = PERIOD_H4)
  {  
   double low2Ago = iLow(_Symbol, tf, 2 + shift);
   double highNow = iHigh(_Symbol, tf, 0 + shift);
   return (low2Ago > highNow);
  }


//bool has_3_black_crows()
//  {
//
//  }

// HAS BEARISH HARAMI
bool has_bearish_harami(ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1);
   double close2 = iClose(_Symbol,tf,2);
   double open1 = iOpen(_Symbol,tf,1);
   double open2 = iOpen(_Symbol,tf,2);
   return close2 > open2 && open1 > close1 && open1 <= close2 && open2 <= close1 && open1 - close1 < close2 - open2;
  }

// HAS BEARISH ENGULFING
bool has_bearish_engulfing(ENUM_TIMEFRAMES tf = PERIOD_H4)
  {
   double close1 = iClose(_Symbol,tf,1);
   double close2 = iClose(_Symbol,tf,2);
   double open1 = iOpen(_Symbol,tf,1);
   double open2 = iOpen(_Symbol,tf,2);

   return close2 > open2 && open1 > close1 && open1 >= close2 && open2 >= close1 && open1 - close1 > close2 - open2;
  }

