//+------------------------------------------------------------------+
//|                               EA_FVG_STORSI_FIBONACCI_FOR_GOLD.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// TREORY - TOP-DOWN ANALYSYS (MULTI TIMEFRAME ANALYSYS)
// WEEKLY/DAILY            HIGHER TF            KEY LEVELS
// H4/H1                   ANALYSYS TF          SUPPLY DEMAND AREA/LIQ ZONE/              FIBO ?
// M15/M5                  ENTRY TF             CONFIRM & ENTRY                           FVG ?

// CHANGES:

// SECRET ? FOR THIS FIBO STRATEGY ?
// GBPJPY   - USE ENTRY TIMEFRAME = m10
// GOLD     - USE ENTRY TIMEFRAME = m5

// SL
//
//- how to implement SL from FIBO ? to reduce drawdown ?
//- check from docs.google.com

// TP - EXIT STRATEGY ?
//
// USE RR    -------------- HIGH DRAWDOWN
// USE FIBO EXTENSION  -------------- LOW DRAWDOWN
//
// https://www.bravotradeacademy.com/en/knowledge/fibonacci-trading/?srsltid=AfmBOoqVggO8O6F_oZGMnRBYCX1wiQ350o0glxxeQNPbDJEG0qD5ks_x

//+------------- TODO: TP STRATEGY (MARK FROM COMMENT IN ORDER) ---------------+
// 1. TP BY FIBO EXTENSION
// 2. TP BY TRAILING STOP

// FIBO EXTENSION -> set comment at the position comment if comment="" tp 0.5 lotsize, if comment="1" close all
// CLOSE ALL LOT IF PRICE REACH 1.272

// Calculate Fibonacci Extension Take Profit for Buy
// double GetFibonacciTPBuy(double swingLow, double swingHigh, double retrace)
//  {
//   double diff = swingHigh - swingLow;
//   double tp127 = retrace + diff * 1.272;
//   double tp1618 = retrace + diff * 1.618;
//   return tp127; // or tp1618
//  }
//
//// Calculate Fibonacci Extension Take Profit for Sell
// double GetFibonacciTPSell(double swingHigh, double swingLow, double retrace)
//   {
//    double diff = swingHigh - swingLow;
//    double tp127 = retrace - diff * 1.272;
//    double tp1618 = retrace - diff * 1.618;
//    return tp127; // or tp1618
//   }

// IF BALANCE 10000
// - STOP TRADE WHEN ENQUITY > 20000 <------------------------------------ PARAMS: STOP_TRADE_WHEN ENQUITY REACH TO 20000 OR  LESS THAN 4000
// - WITHDRAW 10000 FOR TRADING NEW PORT WITH HIGH LEVERAGE ...

// UPDATE STORSI VIA TIMER LIKE RSI ...

// %K line (fast-moving)
// %D line (signal line)

//%K and %D lines:
// The STOCH RSI has two lines: the %K line (fast-moving) and the %D line (signal line).
// The %K line represents the current value of the Stoch RSI, while the %D line is a moving average of the %K line.

// Crossover Signals:
// When the %K line crosses above the %D line, it suggests that the momentum of the asset may be shifting from oversold to overbought,
//  potentially indicating a buy signal. Conversely, when the %K line crosses below the %D line, it suggests the momentum may be shifting from overbought to oversold,
//  potentially indicating a sell signal.

// Overbought/Oversold:
// Overbought conditions are generally defined as the %K line crossing above the 80 level, and oversold conditions are defined as the %K line crossing below the 20 level.
//  These levels indicate that the asset's price may be trading at extreme levels, potentially leading to a trend reversal.

// Trend Identification:
// The Stoch RSI can also be used to identify short-term trends. When the Stoch RSI is above 0.50,
//  it may indicate an uptrend, and when it's below 0.50, it may indicate a downtrend.
//

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "6.66"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

#include <_ICT6.2\HELPER.mqh>
#include <_ICT6.2\ANALYSER_HELPER.mqh>

CSymbolInfo m_symbol;
// CPositionInfo               m_position;
// CTrade                      trade;

//______________________________________________________________________
//_______________________________<INPUTS>_______________________________
// input bool                                         NOTIFY_BOOL=false;
input bool USE_FIBO_BOOL = true;

input ENUM_TIMEFRAMES TF_entry = PERIOD_M5; // ENTRY TIMEFRAME X
// USE_ATR -> SL_FROM_SWING_OR_ATR
// input int                                          SL_FROM_SWING_OR_ATR=-1;         //SL_FROM_SWING_OR_ATR(-1:prev swing high TF 0:curr swing high TF 1:ATRmul)
input double ATR_multiply = 16; // ATRmult(8-48)
// input bool                          LIMIT_trade_time        =false;
bool LIMIT_TRADE_TIME_BOOL = false;
// input bool                          hold_on_WEEKEND         =false;
input bool HOLD_ON_WEEKEND_BOOL = false;
int ATR_shift = 0; // ATR shift(0 or 1)

int BALANCE_MINIMUM_ALLOWED = 500;

input int MAX_BUY_TOTAL_INT = 5;
input int MAX_SELL_TOTAL_INT = 5;

// input bool                                         USE_CUTOFF_LOSS_BOOL=false;
// input bool                                         USE_CUTOFF_PROFIT_BOOL=false;

//+------------------------------------------------------------------+
input double POSITION_SIZE_DOUBLE = 0.01;
//+------------------------------------------------------------------+
// input double                                       CUTOFF_LOSS_USD=-10; // CUTOFF LOSS USD
// input double                                       CUTOFF_PROFIT_USD=80; // CUTOFF PROFIT USD

// 1-waitconfitm, 0-nowait
input int FVG_SHIFT_INT = 0; // FVG shift(0 OR 1)

// input int                                             RSI_TIMER_UPDATE_INTERVAL_INT=480;
input int STORSI_TIMER_UPDATE_INTERVAL_INT = 30;

input ENUM_TIMEFRAMES STORSI_TIMEFRAME = PERIOD_H3;
input bool STORSI_WHEN_OVERBOUGHT_OVERSOLD = false;
// input bool                                         WHEN_OVERBOUGHT_OVERSOLD=true;

