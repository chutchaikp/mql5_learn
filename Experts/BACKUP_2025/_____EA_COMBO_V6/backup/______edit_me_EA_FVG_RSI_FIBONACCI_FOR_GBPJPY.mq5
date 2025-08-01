//+------------------------------------------------------------------+
//|                                 EA_FVG_RSI_FIBONACCI_FOR_GBPJPY.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// COPY FROM EA_FVG_MEMORY_RSI_FIBONACCI

// CHANGES:

// TRY TO APPLY FIBO
// ENTRY TIMEFRAME IS M5 ?

// - ADD ON TIMER FOR UPDATE RSI1 & RSI0

// ADD RSI
// - CROSS_UP_30 (BUY NOW)
// - CROSS_DOWN_70 (SELL NOW)
// - CROSS_UP_50 (BUY)
// - CROSS_DOWN_50 (SELL)

// CUTOFF  ONLY IF position_profit < MININUM_PROFIT_ALLOW_USD (LOSS) <-------------------------
// IF PROFIT DO NOTHING       ... <-------------------------
// OK //OK //OK
// - SET TP (TAKE PROFIT)     ... <-------------------------

// - Cal lot size from balance OnInit
//    x 1000 usd -- 0.01
//    x 2000 usd -- 0.02

// - ADD USE_EMA200_BOOL INPUT
// - Authorized
// - Remove Unneccsary ....
// - CUTOFF PROFIT > 100 USD ----10%--- CLOSE POSITION NOW!
// - CUTOFF PROFIT < -50 USD ----05%--- CLOSE POSITION NOW!
// - ATR to PIP instead ? <--------- NOT CHANGE
// - CHANGE TO POSITION LIST MANIPULATE IN MEMORY
// - close position when profit < -10
// - UPDATE SL/TP WHEN FOUND NEW FVG
// - ATR FROM ENTRY TIMEFRAME

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "66.66"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

#include <_ICT6.2\HELPER.mqh>
#include <_ICT6.2\ANALYSER_HELPER.mqh>

CSymbolInfo m_symbol;
// CPositionInfo               m_position;
// CTrade                      trade;

//+---------------------------------------------------------------------+
//|------------------------------<INPUTS>-------------------------------|
//+---------------------------------------------------------------------+
// input bool                          USE_CUTOFF=true;
// input bool                         USE_UPDATE_SL_FROM_ATR=true;

input ENUM_TIMEFRAMES TF_entry = PERIOD_M5; // ENTRY TIMEFRAME
input double ATR_multiply = 32;             // ATR_multiple(5-20)
// input bool                          LIMIT_trade_time        =false;
input bool LIMIT_TRADE_TIME_BOOL = false;
// input bool                          hold_on_WEEKEND         =false;
input bool HOLD_ON_WEEKEND_BOOL = false;
int ATR_shift = 0; // ATR shift(0 or 1)
int BALANCE_MINIMUM_ALLOWED = 500;
// input bool                          MININUM_PROFIT_ALLOW_BOOL=true;
// input int                           MININUM_PROFIT_ALLOW_USD=-10;

input int MAX_BUY_TOTAL_INT = 30;
input int MAX_SELL_TOTAL_INT = 30;

//--------------------------------------------------------------------//
//------------------------- MONEY MANAGEMENT TECHNIC------------------//
//--------------------------------------------------------------------//
// input double                        position_SIZE           =0.01; // LotSize(0.01-0.1)
// GBPJPY BALANCE: 100000 - LOTSIZE: 1
input double POSITION_SIZE_DOUBLE = 1;
input bool USE_CUTOFF_BOOL = true;
// input bool                                         USE_CUTOFF_LOSS_BOOL=true;
// input bool                                         USE_CUTOFF_PROFIT_BOOL=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double CUTOFF_LOSS_USD = -40;   // CUTOFF LOSS USD(-10 TO -50)
input double CUTOFF_PROFIT_USD = 200; // CUTOFF PROFIT USD(50 TO 200)

// 1-waitconfitm, 0-nowait
// input int                           fvg_shift               =0;
int FVG_SHIFT_INT = 0; // FVG shift(0 OR 1)

// input bool                          USE_EMA200_BOOL         =true;
// ENUM_TIMEFRAMES         TIMEFRAME_EMA200  =PERIOD_M10;

// cannot be input ?
double RSI0_ = -1;
double RSI1_ = -1;

// 30 60 90 UPDATE RSI SIG STATE EVERY X SECONDS
// input int                           TIMER_PERIOD_INT=30;
// Timer Update Interval
// 30
input int RSI_TIMER_UPDATE_INTERVAL_INT = 30;

// | RSI INPUT |
int RSIPeriod = 14;
int RSIOverSold = 30;
int RSIOverBought = 70;

