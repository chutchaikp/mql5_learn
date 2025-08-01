//+------------------------------------------------------------------+
//|                                 EA_FVG_MEMORY_RSI_FIBONACCI_adx.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// FOR:
// - GBPJPY
// - ?

// -FIBONACCI +VWAP


// GBPJPY SLOPE
// 0.0003 0.003 0.03
// EURUSD SLOPE
//

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "777.66"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

#include <_ICT6.2\HELPER.mqh>
// #include <_ICT6.2\ANALYSER_HELPER.mqh>

CSymbolInfo m_symbol;
// CPositionInfo               m_position;
// CTrade                      trade;

//_______________________________<INPUTS>_______________________________

// input group "|------ GENERAL S E T T I N G S ------|";          // ------------------------------------------------------
double                                          POSITION_SIZE_DOUBLE = 0.3;
bool                                            HOLD_ON_WEEKEND_BOOL = false;
bool                                            LIMIT_TRADE_TIME_BOOL = false;
int                                             MAX_BUY_TOTAL_INT = 1;
int                                             MAX_SELL_TOTAL_INT = 1;
bool                                            ONE_WAY_TRADING_BOOL = true;

// input group "|------ ENTRY S E T T I N G S ------|";            // ------------------------------------------------------
ENUM_CONDITION_COMBO                            CONDITION_COMBO=CONDITION_COMBO_EMA_ADX;
// gold 0.5-2
// gbpjpy 0.0003-0.003
double                                          EMA_THRESHOLD = 0.5;
ENUM_ADX_THRESHOLD                              ADX_THRESHOLD = ADX_THRESHOLD20;
bool                                            USE_VWAP_BOOL=false;


input group "|------ EXIT S E T T I N G S ------|";             // ------------------------------------------------------
input ENUM_TIMEFRAMES                                 ATR_TIMEFRAME=PERIOD_H2;
// ATR multiplier(10-50)
input double                                          ATR_multiplier=1; 

bool                                            USE_ADX_V2 = false;

//_______________________________</INPUTS>_______________________________

//datetime lastbar_timeopen = __DATETIME__; // IS NEW BAR, LOR_;

// 333063281 - GBPJPY# Standard demo ?
long allows_account[] = {1, 2, 332463240, 98377677, 333063281};

//|------------ START HERE ------------|
int OnInit() {

   string accoutn_name = AccountInfoString(ACCOUNT_NAME);
   long account_login = AccountInfoInteger(ACCOUNT_LOGIN);
   int index_ = FindInArray(allows_account, account_login);
   // if ( accoutn_name == "Tester" || index_ >= 0  )
   if (index_ >= 0) {
      Comment(StringFormat("Welcome     %s login : %d  ", accoutn_name, account_login));
      // is_authorized=true;
   } else {
      Comment("Unauthorized!");
      ExpertRemove();
   }

   ResetLastError();

   CreateButtonTime();
   CreateButtonOrder(true,true,true);

   // InitIndicatorCustom();
   // Two colons, "::" = ?

   //int InitIndicatorAll(       bool useMA = false,
   //                  bool useSTO = false,
   //                  bool useADX = false,
   //                  bool useATR = false,

   //                  ENUM_STORSI_KLINE STO_KPeriod = KPERIOD14,
   //                  int adx_version_int = 1,
   //                  ENUM_TIMEFRAMES atr_timeframe = PERIOD_H2,
   //                  double position_size_ = 0
   //                 ) {

   ENUM_STORSI_KLINE xx = ENUM_STORSI_KLINE::KPERIOD3;
   InitIndicatorAll(false, false, false, true, xx,1,ATR_TIMEFRAME,POSITION_SIZE_DOUBLE);

   if (USE_VWAP_BOOL==true) {
      InitVWAP();
   }


   #ifdef _DEBUG
   EventSetTimer(5);
   #endif 

   return (INIT_SUCCEEDED);
}

// CLEAN UP
void OnDeinit(const int reason) {
   Comment("");
   EventKillTimer();
   ObjectsDeleteAll(0);
   IndicatorRelease_Generic();
}

datetime last_execute_time = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   UpdateButtonCurrentTime();
}