input ENUM_TIMEFRAMES FIBONACCI_TIMEFRAME = PERIOD_H1;
input ENUM_TIMEFRAMES ANALYSER_TIMEFRAME = PERIOD_H4;

// bool     USE_TRAILING_BOOL=true;
double RR = 1; // RR 1=1:1, 1.5=1:1.5
// CAL TP FROM FIBONACCI EXTENSION ?

//      double tp127 = retrace + (diff * 1.272);
//      double tp1618 = retrace + (diff * 1.618);
// input bool                                         USE_FIBONACCI_EXTENSION_BOOL=true;
// USE_FIBONACCI_EXTENSION_OPTION -> TP_FIBONACCI_EXTENSION_OPTIONS
input int TP_FROM_FIBONACCI_EXTENSION_OPTIONS = 0; // TP.FROM.FIBO.EXT(0:ATR,1:FIBOEXT1.272,2:FIBOEXT1.618)
input int SL_FROM_SWING_OR_ATR = 1;                // SL.FROM.SWING.OR.ATR(-1:prev.swing,0:curr.swing,1:ATR)

//_______________________________</INPUTS>_______________________________

// -------- STORSI -------------
// int KPeriod = 14;
// int KPeriod = 3;
// int KPeriod = 5;
input int KPeriodSelect = 2; // KPeriod(1: "3", 2: "5", 3: "14")
int DPeriod = 3;
int RSI_Period = 14;
double STORSI_OVER_BOUGHT = 80.0;
double STORSI_OVER_SOLD = 20.0;

// input bool                          ASYNC_MODE=true;

bool SHOW_FVG_MARKER = false;
bool SHOW_COMMENT = false;

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

double STORSI_buffer[];
int STORSI_handle;

FVG fvg = {FVG_NONE, 0, 0, __DATETIME__, 0};

datetime lastbar_timeopen = __DATETIME__; // IS NEW BAR, LOR_;
string analyser_fvg_info = "";            // bullish_fvg, bearish_fvg
string analyse_price_action_info = "";    // bullish_engulfing, bearish_engulfing ? harami

bool IS_FRIDAYNIGHT_SATURDAY_SUNDAY = false;

// ------------------------- FOR INTERNAL
double SYMBOL_VOLUME_MAX_ = 0;
double SYMBOL_VOLUME_MIN_ = 0;
double SYMBOL_VOLUME_STEP_ = 0;
double SYMBOL_TRADE_TICK_SIZE_ = 0;
double SYMBOL_TRADE_TICK_VALUE_ = 0;

long ACCOUNT_LEVERAGE_ = 100;

long allows_account[] = {1, 2, 332463240, 98377677};
// bool is_authorized                  =false;

// START HERE <------------------------------------
int OnInit()
{

   string accoutn_name = AccountInfoString(ACCOUNT_NAME);
   long account_login = AccountInfoInteger(ACCOUNT_LOGIN);
   int index_ = FindInArray(allows_account, account_login);
   // if ( accoutn_name == "Tester" || index_ >= 0  )
   if (index_ >= 0)
   {
      Comment(StringFormat("Welcome     %s login : %d  ", accoutn_name, account_login));
      // is_authorized=true;
   }
   else
   {
      Comment("Unauthorized!");
      ExpertRemove();
   }

   ResetLastError();

   // if (ASYNC_MODE==true)
   //    {
   //       trade.SetAsyncMode(true); // no wait other
   //    } else
   //        {
   //         trade.SetAsyncMode(false); // no wait other
   //        }

   // FOR INTERNAL
   SYMBOL_VOLUME_MAX_ = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   SYMBOL_VOLUME_MIN_ = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   SYMBOL_VOLUME_STEP_ = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   SYMBOL_TRADE_TICK_SIZE_ = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   SYMBOL_TRADE_TICK_VALUE_ = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);

   ACCOUNT_LEVERAGE_ = AccountInfoInteger(ACCOUNT_LEVERAGE);

   CreateButton();

   if (!RefreshRates())
   {
      Print("Error RefreshRates. Bid=", DoubleToString(m_symbol.Bid(), Digits()),
            ", Ask=", DoubleToString(m_symbol.Ask(), Digits()));
      return (INIT_FAILED);
   }
   m_symbol.Refresh();

   // | ATR |
   SetIndexBuffer(0, ATR_buffer, INDICATOR_DATA);
   ArraySetAsSeries(ATR_buffer, AsSeries);
   ATR_handle = iATR(_Symbol, TF_entry, 14);
   if (ATR_handle < 0)
   {
      Print("The creation of iATR has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }
   // | /ATR |

   ////| RSI |
   //   RSI_handle=iRSI(_Symbol, RSI_TIMEFRAME, RSIPeriod, PRICE_CLOSE);
   //   if(RSI_handle==INVALID_HANDLE)
   //     {
   //      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",_Symbol,EnumToString(Period()),GetLastError());
   //      return(INIT_FAILED);
   //     }
   //   fvg.rsi_significance_state_=FVG_NONE;
   //
   //   EventSetTimer(RSI_TIMER_UPDATE_INTERVAL_INT);
   //
   //   Sleep(1000);
   //
   //   iRSILoopbacks();
   //
   ////| /RSI |

   // handle=iStochastic(name,period,Kperiod,Dperiod,slowing,ma_method,price_field);
   //| STORSI |
   int KPeriod = 3;
   if (KPeriodSelect == 1)
   {
      KPeriod = 3;
   }
   else if (KPeriodSelect == 2)
   {
      KPeriod = 5;
   }
   else if (KPeriodSelect == 3)
   {
      KPeriod = 14;
   }
   STORSI_handle = iStochastic(_Symbol, STORSI_TIMEFRAME, KPeriod, DPeriod, 3, MODE_SMA, STO_LOWHIGH);
   if (STORSI_handle == INVALID_HANDLE)
   {
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(Period()), GetLastError());
      return (INIT_FAILED);
   }
   fvg.storsi_significance_state_ = FVG_NONE;
   EventSetTimer(STORSI_TIMER_UPDATE_INTERVAL_INT);
   Sleep(1000);
   iSTORSILoopbacks();
   //| /STORSI |

   // DatabaseConnect();
   // Comment( StringFormat("ASYNC MODE      %s", ASYNC_MODE == true ? "TRUE" : "FALSE" ));

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");

   EventKillTimer();

   ObjectsDeleteAll(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{

   // if(USE_CUTOFF == true)
   //{

   // if(USE_TRAILING_BOOL==true) {
   //    PositionsTrailing();
   // }

   // UPDATE RSI EVERY TICK ?
   // UpdateRriSignificanceState();

   //}

   // if(USE_UPDATE_SL_FROM_ATR == true)
   //{
   //  PositionsUpdateSLfromATR();
   //}

   if (HOLD_ON_WEEKEND_BOOL == false && IsFridayNightSaturdaySunday() == true)
   {
      if (PositionsTotal() > 0)
      {
         PositionCloseAllV1();
      }
      return;
   }

   if (InTimeRangeV1() == false && LIMIT_TRADE_TIME_BOOL == true)
   {
      if (PositionsTotal() > 0)
      {
         PositionCloseAllV1();
      }
      return;
   }

   if (IsNewBar(lastbar_timeopen))
   {
      // ENTRY TIMEFRAME
      if (IsBullishFVG(FVG_SHIFT_INT) == false && IsBearishFVG(FVG_SHIFT_INT) == false)
      {
         fvg.type_ = FVG_NONE;
         fvg.time_ = iTime(_Symbol, PERIOD_CURRENT, 0);
      }

      OrderConditions();
      // OrderConditions_V2();
   }
}

// SETUP TIME RANGE
bool InTimeRangeV1()
{
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);

   MqlDateTime dt_;
   TimeToStruct(time, dt_);
   string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week + " " + (string)time);

   MqlDateTime tm;
   TimeToStruct(time, tm);

   if (tm.hour >= hour_start && tm.hour <= hour_end)
   {
      return true;
   }
   return false;
}