// input ENUM_TIMEFRAMES RSITF  = PERIOD_H4;
input ENUM_TIMEFRAMES RSI_TIMEFRAME = PERIOD_H3;

// | Filter SESSION ? |
// input bool     LimitTradingTime  =false;
bool FilterWithTradingTime = false;

// int      LondonStartHour   =10;
int LondonStartHour = 9;
int LondonEndHour = 14;
int NYStartHour = 15;
int NYEndHour = 19;

bool USE_TRAILING_BOOL = true;

input ENUM_TIMEFRAMES FIBONACCI_TIMEFRAME = PERIOD_H1;
input ENUM_TIMEFRAMES ANALYSER_TIMEFRAME = PERIOD_H1;

//_______________________________</INPUTS>_______________________________

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

double RSI_buffer[];
int RSI_handle;

FVG fvg = {FVG_NONE, 0, 0, __DATETIME__, 0};

// int                           risk_percent=10;
// int                           position_maximum=2; // Maximum position 1

datetime lastbar_timeopen = __DATETIME__; // IS NEW BAR, LOR_;
string analyser_fvg_info = "";            // bullish_fvg, bearish_fvg
string analyse_price_action_info = "";    // bullish_engulfing, bearish_engulfing ? harami

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

   // DebugBreak();

   ResetLastError();

   // if (ASYNC_MODE==true)
   //    {
   //       trade.SetAsyncMode(true); // no wait other
   //    }

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

   //| RSI |
   RSI_handle = iRSI(_Symbol, RSI_TIMEFRAME, RSIPeriod, PRICE_CLOSE);
   if (RSI_handle == INVALID_HANDLE)
   {
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(Period()), GetLastError());
      return (INIT_FAILED);
   }
   fvg.rsi_significance_state_ = FVG_NONE;

   EventSetTimer(RSI_TIMER_UPDATE_INTERVAL_INT);

   Sleep(1000);

   iRSILoopbacks();

   //| /RSI |

   // DatabaseConnect();
   // Comment( StringFormat("ASYNC MODE      %s", ASYNC_MODE == true ? "TRUE" : "FALSE" ));

   return (INIT_SUCCEEDED);
}

// CLEAN UP
void OnDeinit(const int reason)
{
   Comment("");

   EventKillTimer();

   // clear objects
   ObjectsDeleteAll(0);
}

void OnTick()
{

   // iRSILoopbacks();

   // if(USE_CUTOFF == true)
   //{

   if (USE_TRAILING_BOOL == true)
   {
      PositionsTrailing();
   }

   // UPDATE RSI EVERY TICK ?
   // UpdateRriSignificanceState();

   //}

   // if(USE_UPDATE_SL_FROM_ATR == true)
   //{
   // PositionsUpdateSLfromATR();
   // }

   if (HOLD_ON_WEEKEND_BOOL == false && IsFridayNightSaturdaySunday() == true)
   {
      if (PositionsTotal() > 0)
      {
         PositionCloseAllV1();
      }
      // datetime datetime_ = iTime(_Symbol,PERIOD_CURRENT,0);
      // MqlDateTime dt_;
      // TimeToStruct(datetime_, dt_);
      // string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
      // ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week + " " + (string)datetime_);
      // Comment("\n\n WEEKEND ... ", day_of_week + " " + (string)datetime_);
      return;
   }

   if (InTimeRangeV1() == false && LIMIT_TRADE_TIME_BOOL == true)
   {
      if (PositionsTotal() > 0)
      {
         PositionCloseAllV1();
      }
      // Comment(StringFormat("\n\nWAIT..... UNTIL HOUR AT: %i ", hour_start));
      return;
   }

   // if(FilterWithTradingTime==true && IsInSession()==false)
   //   {
   //    if(PositionsTotal() > 0)
   //      {
   //       PositionCloseAllV1();
   //       return;
   //      }
   //   }

   if (IsNewBar(lastbar_timeopen))
   {

      PositionInMemoryClear();

      // ENTRY TIMEFRAME
      if (!IsBullishFVG(FVG_SHIFT_INT) && !IsBearishFVG(FVG_SHIFT_INT))
      {
         fvg.type_ = FVG_NONE;
         fvg.time_ = iTime(_Symbol, PERIOD_CURRENT, 0);
      }

      // PRINT INTO & ENTRY CONDITIONS
      // if (SHOW_COMMENT==true)
      //   {
      //      PrintInfo();
      //   }

      // OPEN POSITION NOW ?
      OrderConditions();
   }
}

