//+------------------------------------------------------------------+
//|                                 EA_FVG_MEMORY_RSI_FIBONACCI_adx.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// +FIBONACCI

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

//______________________________________________________________________
//_______________________________<INPUTS>_______________________________

// input bool                                         TRADE_ONE_DIRECTION_BOOL=true;
input ENUM_CONDITION_COMBO CONDITION_COMBO = CONDITION_COMBO_EMA_ADX;
// input ENUM_TIMEFRAMES                              TF_entry=PERIOD_M5;  // ENTRY TIMEFRAME
input double ATR_multiplier = 10; // ATR multiplier(10-50)
// input bool                          LIMIT_trade_time        =false;
//  input bool                                         LIMIT_TRADE_TIME_BOOL=false;
// input bool                          hold_on_WEEKEND         =false;
input bool HOLD_ON_WEEKEND_BOOL = false;
input bool LIMIT_TRADE_TIME_BOOL = false;
// int                     ATR_shift=0; // ATR shift(0 or 1)
int BALANCE_MINIMUM_ALLOWED = 500;
// input bool                          MININUM_PROFIT_ALLOW_BOOL=true;
// input int                           MININUM_PROFIT_ALLOW_USD=-10;

input int MAX_BUY_TOTAL_INT = 1;
input int MAX_SELL_TOTAL_INT = 1;

//--------------------------------------------------------------------//
//------------------------- MONEY MANAGEMENT TECHNIC------------------//
//--------------------------------------------------------------------//
// input double                        position_SIZE           =0.01; // LotSize(0.01-0.1)
input double POSITION_SIZE_DOUBLE = 0.3;
// input bool                          USE_CUTOFF              =true;
// input bool                          USE_CUTOFF_LOSS         =true;
// input bool                                         USE_CUTOFF_LOSS_BOOL=false;
// input bool                          USE_CUTOFF_PROFIT       =false;
// input bool                                         USE_CUTOFF_PROFIT_BOOL=false;
// balance 1000  (loss: -5, profit: 20)
// balance 10000 (loss: -5*10, profit: 20*10)

// POSITION SIZE: 0.01 / CUTOFF_LOSS_USD: -40 / CUTOFF_PROFIT_USD: 100

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// input double                                       CUTOFF_LOSS_USD=-40; // CUTOFF LOSS USD(-10 TO -50)
// input double                                       CUTOFF_PROFIT_USD=200; // CUTOFF PROFIT USD(50 TO 200)

// 1-waitconfitm, 0-nowait
// input int                           fvg_shift               =0;
// input int                                          FVG_SHIFT_INT=0; // FVG shift(0 OR 1)

// input bool                          USE_EMA200_BOOL         =true;
// ENUM_TIMEFRAMES         TIMEFRAME_EMA200  =PERIOD_M10;

// | RSI INPUT |
//int RSIPeriod = 14;
//int RSIOverSold = 30;
//int RSIOverBought = 70;

// input ENUM_TIMEFRAMES RSITF  = PERIOD_H4;
// input ENUM_TIMEFRAMES                                 RSI_TIMEFRAME=PERIOD_H3;
//  input ENUM_TIMEFRAMES                                 FIBONACCI_TIMEFRAME=PERIOD_H1;

input ENUM_ADX_THRESHOLD ADX_THRESHOLD = ADX_THRESHOLD20;
input double EMA_THRESHOLD = 0.5;
input bool USE_ADX_V2 = true;
input bool ONE_WAY_TRADING_BOOL = true;

input ENUM_STORSI_KLINE KPeriodSelect = KPERIOD3;

// FIBO - EXIT STRATEGY ?
input bool USE_FIBO_BOOL = true;
input ENUM_TIMEFRAMES FIBO_TIMEFRAME = PERIOD_H1;
input int FIBO_TP_INT = 1; // fibo tp (1.272 or 1.618)

//|----------------- Filter SESSION ? -----------------|
// bool     FilterWithTradingTime  =false;
//
////int      LondonStartHour   =10;
// int      LondonStartHour   =9;
// int      LondonEndHour     =14;
// int      NYStartHour       =15;
// int      NYEndHour         =19;
//
//// cannot be input ?
// double                        RSI0_=-1;
// double                        RSI1_=-1;

// 30 60 90 UPDATE RSI SIG STATE EVERY X SECONDS
// input int                                             RSI_TIMER_UPDATE_INTERVAL_INT=30;

//_______________________________</INPUTS>_______________________________

// input bool                          ASYNC_MODE=true;
bool SHOW_FVG_MARKER = false;
// bool                             SHOW_ COMMENT=false;

bool USE_DYNAMIC_ATR = true; // USE DYNAMIC ATR
// setup trade time
int hour_start = 8; // Start Hour (utc+2)
int hour_end = 18;  // End Hour (utc+2)

bool close_position_when_AFVG_changed = false; // CLOSE POSITION WHEN AFVG CHANGED / Hedging
// input bool                    use_ATR_from_entry_timeframe=false;

// INDICATOR COPY SOME VALUE FROM
double ATR_buffer[]; // array for the indicator iATR
int ATR_handle;      // handle of the indicator iATR
bool AsSeries = true;

