//+------------------------------------------------------------------+
//|                                 EA_IB_GOLD.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.01"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

#include <_HELPER.V6\HELPER.mqh>
#include <_HELPER.V6\HELPER.ext.mqh>
//#include <_HELPER.V6\Telegram.mqh>

CSymbolInfo m_symbol;
// CPositionInfo               m_position;
// CTrade                      trade;
//CCustomBot bot;

//_______________________________<INPUTS>_______________________________

input group "GENERAL S E T T I N G S";          // ------------------------------------------------------
input double                                          POSITION_SIZE_DOUBLE = 0.3;
input bool                                            HOLD_ON_WEEKEND_BOOL = false;
input bool                                            LIMIT_TRADE_TIME_BOOL = false;
input int                                             MAX_BUY_TOTAL_INT = 1;
input int                                             MAX_SELL_TOTAL_INT = 1;
input bool                                            ONE_WAY_TRADING_BOOL = true;

input group "ENTRY S E T T I N G S";            // ------------------------------------------------------
input ENUM_CONDITION_COMBO                            CONDITION_COMBO=CONDITION_COMBO_EMA_ADX;
// gold 0.5-2
// gbpjpy 0.0003-0.003
input double                                          EMA_THRESHOLD = 0.0003;
input ENUM_ADX_THRESHOLD                              ADX_THRESHOLD = ADX_THRESHOLD20;
input bool                                            USE_VWAP_BOOL=true;

//// TODO: use MACD ? filer ?
//input bool                                            USE_MACD_BOOL=true;

input int                                             FILTER_TIME_X=1; // FILTER-TIME-X [1-2-3]


input group "EXIT S E T T I N G S";             // ------------------------------------------------------
input ENUM_TIMEFRAMES                                 ATR_TIMEFRAME=PERIOD_H2;
input double                                          ATR_multiplier=10; // ATR multiplier


bool                                            USE_ADX_V2 = false;

//_______________________________</INPUTS>_______________________________

//datetime lastbar_timeopen = __DATETIME__; // IS NEW BAR, LOR_;

long allows_account[] = {1, 2, 332463240, 98377677, 333063281};

//|------------ START HERE ------------|
int OnInit() {

//   // TG_SendMessage(chatId,botToken);
//   TG_SendInfoMessage(TG_GetChatID(), TG_GetBotToken(), " OnInit() " );
//
////-------------------------
//   string accoutn_name = AccountInfoString(ACCOUNT_NAME);
//   long account_login = AccountInfoInteger(ACCOUNT_LOGIN);
//   int index_ = FindInArray(allows_account, account_login);
//   // if ( accoutn_name == "Tester" || index_ >= 0  )
//   if (index_ >= 0) {
//      Comment(StringFormat("Welcome     %s login : %d  ", accoutn_name, account_login));
//      // is_authorized=true;
//   } else {
//      Comment("Unauthorized!");
//      ExpertRemove();
//   }
//
//   ResetLastError();

   // CreateButtonTime();

   // InitIndicatorCustom();
   // Two colons, "::" = ?
   //ENUM_STORSI_KLINE xx = ENUM_STORSI_KLINE::KPERIOD3;
   //InitIndicatorAll(true, false, true, true, xx,1,ATR_TIMEFRAME,POSITION_SIZE_DOUBLE);

   //if (USE_FIBO_BOOL==true) {
   //   USE_FIBONACCI_BOOL___=true;
   //}
   //if (USE_VWAP_BOOL==true) {
   //   InitVWAP();
   //}

   return (INIT_SUCCEEDED);
}

// CLEAN UP
void OnDeinit(const int reason) {
   Comment("");
   //EventKillTimer();
   ObjectsDeleteAll(0);
   IndicatorRelease_Generic();
}

datetime last_execute_time = 0;

void OnTick() {

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
   if (secs_diff > 66 * FILTER_TIME_X) {
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

   if (confirmedBullishFVG_==false && confirmedBearighFVG_==false) {
      return;
   }

   // input ENUM_CONDITION_COMBO                         CONDITION_COMBO=CONDITION_COMBO_EMA_STO_ADX;
   CONDITION_INFO condition_info_;
   
   int condition_ = IsValidCondition_Generic(condition_info_, CONDITION_COMBO, ADX_THRESHOLD, EMA_THRESHOLD, USE_ADX_V2);

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

   // --------------------------------------
   // JUST MESSAGE TO TELEGRAM ?
   // CONDITION MATCH (NOT INCLUDE CONDITION MAX SELL/BUY TOTAL POSITION )
   // --------------------------------------
   
   if (confirmedBullishFVG_ == true && condition_ == 1) {
      // TG_SendOrderMessage(TG_GetChatID(), TG_GetBotToken(),ORDER_TYPE_BUY,-1,-1);
      TG_SendInfoMessage(TG_GetChatID(), TG_GetBotToken(), condition_info_, "LONG MEETS");
   }
   else if (confirmedBearighFVG_ == true && condition_ == 2) {
      // TG_SendOrderMessage( TG_GetChatID(), TG_GetBotToken(),ORDER_TYPE_SELL,-1,-1);
      TG_SendInfoMessage(TG_GetChatID(), TG_GetBotToken(), condition_info_, "SHORT MEETS");
   }

}
//+------------------------------------------------------------------+