//// CHECK IS HOLIDAY, ALSO CLOSE POSITION ON FRIDAY NIGHT
// bool IsFridayNightSaturdaySunday() {
//    datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
//    MqlDateTime dt;
//    TimeToStruct(time, dt);
//
//    if(dt.day_of_week == (ENUM_DAY_OF_WEEK)FRIDAY && dt.hour >= 20) {
//       return(true);
//    }
//    if(dt.day_of_week == (ENUM_DAY_OF_WEEK) SATURDAY) {
//       return true;
//    }
//    if(dt.day_of_week == (ENUM_DAY_OF_WEEK) SUNDAY) {
//       return true;
//    }
//    return(false);
// }

// ORDER CONDITIONS
void OrderConditions()
{

   if (fvg.type_ == FVG_NONE)
   {
      return;
   }

   int sell_total = SellTotal();
   int buy_total = BuyTotal();

   datetime time_ = iTime(Symbol(), Period(), 0);

   // TODO: FILTER WITH EMA (................)

   if (fvg.type_ == FVG_BULLISH && buy_total < MAX_BUY_TOTAL_INT && fvg.storsi_significance_state_ == FVG_BULLISH && HAS_BULLISH_FVG_(0, ANALYSER_TIMEFRAME))
   {
      // FIBO ?
      double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 1);
      double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 1);
      double currentLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 0);

      double fib_1618 = FibLevel(lastHigh, lastLow, 1.618); // FOR TP
      double fib_1 = FibLevel(lastHigh, lastLow, 1);
      double fib_786 = FibLevel(lastHigh, lastLow, 0.786);
      // double fib_618 = FibLevel(lastHigh, lastLow, 0.618);
      double fib_50 = FibLevel(lastHigh, lastLow, 0.5);
      double fib_236 = FibLevel(lastHigh, lastLow, 0.236);

      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ BID);

      // if (currentPrice >= fib_50 && currentPrice <= fib_618) {
      // if(currentPrice >= fib_50 && currentPrice <= fib_786) {
      //+--------------------------- IMPORTANT? ---------------------------+
      // if (USE_GOLDEN_ZONE_BOOL==true) {
      // else {
      //    xxxxxxxxxxxxxxx
      //    if(currentLow >= lastLow && currentLow <= fib_50) {
      //       Order_(ORDER_TYPE_BUY, lastLow, lastHigh, currentLow );
      //    }
      // }
      if (currentPrice >= fib_50 && currentPrice <= fib_1)
      {
         Order_(ORDER_TYPE_BUY, lastLow, lastHigh, currentLow);
      }
      //}
      //+------------------------------------------------------------------+
   }
   else if (fvg.type_ == FVG_BEARISH && sell_total < MAX_SELL_TOTAL_INT && fvg.storsi_significance_state_ == FVG_BEARISH && HAS_BEARISH_FVG_(0, ANALYSER_TIMEFRAME))
   {
      // FIBO ?
      double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 1);
      double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 1);
      double currentHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 0);

      double fib_236 = FibLevelForSell(lastHigh, lastLow, 0.236);
      // double fib_382 = FibLevelForSell(lastHigh, lastLow, 0.382);
      double fib_50 = FibLevelForSell(lastHigh, lastLow, 0.5);
      // double fib_618 = FibLevelSorSell(lastHigh, lastLow, 0.618);
      // double fib_786 = FibLevelForSell(lastHigh, lastLow, 0.786);
      double fib_1 = FibLevelForSell(lastHigh, lastLow, 1);
      double fib_1618 = FibLevelForSell(lastHigh, lastLow, 1.618);

      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ ASK);

      // if (currentPrice <= fib_50 && currentPrice >= fib_382) {
      //  if(currentPrice >= fib_236 && currentPrice <= fib_50) {
      //+--------------------------- IMPORTANT? ---------------------------+
      if (currentPrice <= fib_50 && currentPrice >= fib_1)
      {
         // if(currentPrice >= fib_50 && currentPrice <= fib_1) {
         Order_(ORDER_TYPE_SELL, lastLow, lastHigh, currentHigh);
      }
      //+------------------------------------------------------------------+
   }
}