double MA_buffer[]; // array for the indicator iATR
int MA_handle;

double RSI_buffer[];
int RSI_handle;

FVG fvg = {FVG_NONE, 0, 0, __DATETIME__, 0};

// int                           risk_percent=10;
// int                           position_maximum=2; // Maximum position 1

datetime lastbar_timeopen = __DATETIME__; // IS NEW BAR, LOR_;
string analyser_fvg_info = "";            // bullish_fvg, bearish_fvg
string analyse_price_action_info = "";    // bullish_engulfing, bearish_engulfing ? harami

// LIMIT TIME FOR TRADING
// bool IS_FRIDAYNIGHT_SATURDAY_SUNDAY = false;

long allows_account[] = {1, 2, 332463240, 98377677};
// bool is_authorized                  =false;

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

   // InitIndicatorCustom();
   InitIndicatorAll(true, true, true, true, KPeriodSelect);

   return (INIT_SUCCEEDED);
}

// CLEAN UP
void OnDeinit(const int reason) {
   Comment("");
   //EventKillTimer();
   ObjectsDeleteAll(0);
}

datetime last_execute_time = 0;

void OnTick() {

   // PositionsUpdateSLfromATR();
   // UpdateButtonCurrentTime();

   if (HOLD_ON_WEEKEND_BOOL == false && IsFridayNightSaturdaySunday() == true) {
      if (PositionsTotal() > 0) {
         PositionCloseAllV1();
      }
      return;
   }

   // if LIMIT_TRADE_TIME_BOOL is false - not run InTimeRange_Generic
   if (InTimeRange_Generic() == false && LIMIT_TRADE_TIME_BOOL == true) {
      if (PositionsTotal() > 0) {
         PositionCloseAllV1();
      }
      return;
   }

   // if(IsNewBar(lastbar_timeopen)) {

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

   // ENTRY TIMEFRAME
   FVG bullish_fvg;
   FVG bearish_fvg;

   if (!IsBullishFVG_Generic(bullish_fvg, PERIOD_M1, 1, false) && !IsBearishFVG_Generic(bearish_fvg, PERIOD_M1, 1, false)) {
      // if( !IsBullishFVG_Generic(bullish_fvg,PERIOD_M5,0,false) && !IsBearishFVG_Generic(bearish_fvg,PERIOD_M5,0,false)  ) {
      fvg.type_ = FVG_NONE;
      fvg.time_ = iTime(_Symbol, PERIOD_CURRENT, 0);
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

   // if(fvg.type_ == FVG_NONE) {
   //    return;
   // }

   // input ENUM_CONDITION_COMBO                         CONDITION_COMBO=CONDITION_COMBO_EMA_STO_ADX;

   int condition_ = IsValidCondition_Generic(CONDITION_COMBO, ADX_THRESHOLD, EMA_THRESHOLD, USE_ADX_V2);

   if (ONE_WAY_TRADING_BOOL == true && condition_ > 0) {
      if (confirmedBullishFVG_ == true && condition_ == 1 && sell_total > 0) {
         PositionCloseAll(POSITION_TYPE_SELL);
      }
      if (confirmedBearighFVG_ == true && condition_ == 2 && buy_total > 0) {
         PositionCloseAll(POSITION_TYPE_BUY);
      }
   }

   // entry -  m5
   // adx ? -  m10
   // fibo for what ?
   // exit strategy with fibo or atr ?

   if (confirmedBullishFVG_ == true && buy_total < MAX_BUY_TOTAL_INT && condition_ == 1) {

      //      USE_FIBO_BOOL
      //      FIBO_TIMEFRAME
      //      FIBO_TP_INT
      //
      if (USE_FIBO_BOOL == true) {
         LOTS___=POSITION_SIZE_DOUBLE;
         FIBONACCI_TIMEFRAME___=FIBO_TIMEFRAME;
         Order_FIBO_Generic(ORDER_TYPE_BUY, FIBO_TP_INT);
      } else {
         double atr_ = iATRGet_Generic(0);
         double lots_ = LotSize_Generic(POSITION_SIZE_DOUBLE);
         if (atr_ <= 0 || lots_ <= 0) {
            return;
         }
         Order_Generic(ORDER_TYPE_BUY, lots_, atr_, ATR_multiplier);
      }
   } else if (confirmedBearighFVG_ == true && sell_total < MAX_SELL_TOTAL_INT && condition_ == 2) {

      if (USE_FIBO_BOOL == true) {
         LOTS___=POSITION_SIZE_DOUBLE;
         FIBONACCI_TIMEFRAME___=FIBO_TIMEFRAME;
         Order_FIBO_Generic(ORDER_TYPE_SELL, FIBO_TP_INT);
      } else {
         double atr_ = iATRGet_Generic(0);
         double lots_ = LotSize_Generic(POSITION_SIZE_DOUBLE);
         if (atr_ <= 0 || lots_ <= 0) {
            return;
         }
         Order_Generic(ORDER_TYPE_SELL, lots_, atr_, ATR_multiplier);
      }
   }
}