//+------------------------------------------------------------------+
//| UPDATE RSI SIG STATE                                             |
//+------------------------------------------------------------------+
void OnTimer(void)
{

   // UPDATE ONLY RSI0_
   bool state_change = false;
   double rsi_last = iRSIGet(0);
   double rsi1 = RSI1_;

   if (rsi1 < 0)
   {
      RSI0_ = rsi_last;
      RSI1_ = rsi_last;
      return;
   }

   // double rsi0 = RSI0_; // iRSIGet(0);
   // double rsi1 = iRSIGet(1);

   // ! ----------------------------------------- SIGNIFICANCE ----------------------------------------- |
   // - CROSS_UP_30 (BUY NOW)
   if (rsi1 < 30 && rsi_last > 30)
   {
      fvg.rsi_significance_state_ = FVG_BULLISH;
      state_change = true;
   }
   // - CROSS_DOWN_70 (SELL NOW)
   else if (rsi1 > 70 && rsi_last < 70)
   {
      fvg.rsi_significance_state_ = FVG_BEARISH;
      state_change = true;
   }
   // - CROSS_UP_50 (BUY)
   else if (rsi1 < 50 && rsi_last > 50)
   {
      fvg.rsi_significance_state_ = FVG_BULLISH;
      state_change = true;
   }
   // - CROSS_DOWN_50 (SELL)
   else if (rsi1 > 50 && rsi_last < 50)
   {
      fvg.rsi_significance_state_ = FVG_BEARISH;
      state_change = true;
   }

   if (state_change == true)
   {
      RSI1_ = rsi_last;
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

// CHECK IS HOLIDAY, ALSO CLOSE POSITION ON FRIDAY NIGHT
bool IsFridayNightSaturdaySunday()
{
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime dt;
   TimeToStruct(time, dt);

   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)FRIDAY && dt.hour >= 20)
   {
      return (true);
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SATURDAY)
   {
      return true;
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SUNDAY)
   {
      return true;
   }

   return (false);
}

// ------ Trading Time Session ------
bool IsInSession()
{
   // if(!LimitTradingTime)
   //    return true;
   if (FilterWithTradingTime == false)
      return true;

   datetime timeServer = TimeCurrent();
   MqlDateTime t;
   TimeToStruct(timeServer, t);
   int hour = t.hour;

   bool inLondon = (hour >= LondonStartHour && hour < LondonEndHour);
   bool inNY = (hour >= NYStartHour && hour < NYEndHour);

   return (inLondon || inNY);
}
//+------------------------------------------------------------------+