// ORDER CONDITIONS
void OrderConditions_V2()
{
   if (fvg.type_ == FVG_NONE)
   {
      return;
   }

   int sell_total = SellTotal();
   int buy_total = BuyTotal();

   datetime time_ = iTime(Symbol(), Period(), 0);

   double kline = iSTORSI_KLINEGet(0);
   double dline = iSTORSI_DLINEGet(0);

   ENUM_FVGS storsi_significance_state_ = FVG_NONE;
   if (kline > dline)
   {
      storsi_significance_state_ = FVG_BULLISH;

      // BUY ONLY kline & dline under 20
      if (STORSI_WHEN_OVERBOUGHT_OVERSOLD == true)
      {
         if (kline < 20 && dline < 20)
         {
            storsi_significance_state_ = FVG_BULLISH;
         }
         else
         {
            storsi_significance_state_ = FVG_NONE;
         }
      }
   }
   else
   {
      storsi_significance_state_ = FVG_BEARISH;
      // BUY ONLY kline & dline under 20
      if (STORSI_WHEN_OVERBOUGHT_OVERSOLD == true)
      {
         if (kline > 80 && dline > 80)
         {
            storsi_significance_state_ = FVG_BEARISH;
         }
         else
         {
            storsi_significance_state_ = FVG_NONE;
         }
      }
   }

   if (fvg.type_ == FVG_BULLISH && buy_total < MAX_BUY_TOTAL_INT && storsi_significance_state_ == FVG_BULLISH && HAS_BULLISH_FVG_(0, ANALYSER_TIMEFRAME))
   {

      if (USE_FIBO_BOOL == true)
      {

         // FIBO ?
         double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double currentLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 0);

         double fib_1618 = FibLevel(lastHigh, lastLow, 1.618); // FOR TP
         double fib_1 = FibLevel(lastHigh, lastLow, 1);
         double fib_786 = FibLevel(lastHigh, lastLow, 0.786);
         // double fib_618 = FibLevel(lastHigh, lastLow, 0.618);
         double fib_50 = FibLevel(lastHigh, lastLow, 0.5);
         double fib_236 = FibLevel(lastHigh, lastLow, 0.236);

         double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ BID);

         if (currentPrice >= fib_50 && currentPrice <= fib_1)
         {
            Order_(ORDER_TYPE_BUY, lastLow, lastHigh, currentLow);
         }
      }
      else
      {
         Order_(ORDER_TYPE_BUY);
      }
   }
   else if (fvg.type_ == FVG_BEARISH && sell_total < MAX_SELL_TOTAL_INT && storsi_significance_state_ == FVG_BEARISH && HAS_BEARISH_FVG_(0, ANALYSER_TIMEFRAME))
   {

      if (USE_FIBO_BOOL == true)
      {
         // FIBO ?
         double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double currentHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 0);

         double fib_236 = FibLevelForSell(lastHigh, lastLow, 0.236);
         // double fib_382 = FibLevelForSell(lastHigh, lastLow, 0.382);
         double fib_50 = FibLevelForSell(lastHigh, lastLow, 0.5);
         // double fib_618 = FibLevelSorSell(lastHigh, lastLow, 0.618);
         // double fib_786 = FibLevelForSell(lastHigh, lastLow, 0.786);
         double fib_1 = FibLevelForSell(lastHigh, lastLow, 1);
         double fib_1618 = FibLevelForSell(lastHigh, lastLow, 1.618);

         double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ ASK);

         if (currentPrice <= fib_50 && currentPrice >= fib_1)
         {
            // if(currentPrice >= fib_50 && currentPrice <= fib_1) {
            Order_(ORDER_TYPE_SELL, lastLow, lastHigh, currentHigh);
         }
      }
      else
      {
         Order_(ORDER_TYPE_SELL);
      }
   }
}