void OnTick_() {

   if (HOLD_ON_WEEKEND_BOOL == false && IsFridayNightSaturdaySunday() == true) {
      if (PositionsTotal() > 0) {
         PositionCloseAllV1();
      }
      return;
   }

   if (InTimeRange_Generic() == false && LIMIT_TRADE_TIME_BOOL == true) {
      if (PositionsTotal() > 0) {
         PositionCloseAllV1();
      }
      return;
   }

   MqlTick tick;
   if (SymbolInfoTick(_Symbol, tick) == false) {
      return;
   }
   int secs_diff = (int)(tick.time - last_execute_time);
   if (secs_diff > 66) {
      last_execute_time = tick.time;
   } else {
      return;
   }

   OrderConditions();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderConditions() {

   int buy_total = BuyTotal();
   int sell_total = SellTotal();

   bool confirmedBullishFVG_ = FVG_DetectBullishFVG_Generic();
   bool confirmedBearighFVG_ = FVG_DetectBearishFVG_Generic();

   int condition_ = IsValidCondition_Generic(CONDITION_COMBO, ADX_THRESHOLD, EMA_THRESHOLD, USE_ADX_V2);

   if (ONE_WAY_TRADING_BOOL == true && condition_ > 0) {
      if (confirmedBullishFVG_ == true && condition_ == 1 && sell_total > 0) {
         PositionCloseAll(POSITION_TYPE_SELL);
      }
      if (confirmedBearighFVG_ == true && condition_ == 2 && buy_total > 0) {
         PositionCloseAll(POSITION_TYPE_BUY);
      }
   }

   if (confirmedBullishFVG_ == true && buy_total < MAX_BUY_TOTAL_INT && condition_ == 1) {

      double atr_ = iATRGet_Generic(0);
      double lots_ = LotSize_Generic(POSITION_SIZE_DOUBLE);
      if (atr_ <= 0 || lots_ <= 0) {
         return;
      }
      Order_Generic(ORDER_TYPE_BUY, lots_, atr_, ATR_multiplier);

   } else if (confirmedBearighFVG_ == true && sell_total < MAX_SELL_TOTAL_INT && condition_ == 2) {


      double atr_ = iATRGet_Generic(0);
      double lots_ = LotSize_Generic(POSITION_SIZE_DOUBLE);
      if (atr_ <= 0 || lots_ <= 0) {
         return;
      }
      Order_Generic(ORDER_TYPE_SELL, lots_, atr_, ATR_multiplier);

   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer(void) {
   // print out atr value ?
   double atr_ = iATRGet_Generic();

   double bid_ = Tick_Generic().bid;
   double ask_ = Tick_Generic().ask;
   datetime time_ = Tick_Generic().time;
   long time_msc_ = Tick_Generic().time_msc;
   //PrintFormat("Last tick was at %s.%03d",
   //            TimeToString(last_tick.time, TIME_SECONDS),
   //            last_tick.time_msc % 1000 );

   PrintFormat("atr: %.2f ask: %0.2f date: %s.%03d ",atr_,ask_,TimeToString(time_,TIME_SECONDS),time_msc_ % 1000);
}

// TODO: MANUAL TRADING ?
//------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   //if(id==CHARTEVENT_OBJECT_CLICK) {
   //   Print("xx Clicking a mouse button on an object named '"+sparam+"'");
   //}

   if (id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, buttonLong) >= 0) {
      double atr_=iATRGet_Generic();
      double lots_ = StringToDouble( ObjectGetString(0,buttonLots,OBJPROP_TEXT) );
      Order_Generic(ORDER_TYPE_BUY, lots_, atr_, ATR_multiplier);

      Sleep(5);
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

// Order_Generic(ORDER_TYPE_BUY)
// ChartSetSymbolPeriod() ?
// ChartScreenShot() ?

   } else if (id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, buttonShort) >= 0) {
      double atr_=iATRGet_Generic();
      double lots_ = StringToDouble( ObjectGetString(0,buttonLots,OBJPROP_TEXT) );
      Order_Generic(ORDER_TYPE_SELL, lots_, atr_, ATR_multiplier);

      Sleep(5);
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   } else if (id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, buttonCloseAll) >= 0) {
      PositionCloseAll_Generic();
      Sleep(5);
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   }


   //CDialog ?
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam==buttonLots) {
      ObjectSetString(0, buttonLots, OBJPROP_TEXT, ObjectGetString(0,buttonLots,OBJPROP_TEXT));
      // Print(ObjectGetString(0,"buttonLots",OBJPROP_TEXT)); //Prints OLD VALUE
   }
}

//+------------------------------------------------------------------+