// ORDER CONDITIONS
void OrderConditions()
{
   if (fvg.type_ == FVG_NONE)
   {
      return;
   }

   // FIBO ?
   // double lastHigh = iHigh(_Symbol, _Period, 1);
   // double lastLow = iLow(_Symbol, _Period, 1);
   // double fib_50 = FibLevel(lastHigh, lastLow, 0.5);
   // double fib_618 = FibLevel(lastHigh, lastLow, 0.618);
   // double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ BID);

   // bool has_buy = HasBuy();
   // bool has_sell = HasSell();
   // ENUM_TIMEFRAMES FIBONACCI_TIMEFRAME=PERIOD_H1;

   int sell_total = SellTotal();
   int buy_total = BuyTotal();

   if (fvg.type_ == FVG_BULLISH && buy_total < MAX_BUY_TOTAL_INT && HAS_BULLISH_FVG_(0, ANALYSER_TIMEFRAME))
   {
      // XXX GET LAST RSI SIGNIFICANCE STATE
      if (fvg.rsi_significance_state_ == FVG_BULLISH)
      {
         double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 1);
         double currentLow = iLow(_Symbol, FIBONACCI_TIMEFRAME, 0);

         double fib_1618 = FibLevel(lastHigh, lastLow, 1.618); // FOR TP
         double fib_1 = FibLevel(lastHigh, lastLow, 1);
         double fib_786 = FibLevel(lastHigh, lastLow, 0.786);
         double fib_50 = FibLevel(lastHigh, lastLow, 0.5);
         double fib_236 = FibLevel(lastHigh, lastLow, 0.236);

         double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ BID);

         if (currentPrice >= fib_50 && currentPrice <= fib_1)
         {
            Order_(ORDER_TYPE_BUY);
         }
      }
   }
   else if (fvg.type_ == FVG_BEARISH && sell_total < MAX_SELL_TOTAL_INT && HAS_BEARISH_FVG_(0, ANALYSER_TIMEFRAME))
   {
      if (fvg.rsi_significance_state_ == FVG_BEARISH)
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
            Order_(ORDER_TYPE_SELL);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
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

// iRSI loopback
bool iRSILoopbacks()
{
   double rsi0 = 0;
   double rsi1 = 0;
   int i = 0;
   bool res = false;

   for (i = 0; i < 100; i++)
   {
      rsi0 = iRSIGet(0 + i);
      rsi1 = iRSIGet(1 + i);

      // ! ----------------------------------------- SIGNIFICANCE ----------------------------------------- |
      // - CROSS_UP_30 (BUY NOW)
      if (rsi1 < 30 && rsi0 > 30)
      {
         fvg.rsi_significance_state_ = FVG_BULLISH;
         RSI0_ = rsi0;
         RSI1_ = rsi1;
         res = true;
         break;
      }
      // - CROSS_DOWN_70 (SELL NOW)
      else if (rsi1 > 70 && rsi0 < 70)
      {
         fvg.rsi_significance_state_ = FVG_BEARISH;
         RSI0_ = rsi0;
         RSI1_ = rsi1;
         res = true;
         break;
      }
      // - CROSS_UP_50 (BUY)
      else if (rsi1 < 50 && rsi0 > 50)
      {
         fvg.rsi_significance_state_ = FVG_BULLISH;
         RSI0_ = rsi0;
         RSI1_ = rsi1;
         res = true;
         break;
      }
      // - CROSS_DOWN_50 (SELL)
      else if (rsi1 > 50 && rsi0 < 50)
      {
         fvg.rsi_significance_state_ = FVG_BEARISH;
         RSI0_ = rsi0;
         RSI1_ = rsi1;
         res = true;
         break;
      }
   }

   if (i > 100)
   {
      PrintFormat("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
      Alert("NOT FOUND ANALYSE iRSILoopback IN LOOPBACK 50");
   }

   return (res);
}

// UTILITY FUNCTIONS
void PrintInfo()
{
   // REMOVE UNNECCESSARY ?
   // datetime time_ = iTime(Symbol(), Period(), 0);
   string comment_ = "\n\n"; // + (string)time_;
   ENUM_TIMEFRAMES period = Period();

   // input bool                          USE_CUTOFF=true;
   // input bool                          USE_UPDATE_SL_FROM_ATR=true;

   string ments_ = StringFormat(
       "\n\nLEVERAGE                                                         %i " +
           "\n\nLAST CHANGE                                                  - SHOW/HIDE FVG MARKER",
       ACCOUNT_LEVERAGE_);
   comment_ += ments_;

   if (GetLastError() > 0)
   {
      string err_ = StringFormat("\nERROR: %i \n\n", GetLastError());
      comment_ = err_ + comment_;
   }
   Comment(comment_);

} // void PrintInfo()

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

// | RSI GET |
double iRSIGet(const int index)
{
   // double RSI[1];
   //--- reset error code
   ResetLastError();
   //--- fill a part of the iRSI array with values from the indicator buffer that has 0 index
   int res = CopyBuffer(RSI_handle, 0, index, 1, RSI_buffer);
   if (res < 0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return (0.0);
   }
   return (RSI_buffer[0]);
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
   }

   return (low2Ago > highNow);
}

// Entry Order Buy/Sell
void Order_(ENUM_ORDER_TYPE order_type)
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

      // ALSO SET TP IN BAD CASE
      double tp_ = 0.0;
      // if(USE_TRAILING_BOOL==false)
      {
         tp_ = NormalizeDouble(bid_ + (atr_ * ATR_multiply * 1.66), _Digits);
      }

      lots = LotSize_();
      if (lots > 0)
      {
         trade.Buy(lots, _Symbol, ask_, sl_, tp_);
         //         SendMail_(ORDER_TYPE_BUY);
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

      // ALSO SET TP IN BAD CASE
      double tp_ = 0.0;
      // if(USE_TRAILING_BOOL==false)
      {
         tp_ = NormalizeDouble(ask_ - (atr_ * ATR_multiply * 1.66), _Digits);
      }
      lots = LotSize_();
      if (lots > 0)
      {
         trade.Sell(lots, _Symbol, bid_, sl_, tp_);
         //            SendMail_(ORDER_TYPE_SELL);
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

                     // #ifdef _DEBUG
                     // string str_ = StringFormat("___TRAILING.MOVE.SL.FROM:%.2f TO:%.2f --- ResultCode: %i - %s ",
                     //                           sl_price, stop_loss_price,
                     //                           trade.ResultRetcode(),
                     //                           trade.ResultRetcodeDescription());
                     // Print(str_);
                     // Print("");
                     // #endif
                  }
                  else if (position_type == POSITION_TYPE_SELL)
                  {
                     double stop_loss_price = ask_ + (atr_ * ATR_multiply);
                     trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), 0);

                     // #ifdef _DEBUG
                     // string str_ = StringFormat("___TRAILING.MOVE.SL.FROM:%.2f TO:%.2f --- ResultCode: %i - %s ",
                     //                           sl_price, stop_loss_price,
                     //                           trade.ResultRetcode(),
                     //                           trade.ResultRetcodeDescription());
                     // Print(str_);
                     // Print("");
                     // #endif
                  }
               }
            }
         }
      }
   }
}