//+------------------------------------------------------------------+
//| FIBONACCI RETREATMENT                                            |
//+------------------------------------------------------------------+
double FibLevel(double high, double low, double ratio)
{
   return low + (high - low) * ratio;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FibLevelForSell(double high, double low, double ratio)
{
   return high - (high - low) * ratio;
}

//// NEED LOOPBACK TO GET LAST CROSS UP STATE
// void  UpdateRriSignificanceState()
//   {
//    double rsi0 = iRSIGet(0);
//    double rsi1 = iRSIGet(1);
//
//// ! ----------------------------------------- SIGNIFICANCE ----------------------------------------- |
//// - CROSS_UP_30 (BUY NOW)
//   if(rsi1 < 30 && rsi0 > 30)
//     {
//      fvg.rsi_significance_state_ = FVG_BULLISH;
//     }
//// - CROSS_DOWN_70 (SELL NOW)
//   else
//      if(rsi1 > 70 && rsi0 < 70)
//        {
//         fvg.rsi_significance_state_ = FVG_BEARISH;
//        }
//      // - CROSS_UP_50 (BUY)
//      else
//         if(rsi1 < 50 && rsi0 > 50)
//           {
//            fvg.rsi_significance_state_ = FVG_BULLISH;
//           }
//         // - CROSS_DOWN_50 (SELL)
//         else
//            if(rsi1 > 50 && rsi0 < 50)
//              {
//               fvg.rsi_significance_state_ = FVG_BEARISH;
//              }
//  }

//// iRSI loopback
// bool iRSILoopbacks()
//   {
//    double rsi0=0;
//    double rsi1=0;
//    int i=0;
//    bool res=false;
//
//    for(i=0; i<100; i++)
//      {
//       rsi0=iRSIGet(0 + i);
//       rsi1=iRSIGet(1 + i);
//
//       // ! ----------------------------------------- SIGNIFICANCE ----------------------------------------- |
//       // - CROSS_UP_30 (BUY NOW)
//       if(rsi1<30 && rsi0>30)
//         {
//          fvg.rsi_significance_state_ = FVG_BULLISH;
//          RSI0_=rsi0;
//          RSI1_=rsi1;
//          res=true;
//          break;
//         }
//       // - CROSS_DOWN_70 (SELL NOW)
//       else
//          if(rsi1 > 70 && rsi0 < 70)
//            {
//             fvg.rsi_significance_state_ = FVG_BEARISH;
//             RSI0_=rsi0;
//             RSI1_=rsi1;
//             res=true;
//             break;
//            }
//          // - CROSS_UP_50 (BUY)
//          else
//             if(rsi1 < 50 && rsi0 > 50)
//               {
//                fvg.rsi_significance_state_ = FVG_BULLISH;
//                RSI0_=rsi0;
//                RSI1_=rsi1;
//                res=true;
//                break;
//               }
//             // - CROSS_DOWN_50 (SELL)
//             else
//                if(rsi1 > 50 && rsi0 < 50)
//                  {
//                   fvg.rsi_significance_state_ = FVG_BEARISH;
//                   RSI0_=rsi0;
//                   RSI1_=rsi1;
//                   res=true;
//                   break;
//                  }
//      }
//
//    if(i > 100)
//      {
//       PrintFormat("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
//       Alert("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
//      }
//
//    return(res);
//   }

//  // iSTORSI loopback
// bool iSTORSILoopbacks()
//  {
//
//
////   if (isSignalLine)
////        CopyBuffer(iStochastic(_Symbol, _Period, KPeriod, DPeriod, 3, MODE_SMA, 0, applied_price), 1, shift, 1, stoch);
////    else
////        CopyBuffer(iStochastic(_Symbol, _Period, KPeriod, DPeriod, 3, MODE_SMA, 0, applied_price), 0, shift, 1, stoch);
////
//  xx
//   double rsi0=0;
//   double rsi1=0;
//   int i=0;
//   bool res=false;
//
//   for(i=0; i<100; i++)
//     {
//      rsi0=iRSIGet(0 + i);
//      rsi1=iRSIGet(1 + i);
//
//      // ! ----------------------------------------- SIGNIFICANCE ----------------------------------------- |
//      // - CROSS_UP_30 (BUY NOW)
//      if(rsi1<30 && rsi0>30)
//        {
//         fvg.rsi_significance_state_ = FVG_BULLISH;
//         RSI0_=rsi0;
//         RSI1_=rsi1;
//         res=true;
//         break;
//        }
//      // - CROSS_DOWN_70 (SELL NOW)
//      else
//         if(rsi1 > 70 && rsi0 < 70)
//           {
//            fvg.rsi_significance_state_ = FVG_BEARISH;
//            RSI0_=rsi0;
//            RSI1_=rsi1;
//            res=true;
//            break;
//           }
//         // - CROSS_UP_50 (BUY)
//         else
//            if(rsi1 < 50 && rsi0 > 50)
//              {
//               fvg.rsi_significance_state_ = FVG_BULLISH;
//               RSI0_=rsi0;
//               RSI1_=rsi1;
//               res=true;
//               break;
//              }
//            // - CROSS_DOWN_50 (SELL)
//            else
//               if(rsi1 > 50 && rsi0 < 50)
//                 {
//                  fvg.rsi_significance_state_ = FVG_BEARISH;
//                  RSI0_=rsi0;
//                  RSI1_=rsi1;
//                  res=true;
//                  break;
//                 }
//
//     }
//
//   if(i > 100)
//     {
//      PrintFormat("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
//      Alert("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
//     }
//
//   return(res);
//  }

//// ON CHART EVENT
// void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
//   {
//    if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam, "buttonNotifyOnOff") >= 0)
//      {
//       Print("buttonNotifyOnOff clicked");
//       Sleep(20);
//       ObjectSetInteger(0, sparam, OBJPROP_STATE, false);//
//       // PositionCloseAll();
//       NOTIFY_BOOL=!NOTIFY_BOOL;
//       string str_ = NOTIFY_BOOL==true ? "TRUE" : "FALSE";
//       ObjectSetString(0, buttonNotifyOnOff, OBJPROP_TEXT, "NOTIFY: " + str_);
//      }
//   }

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

//// Just Update STORSI
void OnTimer(void)
{
   double kline = iSTORSI_KLINEGet(0);
   double dline = iSTORSI_DLINEGet(0);
   if (kline > dline)
   {
      fvg.storsi_significance_state_ = FVG_BULLISH;
   }
   else
   {
      fvg.storsi_significance_state_ = FVG_BEARISH;
   }
   UpdateIsFridayNightSaturdaySunday();
}

// CHANGE TIME LABEL IN 30 SECS ?
void UpdateIsFridayNightSaturdaySunday()
{
   bool res = false;
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime dt;
   TimeToStruct(time, dt);

   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)FRIDAY && dt.hour >= 20)
   {
      res = true;
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SATURDAY)
   {
      res = true;
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SUNDAY)
   {
      res = true;
   }
   IS_FRIDAYNIGHT_SATURDAY_SUNDAY = res;

   // UPDATE TIME EVERY 30 SECS ?
   datetime datetime_ = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime dt_;
   TimeToStruct(datetime_, dt_);
   string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);

   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week + " " + (string)datetime_);
   // if(IS_FRIDAYNIGHT_SATURDAY_SUNDAY==true) {
   //    Comment("\n\n WEEKEND ... "); // , day_of_week + " " + (string)datetime_);
   // }
}

// Look current time
void iSTORSILoopbacks()
{
   double kline = iSTORSI_KLINEGet(0);
   double dline = iSTORSI_DLINEGet(0);

   if (kline > dline)
   {
      fvg.storsi_significance_state_ = FVG_BULLISH;
   }
   else
   {
      fvg.storsi_significance_state_ = FVG_BEARISH;
   }

   fvg.storsi_kline_prev_ = kline;
   fvg.storsi_dline_prev_ = dline;

   // string str_ = NOTIFY_BOOL==true ? "TRUE" : "FALSE";
   // ObjectSetString(0, buttonNotifyOnOff, OBJPROP_TEXT, "NOTIFY: " + str_);
}

//// UTILITY FUNCTIONS
// void PrintInfo() {
//// REMOVE UNNECCESSARY ?
//// datetime time_ = iTime(Symbol(), Period(), 0);
//   string comment_ = "\n\n"; // + (string)time_;
//   ENUM_TIMEFRAMES period    = Period();
//
////input bool                          USE_CUTOFF=true;
////input bool                          USE_UPDATE_SL_FROM_ATR=true;
//
//   string ments_ = StringFormat(
//                      "\n\nLEVERAGE                                                         %i " +
//                      "\n\nLAST CHANGE                                                  - SHOW/HIDE FVG MARKER"
//                      ,
//                      ACCOUNT_LEVERAGE_
//                   );
//   comment_ += ments_;
//
//   if(GetLastError() > 0) {
//      string err_ = StringFormat("\nERROR: %i \n\n", GetLastError());
//      comment_ = err_ + comment_;
//   }
//   Comment(comment_);
//
//// ObjectSetString(0, buttonEntryFVG, OBJPROP_TEXT, "efvg:" + FvgTypeToString(fvg.type_) + "/" + (string)fvg.time_);
//
////if(fvg.type_ == FVG_BULLISH)
////  {
////   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_COLOR, clrGreen);
////  }
////else
////   if(fvg.type_ == FVG_BEARISH)
////     {
////      ObjectSetInteger(0, buttonEntryFVG, OBJPROP_COLOR, clrRed);
////     }
////   else
////     {
////      ObjectSetInteger(0, buttonEntryFVG, OBJPROP_COLOR, clrSilver);
////     }
//
//
////MqlDateTime dt_;
////TimeToStruct(time_, dt_);
////string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
////ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week + " " + (string)time_);
//
////   if(PositionsTotal() != 1)
////     {
////      return;
////     }
////
////   MqlTick tick[1] = {};
////   if(!SymbolInfoTick(_Symbol, tick[0]))
////     {
////      Print("SymbolInfoTick() failed. Error ", GetLastError());
////      return;
////     }
//
//} // void PrintInfo()

// INIT ANALYSER ATR // Get new ATR when PositionTotal > 0 only
bool iATRGet()
{
   int index = ATR_shift;
   double ATR[1];
   ResetLastError();
   if (CopyBuffer(ATR_handle, 0, index, 1, ATR_buffer) < 0)
   {
      int err_ = GetLastError();
      PrintFormat("Failed to copy data from the iATR indicator, error code %d", GetLastError());
   }
   else
   {
      fvg.atr_ = ATR_buffer[0];
   }
   // ObjectSetString(0, buttonATR, OBJPROP_TEXT, StringFormat("ATR: %.3f", NormalizeDouble(fvg.atr_, _Digits)));

   return true;
}

//// | RSI GET |
// double iRSIGet(const int index)
//   {
//// double RSI[1];
////--- reset error code
//   ResetLastError();
////--- fill a part of the iRSI array with values from the indicator buffer that has 0 index
//   int res=CopyBuffer(RSI_handle,0,index,1, RSI_buffer);
//   if(res<0)
//     {
//      //--- if the copying fails, tell the error code
//      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
//      //--- quit with zero result - it means that the indicator is considered as not calculated
//      return(0.0);
//     }
//   return(RSI_buffer[0]);
//  }

// | STORSI GET |
// %K line (fast-moving) - BLUE
// %D line (signal line) - ORANGE
double iSTORSI_KLINEGet(int shift = 0)
{
   ResetLastError();
   //   if (isSignalLine)
   //       CopyBuffer(iStochastic(_Symbol, _Period, KPeriod, DPeriod, 3, MODE_SMA, 0, applied_price), 1, shift, 1, stoch); <------------- D LINE
   //   else
   //       CopyBuffer(iStochastic(_Symbol, _Period, KPeriod, DPeriod, 3, MODE_SMA, 0, applied_price), 0, shift, 1, stoch); <------------- K LINE

   int res = CopyBuffer(STORSI_handle, 0, shift, 1, STORSI_buffer);
   if (res < 0)
   {
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
      return (0.0);
   }
   return (STORSI_buffer[0]);
}
// L LINE = SIGNAL LINE = ORANGE ?
double iSTORSI_DLINEGet(int shift = 0)
{
   ResetLastError();
   int res = CopyBuffer(STORSI_handle, 1, shift, 1, STORSI_buffer);
   if (res < 0)
   {
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
      return (0.0);
   }
   return (STORSI_buffer[0]);
}

// Detect Bearish Fair Value Gap (FVG)
bool IsBullishFVG(int shift = 0)
{
   double high2Ago = iHigh(_Symbol, PERIOD_CURRENT, 2 + shift);
   double lowNow = iLow(_Symbol, PERIOD_CURRENT, 0 + shift);
   datetime time_ = iTime(_Symbol, PERIOD_CURRENT, 0);

   if (high2Ago < lowNow)
   {
      fvg.type_ = FVG_BULLISH;
      fvg.top_ = lowNow;
      fvg.bottom_ = high2Ago;
      fvg.time_ = time_;

      if (SHOW_FVG_MARKER == true)
      {
         DrawFVGMarker(shift, true);
      }

      // PositionsTrailing();
   }

   return (high2Ago < lowNow);
}

// Detect Bullish Fair Value Gap (FVG)
bool IsBearishFVG(int shift = 0)
{
   double low2Ago = iLow(_Symbol, PERIOD_CURRENT, 2 + shift);
   double highNow = iHigh(_Symbol, PERIOD_CURRENT, 0 + shift);
   datetime time_ = iTime(_Symbol, PERIOD_CURRENT, 0);

   if (low2Ago > highNow)
   {
      fvg.type_ = FVG_BEARISH; // "bearish";
      fvg.top_ = low2Ago;
      fvg.bottom_ = highNow;
      fvg.time_ = time_;

      if (SHOW_FVG_MARKER == true)
      {
         DrawFVGMarker(shift, false);
      }

      // PositionsTrailing();
   }

   return (low2Ago > highNow);
}

// Calculate Fibonacci Extension Take Profit for Buy
double GetFibonacciTP(ENUM_ORDER_TYPE order_type, double swing_low, double swing_high, double retrace)
{

   if (order_type == ORDER_TYPE_BUY)
   {

      double diff = swing_high - swing_low;
      double tp127 = retrace + (diff * 1.272);
      double tp1618 = retrace + (diff * 1.618);
      // return tp127; // or tp1618
      // return NormalizeDouble(tp1618,_Digits);
      if (TP_FROM_FIBONACCI_EXTENSION_OPTIONS == 1)
      {
         return NormalizeDouble(tp127, _Digits);
      }
      return NormalizeDouble(tp1618, _Digits);
   }
   else
   {
      double diff = swing_high - swing_low;
      double tp127 = retrace - (diff * 1.272);
      double tp1618 = retrace - (diff * 1.618);
      // return tp127; // or tp1618
      // return NormalizeDouble(tp1618,_Digits);
      if (TP_FROM_FIBONACCI_EXTENSION_OPTIONS == 1)
      {
         return NormalizeDouble(tp127, _Digits);
      }
      return NormalizeDouble(tp1618, _Digits);
   }
}