// POSITION TRAILING AUTOMATIC ?
// UPDATE SL IMMEDIATELY WHEN NEW FVG OCCUR AND PROFIT IS GET BETTER
void PositionsTrailing()
{
   if (PositionsTotal() > 0)
   {
      for (int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i); // --------------------------------
         if (PositionSelectByTicket(ticket))
         {
            string symbol = PositionGetString(POSITION_SYMBOL);
            if (symbol == _Symbol)
            {
               double sl_price = PositionGetDouble(POSITION_SL);
               long position_type = PositionGetInteger(POSITION_TYPE);
               double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
               // double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
               double position_profit = PositionGetDouble(POSITION_PROFIT); // from above line 570
               double ask_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
               double bid_ = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
               long position_time_update = PositionGetInteger(POSITION_TIME_UPDATE);
               double spread_ = MathAbs(ask_ - bid_);
               double ask_bid_everage_ = (ask_ + bid_) / 2;

               //  -10
               // if (MININUM_PROFIT_ALLOW_BOOL == true && position_profit < MININUM_PROFIT_ALLOW_USD )
               //   {
               //      // close this ticket
               //      PositionCloseV6(ticket);
               //      PositionDataDelete(ticket);
               //      continue;
               //   }

               // if ( (USE_CUTOFF == true) && (position_profit < CUTOFF_LOSS_USD || position_profit > CUTOFF_PROFIT_USD) )
               //   {
               //    PositionCloseV6(ticket);
               //    PositionDataDelete(ticket);
               //    Print("");
               //    Alert(StringFormat("------------- > close ticketid: %d with profit: %.2f ", ticket, position_profit));
               //    Print("");
               //    continue;
               //   }

               if ((USE_CUTOFF_BOOL == true) && position_profit < CUTOFF_LOSS_USD)
               {
                  PositionCloseV6(ticket);
                  PositionDataDelete(ticket);
                  continue;
               }

               if ((USE_CUTOFF_BOOL == true) && position_profit > CUTOFF_PROFIT_USD)
               {
                  PositionCloseV6(ticket);
                  PositionDataDelete(ticket);
                  continue;
               }

               // NEED TEST ...........

               //// UPDATE SL IF PROFIT INCREASE
               //// bool database_check=DatabaseInsert(ticket, position_profit);
               // bool memory_check=PositionDataInsertOrUpdate(ticket, position_profit, position_time_update);
               // if(memory_check==false)
               //   {
               //    // check invalid ?
               //    // return; // <---------------- WRONG
               //    continue; // next for
               //   }

               // XX ONDEMAND ATR
               if (USE_DYNAMIC_ATR == true)
               {
                  iATRGet(); // OPTIMIZATION? DYNAMIC ATR UNCOMMENT THIS LINE
               }

               double atr_ = fvg.atr_;

               if (MathAbs(ask_bid_everage_ - sl_price) > (atr_ * ATR_multiply * 1.5))
               {
                  if (position_type == POSITION_TYPE_BUY)
                  {
                     double stop_loss_price = bid_ - (atr_ * ATR_multiply);
                     double tp_price = bid_ + (atr_ * ATR_multiply * 1.66);
                     // APPLY TO MULTI TIMEFRAME
                     trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), NormalizeDouble(tp_price, _Digits));
                  }
                  else if (position_type == POSITION_TYPE_SELL)
                  {
                     double stop_loss_price = ask_ + (atr_ * ATR_multiply);
                     double tp_price = bid_ - (atr_ * ATR_multiply * 1.66);
                     // APPLY TO MULTI TIMEFRAME
                     trade.PositionModify(ticket, NormalizeDouble(stop_loss_price, _Digits), NormalizeDouble(tp_price, _Digits));
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
void SendMail_(ENUM_ORDER_TYPE order_type)
{

   return;

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
      SUBJECT = "BUY SUBJECT";
      TEXT = "BUY TEXT";
   }

   if (!SendMail(SUBJECT, TEXT))
   {
      Print("SendMail() failed. Error ", GetLastError());
   }
}

// GENERIC LOT CALCULATION
double LotSize_()
{

   // IF GOLD or GBPJPY
   // return position_SIZE;

   // IF US30 OR US100 ?

   if (SYMBOL_VOLUME_MIN_ < 0.1)
   {
      return POSITION_SIZE_DOUBLE;
   }
   else
   {
      return SYMBOL_VOLUME_MIN_;
   }

   // UNREACHABLE

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
//+----------------------------- DABASE -----------------------------+
//+------------------------------------------------------------------+

// string filename="GOLD.sqlite";
//
//// DATABASE CONNECT
// void DatabaseConnect()
//   {
//
////string filename="GOLD.sqlite";
////--- create or open the database in the common terminal folder
//   int db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE |DATABASE_OPEN_COMMON);
//   if(db==INVALID_HANDLE)
//     {
//      Print("DB: ", filename, " open failed with code ", GetLastError());
//      return;
//     }
//
////--- create the GOLD table
//   if(!DatabaseCreateTableGOLD(db))
//     {
//      DatabaseClose(db);
//      return;
//     }
//
////--- request
//   string request="SELECT * FROM GOLD ";
////--- display // PrintFormat("Try to print request \"SELECT EMP_ID, NAME, DEPT FROM COMPANY LEFT OUTER JOIN DEPARTMENT\"");
//   if(DatabasePrint(db, request, 0)<0)
//     {
//      Print("DatabasePrint failed with code ", GetLastError());
//      DatabaseClose(db);
//      return;
//     }
////--- close the database
//   DatabaseClose(db);
//
//  }

// INSERT
// UPDATE
// DELETE

////+------------------------------------------------------------------+
////| Create the GOLD table                       |
////+------------------------------------------------------------------+
// bool DatabaseCreateTableGOLD(int database)
//   {
////--- if the GOLD table exists, delete it
//   if(DatabaseTableExists(database, "DATABASE_GOLD"))
//     {
//      //--- delete the table
//      if(!DatabaseExecute(database, "DROP TABLE GOLD"))
//        {
//         Print("Failed to drop table GOLD with code ", GetLastError());
//         return(false);
//        }
//     }
////--- create the GOLD table
//// https://www.geeksforgeeks.org/sqlite-insert-if-not-exists-else-update/
////CREATE TABLE IF NOT EXISTS users (
////    id INTEGER PRIMARY KEY,
////    username TEXT UNIQUE,
////    email TEXT
////);
//   if(!DatabaseExecute(database,
//                       "CREATE TABLE IF NOT EXISTS GOLD ("
//                       "ID      INTEGER   PRIMARY KEY,"
//                       "TICKET  INTEGER   UNIQUE,"
//                       "PROFIT  REAL"
//                       ");CREATE UNIQUE INDEX data_idx ON GOLD(TICKET);"
//                      ))
//     {
//      Print("DB: create table GOLD failed with code ", GetLastError());
//      return(false);
//     }

// CREATE UNIQUE INDEX data_idx ON data(event_id, track_id);

//
// https://www.mql5.com/en/articles/7463#analysis_by_symbols
// TODO: CREATE INDEX FOR SPEED UP
// INDEX ? CHECK FROM https://www.mql5.com/en/articles/7463#analysis_by_symbols
// CREATE INDEX Idx1 ON deals(position_id)

////--- enter data to the GOLD table
//   if(!DatabaseExecute(database,
//                           "INSERT INTO GOLD (ID,TICKET,PROFIT) VALUES (NULL, 123, 1.2); "
//                           "INSERT INTO GOLD (ID,TICKET,PROFIT) VALUES (NULL, 456, 2.3); "
//                           "INSERT INTO GOLD (ID,TICKET,PROFIT) VALUES (NULL, 789, 7.4);"
//                       ))
//     {
//      Print("GOLD insert failed with code ", GetLastError());
//      return(false);
//     }
//--- success
// return(true);
//}

////+------------------------------------------------------------------+
////| Insert the GOLD table                       |
//// https://www.geeksforgeeks.org/sqlite-insert-if-not-exists-else-update/
////+------------------------------------------------------------------+
// bool DatabaseIn  sert_TEST(ulong ticket_, double profit_)
//   {
////INSERT OR REPLACE INTO GOLD (ID, TICKET, PROFIT) VALUES (
////    (SELECT ID FROM GOLD WHERE TICKET=%d),
////    %d,
////    %f
//// );
//
//   int db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE |DATABASE_OPEN_COMMON);
//   if(db==INVALID_HANDLE)
//     {
//      Print("DB: ", filename, " open failed with code ", GetLastError());
//      return false;
//     }
//
////--- INSERT or UPDATE data
//   string req_ = StringFormat(" INSERT OR REPLACE INTO GOLD (ID, TICKET, PROFIT) VALUES ("
//                              "   (SELECT ID FROM GOLD WHERE TICKET=%d), "
//                              "     %d, "
//                              "     %f ); ", ticket_, ticket_, profit_);
//
//   if(!DatabaseExecute(db, req_))
//     {
//      int err_ = GetLastError();
//      Print("DB: ", filename, " insert failed with code ", err_);
//      DatabaseClose(db);
//      return false;
//     }
//
//
////     bool res_ = DatabaseRead(handle_);
////     int err_ = GetLastError();
////
////     Return true if successful, otherwise false. To get the error code, use GetLastError(), the possible responses are:
////•ERR_INVALID_PARAMETER (4003)               –  no table name specified (empty string or NULL);
////•ERR_WRONG_STRING_PARAMETER (5040)  – error converting a request into a UTF-8 string;
////•ERR_DATABASE_INTERNAL (5120)              – internal database error;
////•ERR_DATABASE_INVALID_HANDLE (5121)    – invalid database handle;
////•ERR_DATABASE_EXECUTE (5124)                –  request execution error;
////•ERR_DATABASE_NO_MORE_DATA (5126)    – no table exists (not an error, normal completion).
//
//
////--- close the database
//   DatabaseClose(db);
//
////--- success
//   return(true);
//  }

// EXIST AND OLD PROFIT < NEW PROFIT        - RETURN TRUE
// ELSE RETURN FALSE

//+------------------------------------------------------------------+
//|                                                                  |
////+------------------------------------------------------------------+
// bool DatabaseInsert(ulong ticket_, double new_profit_)
//   {
////--- create or open the database in the common terminal folder
//   int db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE |DATABASE_OPEN_COMMON);
//   if(db==INVALID_HANDLE)
//     {
//      Print("DB: ", filename, " open failed with code ", GetLastError());
//      return false;
//     }
//
////--- prepare new request about total salary
//   int request_=DatabasePrepare(db, StringFormat("SELECT PROFIT FROM GOLD WHERE TICKET=%d", ticket_));
//   if(request_==INVALID_HANDLE)
//     {
//      Print("DB: ", filename, " request failed with code ", GetLastError());
//      DatabaseClose(db);
//      return false;
//     }
//
////bool res_ = DatabaseRead(request_);
////int err_ = GetLastError();
//
////     Return true if successful, otherwise false. To get the error code, use GetLastError(), the possible responses are:
////•ERR_INVALID_PARAMETER (4003)               –  no table name specified (empty string or NULL);
////•ERR_WRONG_STRING_PARAMETER (5040)  – error converting a request into a UTF-8 string;
////•ERR_DATABASE_INTERNAL (5120)              – internal database error;
////•ERR_DATABASE_INVALID_HANDLE (5121)    – invalid database handle;
////•ERR_DATABASE_EXECUTE (5124)                –  request execution error;
////•ERR_DATABASE_NO_MORE_DATA (5126)    – no table exists (not an error, normal completion).
//
//   bool found_ = false;
//   double OLD_PROFIT=0;
//   while(DatabaseRead(request_))
//     {
//      DatabaseColumnDouble(request_, 0, OLD_PROFIT);
//      Print("Total salary=", OLD_PROFIT);
//      found_ = true;
//     }
//
//   bool res_ = DatabaseRead(request_);
//   int err_ = GetLastError();
//
//   string request_string=""; // StringFormat("UPDATE GOLD SET PROFIT=%.2f WHERE TICKET=%d", new_profit_, ticket_);
//   if(found_ == true)
//     {
//      // UPDATE WITH NEW PROFIT
//      if(OLD_PROFIT<new_profit_)
//        {
//         request_string=StringFormat("UPDATE GOLD SET PROFIT=%.2f WHERE TICKET=%d", new_profit_, ticket_);
//         if(!DatabaseExecute(db, request_string))
//           {
//            Print("GOLD update failed with code ", GetLastError());
//            return(false);
//           }
//
//        }
//
//     }
//   else
//     {
//      // INSERT NEW
//      request_string=StringFormat("INSERT GOLD (TICKET, PROFIT) VALUES (%d, %f)", ticket_, new_profit_);
//      if(!DatabaseExecute(db, request_string))
//        {
//         Print("GOLD insert failed with code ", GetLastError());
//         return(false);
//        }
//     }
//
//   DatabaseClose(db);
//   return(OLD_PROFIT<new_profit_);
//
//  }
//+------------------------------------------------------------------+

// -------------------------------------- SPEED UP IN MEMORY --------------------------------
// FOR SPEED UP / BETTER THAN DATABASE(SQLITE) ?
struct POSITION_DATA
{
   ulong TICKET;
   double PROFIT;
   long TIME;
};

POSITION_DATA position_data[];

// ADD/UPDATE/DELETE STRUCTS OF ARRAY IN MEMORY
bool PositionDataInsertOrUpdate(ulong ticket_, double profit_, long time_update_)
{
   bool exist_ = PositionDataExist(ticket_);
   if (exist_ == false)
   {
      PositionDataInsert(ticket_, profit_, time_update_);
   }
   else
   {
      // return TRUE only found & new profit > old profit
      double old_profit = PositionDataGetProfitByTicket(ticket_);
      if (old_profit < profit_)
      {
         PositionDataUpdate(ticket_, profit_, time_update_);
         return true;
      }
   }

   // ok
   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionDataInsert(ulong ticket_, double profit_, long time_update_)
{
   int size = ArraySize(position_data);
   ArrayResize(position_data, size + 1);

   position_data[size].TICKET = ticket_;
   position_data[size].PROFIT = profit_;
   position_data[size].TIME = time_update_;
   // ok
}

// CHECK EXIST (FROM INDEX)
bool PositionDataExist(ulong ticket_)
{
   bool res = false;
   for (int i = 0; i < ArraySize(position_data); i++)
   {
      if (position_data[i].TICKET == ticket_)
      {
         // return true;
         res = true;
         // ok
      }
   }
   return (res);
}

// UPDATE BY TICKET
void PositionDataUpdate(ulong ticket_, double profit_, long time_update_)
{
   for (int i = 0; i < ArraySize(position_data); i++)
   {
      if (position_data[i].TICKET == ticket_)
      {
         position_data[i].PROFIT = profit_;
         position_data[i].TIME = time_update_;
         // return;
         break; // break for
         // ok
      }
   }
}

// DELETE BY TICKET ?
void PositionDataDelete(ulong ticket_)
{
   int size = ArraySize(position_data);

   for (int i = 0; i < size; i++)
   {
      if (position_data[i].TICKET == ticket_)
      {
         for (int j = i; j < size - 1; j++)
         {
            position_data[j] = position_data[j + 1]; // Shift elements left
         }
         ArrayResize(position_data, size - 1); // Reduce size
         Print("Trade Deleted: ID=", ticket_);
         // return;
         break; // break for
      }
   }
   Print("Trade ID not found!");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionDataPrint()
{
   // for (int i = 0; i < ArraySize(position_data); i++) {
   //     Print("ID:", position_data[i].id, " Type:", tradeArray[i].type, " Price:", tradeArray[i].price, " Lot:", tradeArray[i].lot);
   // }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PositionDataGetProfitByTicket(ulong ticket_)
{
   // return position_data[ticket_].PROFIT;
   double res = -999;
   for (int i = 0; i < ArraySize(position_data); i++)
   {
      if (position_data[i].TICKET == ticket_)
      {
         res = position_data[i].PROFIT; // ok
         break;
      }
   }
   return (res);
}

// TODO: HOW TO CLEAR
// GET BY TICKET  // CLEAR CLOSED POSITION
// void GetLastClosedTrade() {
//    ulong last_ticket = 0;
//    datetime last_time = 0;
//
//    // Loop through the history to find the most recent closed deal
//    f or (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
//        ulong deal_ticket = HistoryDealGetTicket(i);
//        if (HistoryDealSelect(deal_ticket)) {
//            datetime close_time = HistoryDealGetInteger(deal_ticket, DEAL_TIME);
//            if (close_time > last_time) {
//                last_time = close_time;
//                last_ticket = deal_ticket;
//            }
//        }
//    }
//
//    if (last_ticket > 0) {
//        double close_price = HistoryDealGetDouble(last_ticket, DEAL_PRICE);
//        double profit = HistoryDealGetDouble(last_ticket, DEAL_PROFIT);
//        string type = (HistoryDealGetInteger(last_ticket, DEAL_TYPE) == DEAL_TYPE_BUY) ? "BUY" : "SELL";
//
//        Print("Last Closed Trade -> Ticket: ", last_ticket, ", Type: ", type, ", Price: ", close_price, ", Profit: ", profit);
//    } else {
//        Print("No closed trades found!");
//    }
//}

//>>>>>>>>>>>>>>-------------------------------------------

// ResetLastError();
// if(!PositionSelectByTicket(ticket))
//      {
//       PrintFormat("PositionSelectByTicket(%I64u) failed. Error %d", ticket, GetLastError());
//       return;
//      }

// if new bar -> clear array which ticket if position has been closed
void PositionInMemoryClear()
{
   if (PositionsTotal() == 0)
   {
      ArrayResize(position_data, 0); // Reduce size
   }

   // int position_size = ArraySize(position_data);
   // for (int i=0; i<position_size; i++)
   //    {
   //       ulong ticket_=position_data[i].TICKET;
   //       if(!PositionSelectByTicket(ticket_))
   //          {
   //             PositionDataDelete(ticket_); // delete mem
   //          }
   //    }
}
//+------------------------------------------------------------------+