// Entry Order Buy/Sell
void Order_(ENUM_ORDER_TYPE order_type, double swing_low = 0, double swing_high = 0, double retrace = 0)
{

   // BALANCE_MINIMUM_ALLOWED
   double balance_ = AccountInfoDouble(ACCOUNT_BALANCE);
   double balance_mininum_allowed_ = BALANCE_MINIMUM_ALLOWED;
   if (balance_ < BALANCE_MINIMUM_ALLOWED)
   {
      return;
   }

   double ask_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
   double bid_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
   double spread_ = MathAbs(ask_ - bid_);
   double lots = 0;

   if (order_type == ORDER_TYPE_BUY)
   {
      // XX ONDEMAND ATR?
      iATRGet();
      double atr_ = fvg.atr_;
      if (atr_ <= 0)
      {
         return;
      }
      double sl_ = NormalizeDouble(bid_ - (atr_ * ATR_multiply), _Digits);
      if (SL_FROM_SWING_OR_ATR == 0)
      {
         sl_ = NormalizeDouble(retrace, _Digits);
      }
      else if (SL_FROM_SWING_OR_ATR == -1)
      {
         sl_ = NormalizeDouble(swing_low, _Digits);
      }

      // ALSO SET TP IN BAD CASE
      double tp_ = 0.0;
      if (TP_FROM_FIBONACCI_EXTENSION_OPTIONS > 0 && retrace > 0)
      {
         tp_ = GetFibonacciTP(order_type, swing_low, swing_high, retrace);
      }
      else
      {
         tp_ = NormalizeDouble(bid_ + (atr_ * ATR_multiply * RR), _Digits);
      }

      lots = LotSize_();
      if (lots > 0)
      {
         trade.Buy(lots, _Symbol, ask_, sl_, tp_);
         SendMail_(ORDER_TYPE_BUY);
      }
   }
   else if (order_type == ORDER_TYPE_SELL)
   {
      // XX ONDEMAND ATR?
      iATRGet();
      double atr_ = fvg.atr_;
      if (atr_ <= 0)
      {
         return;
      }
      double sl_ = 0.0;
      sl_ = NormalizeDouble(ask_ + (atr_ * ATR_multiply), _Digits);
      if (SL_FROM_SWING_OR_ATR == 0)
      {
         // sl_=NormalizeDouble(swing_high, _Digits);
         sl_ = NormalizeDouble(retrace, _Digits);
      }
      else if (SL_FROM_SWING_OR_ATR == -1)
      {
         sl_ = NormalizeDouble(swing_high, _Digits);
      }

      // ALSO SET TP IN BAD CASE
      double tp_ = 0.0;
      if (TP_FROM_FIBONACCI_EXTENSION_OPTIONS > 0 && retrace > 0)
      {
         tp_ = GetFibonacciTP(order_type, swing_low, swing_high, retrace);
      }
      else
      {
         tp_ = NormalizeDouble(ask_ - (atr_ * ATR_multiply * RR), _Digits);
      }

      lots = LotSize_();
      if (lots > 0)
      {
         trade.Sell(lots, _Symbol, bid_, sl_, tp_);
         SendMail_(ORDER_TYPE_SELL);
      }
   }
}

// TRAILING STOP
void PositionsUpdateSLfromATR()
{
   if (PositionsTotal() > 0)
   {
      for (int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket))
         {
            string symbol = PositionGetString(POSITION_SYMBOL);
            if (symbol == _Symbol)
            {
               double sl_price = PositionGetDouble(POSITION_SL);
               long position_type = PositionGetInteger(POSITION_TYPE);
               double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
               // double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
               double ask_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
               double bid_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
               double spread_ = MathAbs(ask_ - bid_);
               double ask_bid_everage_ = (ask_ + bid_) / 2;

               // XX ONDEMAND ATR
               if (USE_DYNAMIC_ATR == true)
               {
                  iATRGet(); // OPTIMIZATION? DYNAMIC ATR UNCOMMENT THIS LINE
               }

               double atr_ = fvg.atr_;

               if (MathAbs(ask_bid_everage_ - sl_price) > (atr_ * ATR_multiply * 2))
               {
                  if (position_type == POSITION_TYPE_BUY)
                  {
                     double stop_loss_price = bid_ - (atr_ * ATR_multiply);
                     trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), 0);
                  }
                  else if (position_type == POSITION_TYPE_SELL)
                  {
                     double stop_loss_price = ask_ + (atr_ * ATR_multiply);
                     trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), 0);
                  }
               }
            }
         }
      }
   }
}

//// POSITION TRAILING AUTOMATIC ?
//// UPDATE SL IMMEDIATELY WHEN NEW FVG OCCUR AND PROFIT IS GET BETTER
// void PositionsTrailing() {
//    if(PositionsTotal() > 0) {
//       for(int i = 0; i < PositionsTotal(); i++) {
//          ulong ticket = PositionGetTicket(i); // --------------------------------
//          if(PositionSelectByTicket(ticket)) {
//             string symbol = PositionGetString(POSITION_SYMBOL);
//             if(symbol == _Symbol) {
//                double sl_price = PositionGetDouble(POSITION_SL);
//                long position_type = PositionGetInteger(POSITION_TYPE);
//                double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
//                // double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
//                double position_profit = PositionGetDouble(POSITION_PROFIT); // from above line 570
//                double ask_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
//                double bid_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
//                long position_time_update = PositionGetInteger(POSITION_TIME_UPDATE);
//                double spread_ = MathAbs(ask_ - bid_);
//                double ask_bid_everage_ = (ask_ + bid_)/2;
//
//                //  -10
//                //if (MININUM_PROFIT_ALLOW_BOOL == true && position_profit < MININUM_PROFIT_ALLOW_USD )
//                //   {
//                //      // close this ticket
//                //      PositionCloseV6(ticket);
//                //      PositionDataDelete(ticket);
//                //      continue;
//                //   }
//
//                //if ( (USE_CUTOFF == true) && (position_profit < CUTOFF_LOSS_USD || position_profit > CUTOFF_PROFIT_USD) )
//                //  {
//                //   PositionCloseV6(ticket);
//                //   PositionDataDelete(ticket);
//                //   Print("");
//                //   Alert(StringFormat("------------- > close ticketid: %d with profit: %.2f ", ticket, position_profit));
//                //   Print("");
//                //   continue;
//                //  }
//
//                if((USE_CUTOFF_LOSS_BOOL == true) && position_profit < CUTOFF_LOSS_USD) {
//                   PositionCloseV6(ticket);
//                   PositionDataDelete(ticket);
//                   continue;
//                }
//
//                if((USE_CUTOFF_PROFIT_BOOL == true) && position_profit > CUTOFF_PROFIT_USD) {
//                   PositionCloseV6(ticket);
//                   PositionDataDelete(ticket);
//                   continue;
//                }
//
//                // UPDATE SL IF PROFIT INCREASE
//                // bool database_check=DatabaseInsert(ticket, position_profit);
//                bool memory_check=PositionDataInsertOrUpdate(ticket, position_profit, position_time_update);
//                if(memory_check==false) {
//                   // check invalid ?
//                   // return; // <---------------- WRONG
//                   continue; // next for
//                }
//
//                // XX ONDEMAND ATR
//                if(USE_DYNAMIC_ATR==true) {
//                   iATRGet(); // OPTIMIZATION? DYNAMIC ATR UNCOMMENT THIS LINE
//                }
//
//                double atr_ = fvg.atr_;
//
//                if(MathAbs(ask_bid_everage_ - sl_price) > (atr_ * ATR_ multiply * 2)) {
//                   if(position_type == POSITION_TYPE_BUY) {
//                      double stop_loss_price = bid_ - (atr_ * ATR_ multiply);
//                      double tp_price = bid_ + (atr_ * ATR_ multiply);
//                      trade .PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), NormalizeDouble(tp_price, _Digits));
//
//
//                   } else if(position_type == POSITION_TYPE_SELL) {
//                      double stop_loss_price = ask_ + (atr_ * ATR_ multiply);
//                      double tp_price = ask_ - (atr_ * ATR_ multiply);
//                      trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), NormalizeDouble(tp_price, _Digits));
//
//
//                   }
//                }
//             }
//          }
//       }
//    }
// }

//+------------------------------------------------------------------+
void SendMail_(ENUM_ORDER_TYPE order_type)
{

   // if(NOTIFY_BOOL==false) {
   return;
   //}

   //--- check permission to send email in the terminal
   if (!TerminalInfoInteger(TERMINAL_EMAIL_ENABLED))
   {
      Print("Error. The client terminal does not have permission to send email messages");
      return;
   }

   //--- send mail
   ResetLastError();
   string SUBJECT = "SELL SUBJECT";
   string TEXT = "SELL TEXT";
   if (order_type == ORDER_TYPE_BUY)
   {
      SUBJECT = "BUY SUBJECT" + _Symbol + "BUY NOW!";
      TEXT = _Symbol + "BUY NOW!";
   }

   if (!SendMail(SUBJECT, TEXT))
   {
      Print("SendMail() failed. Error ", GetLastError());
   }
}

// GENERIC LOT SIZE CALCULATION
double LotSize_()
{

   // US30Cash
   string sym_name = _Symbol;
   if (StringToUpper(sym_name))
   {

      // BALANCE 10000
      // GOLD                 -> ? 1 lots(winrate > 90% ?)
      // BTCUSD               -> 4 - 5 LOTS
      // US30CASH US100CASH   -> 1 - 2 LOTS

      if (sym_name == "US30CASH" || sym_name == "US100CASH" || sym_name == "BTCUSD#")
      {
         return POSITION_SIZE_DOUBLE;
      }
   }

   // #ifdef not DEBUG
   if (SYMBOL_VOLUME_MIN_ < 0.1)
   {
      return POSITION_SIZE_DOUBLE;
   }
   else
   {
      return SYMBOL_VOLUME_MIN_;
   }
   // #endif

   double percentage_to_lose = 5; //   SELL_BU sell_buy_percent;
                                  // double entry_price, double stop_loss_price, double percentage_to_lose

   // Get Symbol Info
   double lots_maximum = SYMBOL_VOLUME_MAX_;     // SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double lots_minimum = SYMBOL_VOLUME_MIN_;     // SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double volume_step = SYMBOL_VOLUME_STEP_;     // SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   double tick_size = SYMBOL_TRADE_TICK_SIZE_;   // SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SYMBOL_TRADE_TICK_VALUE_; // SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);

   // Get trade basic info
   double available_capital = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_BALANCE)), AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   double amount_to_risk = available_capital * percentage_to_lose / 100;

   // double sl_distance = MathAbs(entry_price - stop_loss_price); // Get the Abs since it might be a short (EP < SL)
   // ATR ?
   // XX ONDEMAND ATR?

   double sl_distance = fvg.atr_ * ATR_multiply;

   // Calculate steps and lots
   double money_step = sl_distance / tick_size * tick_value * volume_step;
   double lots = fmin(lots_maximum, fmax(lots_minimum, NormalizeDouble(amount_to_risk / money_step * volume_step, 2)));
   // The number 2 is due to my brokers volume step, depends on the currency pair
   // double normal_lots = NormalizeDouble(lots, 2);

   // https://www.mql5.com/en/forum/189533
   // double normal_lots = ((int)MathFloor(lots * 100)) / 100;
   int lot_digits = 3;
   if (lots_minimum == 0.001)
      lot_digits = 3;
   if (lots_minimum == 0.01)
      lot_digits = 2;
   if (lots_minimum == 0.1)
      lot_digits = 1;

   double double_lots_ = lots * 100;
   int int_lots_ = (int)double_lots_;
   double normal_lots_ = (double)int_lots_ / 100;
   double real_lots = NormalizeDouble(normal_lots_, lot_digits);

   if (real_lots < 0.01)
   {
      return 0.01;
   }

   return (real_lots);
}

//| Refreshes the symbol quotes data                                 |
bool RefreshRates()
{
   //--- refresh rates
   if (!m_symbol.RefreshRates())
      return (false);
   //--- protection against the return value of "zero"
   if (m_symbol.Ask() == 0 || m_symbol.Bid() == 0)
      return (false);
   //---
   return (true);
}

//+------------------------------------------------------------------+
