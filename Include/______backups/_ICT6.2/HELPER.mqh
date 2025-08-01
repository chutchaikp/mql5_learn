//+------------------------------------------------------------------+
//|                                                       HELPER.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <_ICT6.2\TYPES.mqh>

CPositionInfo m_position;
CTrade trade;

//|          pre init    - entry       |
bool USE_STO_BOOL___ = false;
bool USE_EMA_BOOL___ = false;
bool USE_ADX_BOOL___ = false;
bool USE_FIBONACCI_BOOL___ = false;
bool USE_ATR_BOOL___ = false;
bool USE_VWAP_BOOL___ = false;

//|         pre init    - exit         |
ENUM_TP_OPTION TP_OPTION___; //            =TP_OPTION_FIBONACCI_1272;
double LOTS___=0;              //                 =0.3;

double EMA_THRESHOLD___;                //        =0.3;
ENUM_ADX_THRESHOLD ADX_THRESHOLD___;    //        =ADX_THRESHOLD20;
ENUM_TIMEFRAMES FIBONACCI_TIMEFRAME___; //  =PERIOD_H2;

ENUM_TIMEFRAMES ATR_TIMEFRAME___; //        =PERIOD_H2;
double ATR_MULTIPLIER___;         //       =1.5;
ENUM_STORSI_KLINE STO_KPERIOD___; // =KPERIOD14

//+------------------------------------------------------------------+
//| GENERIC ORDER                                                    |
//+------------------------------------------------------------------+
void Order_Generic(ENUM_ORDER_TYPE order_type_) {

   double tp_, sl_;
   if (TP_OPTION___ == TP_OPTION_FIBONACCI_1272) {
      FIBONACCI_GetTP_GetSL_Generic(tp_, sl_, order_type_, 1);
      OrderV2_(order_type_, LOTS___, tp_, sl_);
   } else if (TP_OPTION___ == TP_OPTION_FIBONACCI_1618) {
      FIBONACCI_GetTP_GetSL_Generic(tp_, sl_, order_type_, 2);
      OrderV2_(order_type_, LOTS___, tp_, sl_);
   } else if (TP_OPTION___ == TP_OPTION_ATR) {
      ATR_GetTP_GetSL_Generic(tp_, sl_, order_type_);
      OrderV2_(order_type_, LOTS___, tp_, sl_);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void Order_Generic(ENUM_ORDER_TYPE order_type_, double lots_, double atr_ = 100, double ATR_multiply_ = 1.5) {
//
//   // filter with vwap ?
//   // 1 uptrend ?
//   // 2 downtrend ?
//
//   if (USE_VWAP_BOOL___==true) {
//      double vwap_ = iVWAPGet_Generic();
//      double close0 = iClose(_Symbol,PERIOD_CURRENT,0);
//
//      //ConditiondataInsert( close0 > vwap_ ? 1 : 2 );
//      if (order_type_==ORDER_TYPE_BUY && vwap_==1) {
//         OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
//         return;
//      }
//      if (order_type_==ORDER_TYPE_SELL && vwap_==2) {
//         OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
//         return;
//      }
//   }
//
//   OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
//}

// edit
void Order_Generic(ENUM_ORDER_TYPE order_type_, double lots_, double atr_ = 100, double ATR_multiply_ = 1.5) {

   // filter with vwap ?
   // 1 uptrend ?
   // 2 downtrend ?

   if (USE_VWAP_BOOL___==true) {
      double vwap_ = iVWAPGet_Generic();
      double close0 = iClose(_Symbol,PERIOD_CURRENT,0);
      int vwap_trend_ = close0 > vwap_ ? 1 : 2;

      //ConditiondataInsert( close0 > vwap_ ? 1 : 2 );
      if (order_type_==ORDER_TYPE_BUY && vwap_trend_==1) {
         OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
         return;
      }
      if (order_type_==ORDER_TYPE_SELL && vwap_trend_==2) {
         OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
         return;
      }

   } else {
      OrderV1_(order_type_, lots_, atr_, ATR_multiply_);
   }

}

void OrderV1_(ENUM_ORDER_TYPE order_type, double lots, double atr_ = 100, double ATR_multiply_ = 1.5) {

   double ask_ = Tick_Generic().ask; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL _ASK), _Digits);
   double bid_ = Tick_Generic().bid; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL _BID), _Digits);
   double spread_ = MathAbs(ask_ - bid_);

   if (order_type == ORDER_TYPE_BUY) {
      double sl_ = NormalizeDouble(bid_ - (atr_ * ATR_multiply_), _Digits);
      double tp_ = NormalizeDouble(bid_ + (atr_ * (ATR_multiply_)), _Digits);

      if (lots > 0) {
         trade.Buy(lots, _Symbol, ask_, sl_, tp_);
         int err_ = GetLastError();
         if (err_ > 0) {
            double point_ = _Point;
            Print(err_);
            Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
         }
      }
   } else if (order_type == ORDER_TYPE_SELL) {
      double sl_ = NormalizeDouble(ask_ + (atr_ * ATR_multiply_), _Digits);
      double tp_ = NormalizeDouble(ask_ - (atr_ * (ATR_multiply_)), _Digits);
      if (lots > 0) {
         trade.Sell(lots, _Symbol, bid_, sl_, tp_);
         int err_ = GetLastError();
         if (err_ > 0) {
            double point_ = _Point;
            Print(err_);
            Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
         }
      }
   }
}

// JUST ORDER
void OrderV2_(ENUM_ORDER_TYPE order_type, double lots, double tp_, double sl_) {

   double ask_ = Tick_Generic().ask; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
   double bid_ = Tick_Generic().bid; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
   double spread_ = MathAbs(ask_ - bid_);

   if (order_type == ORDER_TYPE_BUY) {
      if (lots > 0) {
         trade.Buy(lots, _Symbol, ask_, sl_, tp_);
         int err_ = GetLastError();
         if (err_ > 0) {
            Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
         }
      }
   } else if (order_type == ORDER_TYPE_SELL) {
      if (lots > 0) {
         trade.Sell(lots, _Symbol, bid_, sl_, tp_);
         int err_ = GetLastError();
         if (err_ > 0) {
            Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
         }
      }
   }
}

void ATR_GetTP_GetSL_Generic(double &tp, double &sl, ENUM_ORDER_TYPE order_type) {

   double ask_ = Tick_Generic().ask; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
   double bid_ = Tick_Generic().bid; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
   double spread_ = MathAbs(ask_ - bid_);
   double atr_ = iATRGet_Generic();

   if (order_type == ORDER_TYPE_BUY) {
      sl = NormalizeDouble(bid_ - (atr_ * ATR_MULTIPLIER___), _Digits);
      tp = NormalizeDouble(bid_ + (atr_ * (ATR_MULTIPLIER___)), _Digits);
   } else if (order_type == ORDER_TYPE_SELL) {
      sl = NormalizeDouble(ask_ + (atr_ * ATR_MULTIPLIER___), _Digits);
      tp = NormalizeDouble(ask_ - (atr_ * (ATR_MULTIPLIER___)), _Digits);
   }
}

void Order_FIBO_Generic(ENUM_ORDER_TYPE order_type_, int fibo_tp_int = 1) {

   double tp_, sl_;
   FIBONACCI_GetTP_GetSL_Generic(tp_, sl_, order_type_, fibo_tp_int);

   double ask_ = Tick_Generic().ask; // NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ ASK), _Digits);
   double bid_ = Tick_Generic().bid; // (SymbolInfoDouble(_Symbol, SYMBOL_ BID), _Digits);
   double spread_ = MathAbs(ask_ - bid_);

   if (order_type_ == ORDER_TYPE_BUY) {
      trade.Buy(LOTS___, _Symbol, ask_, sl_, tp_);
      int err_ = GetLastError();
      if (err_ > 0) {
         Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
      }
   } else if (order_type_ == ORDER_TYPE_SELL) {
      trade.Sell(LOTS___, _Symbol, bid_, sl_, tp_);
      int err_ = GetLastError();
      if (err_ > 0) {
         Print("----- Retcode: ", trade.ResultRetcode(), " Description: ", trade.ResultRetcodeDescription());
      }
   }
}

// LOT SIZE GENERIC
double LotSize_Generic(double POSITION_SIZE_DOUBLE_) {

   // US30Cash
   string sym_name = _Symbol;
   if (StringToUpper(sym_name)) {

      // BALANCE 10000
      // GOLD                 -> ? 1 lots(winrate > 90% ?)
      // BTCUSD               -> 4 - 5 LOTS
      // US30CASH US100CASH   -> 1 - 2 LOTS

      if (sym_name == "US30CASH" || sym_name == "US100CASH" || sym_name == "BTCUSD#") {
         return POSITION_SIZE_DOUBLE_;
      }
   }

   double percentage_to_lose = 5; //   SELL_BU sell_buy_percent;
   // double entry_price, double stop_loss_price, double percentage_to_lose

   // Get Symbol Info
   double lots_maximum = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);     // SYMBOL_VOLUME_MAX_; //
   double lots_minimum = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);     // SYMBOL_VOLUME_MIN_; //
   double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);     // SYMBOL_VOLUME_STEP_; //
   double tick_size = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);   // SYMBOL_TRADE_TICK_SIZE_; //
   double tick_value = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE); // SYMBOL_TRADE_TICK_VALUE_; //

   // #ifdef not DEBUG
   if (lots_minimum < 0.1) {
      return POSITION_SIZE_DOUBLE_;
   } else {
      return lots_minimum;
   }
   // #endif

   // Get trade basic info
   double available_capital = fmin(fmin(AccountInfoDouble(ACCOUNT_EQUITY), AccountInfoDouble(ACCOUNT_BALANCE)), AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   double amount_to_risk = available_capital * percentage_to_lose / 100;

   // double sl_distance = MathAbs(entry_price - stop_loss_price); // Get the Abs since it might be a short (EP < SL)
   // ATR ?
   // XX ONDEMAND ATR?

   double sl_distance = 100 / _Point; // fvg.atr_ * 1; //ATR_multiply;

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

   if (real_lots < 0.01) {
      return 0.01;
   }

   return (real_lots);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpen(const bool debug = false) {
   string symbol = _Symbol;
   datetime from = NULL;
   datetime to = NULL;
   datetime serverTime = TimeTradeServer();

   // Get the day of the week
   MqlDateTime dt;
   TimeToStruct(serverTime, dt);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dt.day_of_week;

   // Get the time component of the current datetime
   const int time = (int)MathMod(serverTime, PeriodSeconds(PERIOD_D1));

   if (debug)
      PrintFormat("%s(%s): Checking %s", __FUNCTION__, symbol, EnumToString(day_of_week));

   // Brokers split some symbols between multiple sessions.
   // One broker splits forex between two sessions (Tues thru Thurs on different session).
   // 2 sessions (0,1,2) should cover most cases.
   int session = 2;
   while (session > -1) {
      if (SymbolInfoSessionTrade(symbol, day_of_week, session, from, to)) {
         if (debug)
            PrintFormat("%s(%s): Checking %d>=%d && %d<=%d",
                        __FUNCTION__,
                        symbol,
                        time,
                        from,
                        time,
                        to);
         if (time >= from && time <= to) {
            if (debug)
               PrintFormat("%s Market is open", __FUNCTION__);
            return true;
         }
      }
      session--;
   }
   if (debug)
      PrintFormat("%s Market not open", __FUNCTION__);
   return false;
}

// CHECK IS HOLIDAY, ALSO CLOSE POSITION ON FRIDAY NIGHT
bool IsFridayNightSaturdaySunday() {
   datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime dt;
   TimeToStruct(time, dt);

   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)FRIDAY && dt.hour >= 20) {
      return (true);
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SATURDAY) {
      return true;
   }
   if (dt.day_of_week == (ENUM_DAY_OF_WEEK)SUNDAY) {
      return true;
   }
   return (false);
}

// int                              hour_start=8;  // Start Hour (utc+2)
// int                              hour_end=18;   // End Hour (utc+2)
// int      LondonStartHour   =9;
// int      LondonEndHour     =14;
// int      NYStartHour       =15;
// int      NYEndHour         =19;
//  SETUP TIME RANGE
bool InTimeRange_Generic(int hour_start_ = 8, int hour_end_ = 19) {
   datetime time_ = iTime(_Symbol, PERIOD_CURRENT, 0);

   MqlDateTime dt_;
   TimeToStruct(time_, dt_);
   string day_of_week_ = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week_ + " " + (string)time_);

   MqlDateTime tm_;
   TimeToStruct(time_, tm_);

   if (tm_.hour >= hour_start_ && tm_.hour <= hour_end_) {
      return true;
   }
   return false;
}

// HAS LONG POSITION
bool HasBuy() {
   bool res = false;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_BUY) {
            // return true;
            res = true;
            break;
         }
      }
   }
   return (res);
}

// HAS SHORT POSITION
bool HasSell() {
   bool res = false;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_SELL) {
            // return true;
            res = true;
         }
      }
   }
   return (res);
}

// Get position by type
int PositionByType(ENUM_POSITION_TYPE type_) {
   if (type_ == POSITION_TYPE_BUY) {
      return BuyTotal();
   } else if (type_ == POSITION_TYPE_SELL) {
      return SellTotal();
   }
   return (-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BuyTotal() {
   int total_ = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_BUY) {
            total_++;
         }
      }
   }
   return total_;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SellTotal() {
   int total_ = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_SELL) {
            total_++;
         }
      }
   }
   return total_;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionInfoCount(int &buy, int &sell) {
   buy = 0;
   sell = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         if (m_position.PositionType() == POSITION_TYPE_BUY) {
            buy++;
         }
         if (m_position.PositionType() == POSITION_TYPE_SELL) {
            sell++;
         }
      }
   }
}

// Close all positions BY POSITION TYPE
void PositionCloseAll(ENUM_POSITION_TYPE position_type_ = POSITION_TYPE_BUY) {
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         if (m_position.Symbol() == Symbol() && m_position.PositionType() == position_type_) {
            ulong ticket_ = m_position.Ticket();
            trade.PositionClose(ticket_);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CLOSE ALL POSITIONS                                              |
//+------------------------------------------------------------------+
void PositionCloseAllV1() {
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (m_position.SelectByIndex(i)) {
         if (m_position.Symbol() == Symbol()) {
            ulong ticket_ = m_position.Ticket();
            trade.PositionClose(ticket_);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionCloseAll_Generic() {
   PositionCloseAllV1();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionCloseV6(ulong ticket_) {
   // if (m_position.SelectByTicket(ticket_)
   //{
   //    if (m_position.Symbol() == Symbol())
   //    {
   //       ulong ticket_ = m_position.Ticket();
   trade.PositionClose(ticket_);
   //   }
   //}
}

// Prevent dup calculation
bool IsNewBar(datetime &lastbar_timeopen_, bool print_log = true) {
   static datetime bartime = 0; // store open time of the current bar
   //--- get open time of the zero bar
   datetime currbar_time = iTime(_Symbol, _Period, 0);
   //--- if open time changes, a new bar has arrived
   if (bartime != currbar_time) {
      bartime = currbar_time;
      lastbar_timeopen_ = bartime;
      // LOR_=bartime;
      //--- display data on open time of a new bar in the log
      if (print_log && !(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER))) {
         //--- display a message with a new bar open time
         PrintFormat("%s: new bar on %s %s opened at %s", __FUNCTION__, _Symbol,
                     StringSubstr(EnumToString(_Period), 7),
                     TimeToString(TimeCurrent(), TIME_SECONDS));
         //--- get data on the last tick
         MqlTick last_tick;
         if (!SymbolInfoTick(Symbol(), last_tick))
            Print("SymbolInfoTick() failed, error = ", GetLastError());
         //--- display the last tick time up to milliseconds
         PrintFormat("Last tick was at %s.%03d",
                     TimeToString(last_tick.time, TIME_SECONDS), last_tick.time_msc % 1000);
      }
      //--- we have a new bar
      return (true);
   }
   //--- no new bar
   return (false);
}

// Draw FVG to chart
void DrawFVGMarker(int shift, bool bullish) {
   color markerColor = bullish ? clrYellow : clrBlue;
   string markerName = bullish ? "BullishFVG_" : "BearishFVG_";

   int total_object = ObjectsTotal(0, 0, -1) + 1;
   markerName += IntegerToString(total_object);

   double startPrice = bullish == false ? iLow(_Symbol, PERIOD_CURRENT, 2 + shift) : iHigh(_Symbol, PERIOD_CURRENT, 2 + shift);
   double endPrice = bullish == false ? iHigh(_Symbol, PERIOD_CURRENT, 0 + shift) : iLow(_Symbol, PERIOD_CURRENT, 0 + shift);

   ObjectCreate(0, markerName, OBJ_RECTANGLE, 0,
                iTime(_Symbol, PERIOD_CURRENT, 2 + shift),
                startPrice,
                iTime(_Symbol, PERIOD_CURRENT, 0 + shift),
                endPrice);

   ObjectSetInteger(0, markerName, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(0, markerName, OBJPROP_WIDTH, 1);
}

// long         chart_id,      // chart identifier
// draw in  not working

void DrawFVGMarker_Generic(ENUM_TIMEFRAMES tf_, int shift, bool bullish) {

   // 9 223 372 036 854 775 807
   long chart_id = 854775807 + (long)tf_;

   color markerColor = bullish ? clrYellow : clrBlue;
   string markerName = bullish ? "BullishFVG_" : "BearishFVG_";

   int total_object = ObjectsTotal(chart_id, 0, -1) + 1;
   markerName += IntegerToString(total_object);

   double startPrice = bullish == false ? iLow(_Symbol, tf_, 2 + shift) : iHigh(_Symbol, tf_, 2 + shift);
   double endPrice = bullish == false ? iHigh(_Symbol, tf_, 0 + shift) : iLow(_Symbol, tf_, 0 + shift);

   ObjectCreate(chart_id, markerName, OBJ_RECTANGLE, 0,
                iTime(_Symbol, tf_, 2 + shift),
                startPrice,
                iTime(_Symbol, tf_, 0 + shift),
                endPrice);

   ObjectSetInteger(chart_id, markerName, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(chart_id, markerName, OBJPROP_WIDTH, 1);
}

//+------------------------------------------------------------------+
// DISPLAY BUTTONS

// string buttonLastAnalyserFVG     ="buttonLastAnalyserFVG";
// string buttonAnalyseFVG          ="buttonAnalyseFVG";
// string buttonEntryFVG            ="buttonEntryFVG";
string buttonNotifyOnOff = "buttonNotifyOnOff";
string buttonCurrentTime = "buttonCurrentTime";
// string buttonTrailingDiff        ="buttonTrailingDiff";
string buttonATR = "buttonATR";
// string buttonRSI1RSI0            ="buttonRSI1RSI0";
string buttonSTORSI = "buttonSTORSI";
string buttonEmaThreadhold = "buttonEmaThreadhold";

string buttonPrice = "buttonPrice";
string buttonAdxValue = "buttonAdxValue";
string buttonAdxDiPlus = "buttonAdxDiPlus";
string buttonAdxDiMinus = "buttonAdxDiMinus";

string buttonLong = "buttonLong";
string buttonShort = "buttonShort";
string buttonCloseAll = "buttonCloseAll";

// simple button
void CreateButton() {

   // LINE 0
   // ObjectCreate(0, buttonRSI1RSI0, OBJ_BUTTON, 0, 0, 0);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_XSIZE, 400);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_YSIZE, 50);
   // ObjectSetString(0, buttonRSI1RSI0, OBJPROP_TEXT, "buttonRSI1RSI0");
   // ObjectSetInteger(0,buttonRSI1RSI0,OBJPROP_COLOR,clrBlue);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_XDISTANCE, 20);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_YDISTANCE, 180);
   // ObjectSetInteger(0, buttonRSI1RSI0, OBJPROP_FONTSIZE, 16);

   // LINE 1
   //   ObjectCreate(0, buttonLastAnalyserFVG, OBJ_BUTTON, 0, 0, 0);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XSIZE, 400);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_YSIZE, 50);
   //   ObjectSetString(0, buttonLastAnalyserFVG, OBJPROP_TEXT, "buttonLastAnalyserFVG");
   //   // ObjectSetInteger(0,buttonLastAnalyserFVG,OBJPROP_COLOR,clrOrange);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   //   // ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XDISTANCE, 380);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XDISTANCE, 20);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_YDISTANCE, 120);
   //   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_FONTSIZE, 16);
   //
   //   ObjectCreate(0, buttonAnalyseFVG, OBJ_BUTTON, 0, 0, 0);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_XSIZE, 400);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_YSIZE, 50);
   //   ObjectSetString(0, buttonAnalyseFVG, OBJPROP_TEXT, "buttonAnalyseFVG");
   //   // ObjectSetInteger(0,buttonAnalyseFVG,OBJPROP_COLOR,clrRed);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_XDISTANCE, 430);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_YDISTANCE, 120);
   //   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_FONTSIZE, 16);
   //

   //
   //   // LINE 2
   //   ObjectCreate(0, buttonEntryFVG, OBJ_BUTTON, 0, 0, 0);
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_XSIZE, 400); // 160
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_YSIZE, 50);
   //   ObjectSetString(0, buttonEntryFVG, OBJPROP_TEXT, "buttonEntryFVG");
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_COLOR, clrBlue);
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_XDISTANCE, 20); // 210 -> 20
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_YDISTANCE, 60);
   //   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_FONTSIZE, 16);

   // ObjectCreate(0, buttonTrailingDiff, OBJ_BUTTON, 0, 0, 0);
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_XSIZE, 300);
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_YSIZE, 50);
   // ObjectSetString(0, buttonTrailingDiff, OBJPROP_TEXT, "buttonTrailingDiff");
   //// ObjectSetInteger(0,buttonTrailingDiff,OBJPROP_COLOR,clrOrange);
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_XDISTANCE, 600); // // + 240
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_YDISTANCE, 60);
   // ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_FONTSIZE, 12);

   ////   NOTIFY ON/OFF
   //   ObjectCreate(0, buttonNotifyOnOff, OBJ_BUTTON, 0, 0, 0);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_XSIZE, 400);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_YSIZE, 80);
   //   ObjectSetString(0, buttonNotifyOnOff, OBJPROP_TEXT, "buttonNotifyOnOff");
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_COLOR, clrBlue);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_XDISTANCE, 20);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_YDISTANCE, 100);
   //   ObjectSetInteger(0, buttonNotifyOnOff, OBJPROP_FONTSIZE, 16);

   // DEBUG STORSI
   // ObjectCreate(0, buttonSTORSI, OBJ_BUTTON, 0, 0, 0);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_XSIZE, 700);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_YSIZE, 80);
   // ObjectSetString(0, buttonSTORSI, OBJPROP_TEXT, "buttonNotifyOnOff");
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_COLOR, clrBlue);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_XDISTANCE, 20);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_YDISTANCE, 100);
   // ObjectSetInteger(0, buttonSTORSI, OBJPROP_FONTSIZE, 16);

   // ObjectCreate(0, buttonEmaThreadhold, OBJ_BUTTON, 0, 0, 0);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_XSIZE, 1200);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_YSIZE, 80);
   // ObjectSetString(0, buttonEmaThreadhold, OBJPROP_TEXT, "buttonEmaThreadhold");
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_COLOR, clrBlue);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_XDISTANCE, 20);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_YDISTANCE, 100);
   // ObjectSetInteger(0, buttonEmaThreadhold, OBJPROP_FONTSIZE, 11);

   // PRICE
   ObjectCreate(0, buttonPrice, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonPrice, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonPrice, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonPrice, OBJPROP_TEXT, "buttonPrice");
   ObjectSetInteger(0, buttonPrice, OBJPROP_COLOR, clrAqua);
   ObjectSetInteger(0, buttonPrice, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonPrice, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonPrice, OBJPROP_YDISTANCE, 500);
   ObjectSetInteger(0, buttonPrice, OBJPROP_FONTSIZE, 16);

   // ATR
   ObjectCreate(0, buttonATR, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonATR, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonATR, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonATR, OBJPROP_TEXT, "buttonATR");
   ObjectSetInteger(0, buttonATR, OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, buttonATR, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonATR, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonATR, OBJPROP_YDISTANCE, 400);
   ObjectSetInteger(0, buttonATR, OBJPROP_FONTSIZE, 16);

   // ADX
   ObjectCreate(0, buttonAdxValue, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxValue, OBJPROP_TEXT, "buttonAdxValue");
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_YDISTANCE, 300);
   ObjectSetInteger(0, buttonAdxValue, OBJPROP_FONTSIZE, 16);
   // ObjectSetInteger(0, buttonAdxValue, OBJPROP_ANCHOR, ANCHOR_LEFT);

   // ADX - DIplus
   ObjectCreate(0, buttonAdxDiPlus, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxDiPlus, OBJPROP_TEXT, "buttonAdxDiPlus");
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_YDISTANCE, 200);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, buttonAdxDiPlus, OBJPROP_ALIGN, ALIGN_LEFT);

   // ADX - DIminus
   ObjectCreate(0, buttonAdxDiMinus, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxDiMinus, OBJPROP_TEXT, "buttonAdxDiMinus");
   // ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_COLOR, clrRed); default is red
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, buttonAdxDiMinus, OBJPROP_ALIGN, ALIGN_LEFT);

   // TIME
   ObjectCreate(0, buttonCurrentTime, OBJ_BUTTON, 0, 0, 0);
   // ObjectCreate(0, buttonCurrentTime, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XSIZE, 700);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, "buttonCurrentTime");
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_ALIGN, ALIGN_CENTER);
   // ObjectSetInteger(0, buttonCurrentTime, OBJPROP_ANCHOR, ANCHOR_CENTER);
   // ObjectSetInteger(0,buttonCurrentTime,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XDISTANCE, 720);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_FONTSIZE, 14);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButtonTime() {
   // TIME
   ObjectCreate(0, buttonCurrentTime, OBJ_BUTTON, 0, 0, 0);
   // ObjectCreate(0, buttonCurrentTime, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XSIZE, 700);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, "buttonCurrentTime");
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_ALIGN, ALIGN_CENTER);
   // ObjectSetInteger(0, buttonCurrentTime, OBJPROP_ANCHOR, ANCHOR_CENTER);
   // ObjectSetInteger(0,buttonCurrentTime,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XDISTANCE, 720);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_FONTSIZE, 14);
}

string buttonLots = "buttonLots";
//string buttonEditMe = "buttonEditMe";

void CreateButtonOrder(bool create_long_ = true, bool create_short_ = true, bool create_closeall_ = true, bool create_edit_ = true) {

   if (create_edit_ == true) {
      ObjectCreate(0, buttonLots, OBJ_EDIT, 0, 0, 0);
      // ObjectCreate(0, buttonLots, OBJ_EDIT, 0, 0, 0);
      ObjectSetInteger(0, buttonLots, OBJPROP_XSIZE, 500);
      ObjectSetInteger(0, buttonLots, OBJPROP_YSIZE, 80);
      ObjectSetString(0, buttonLots, OBJPROP_TEXT, "0.01");
      ObjectSetInteger(0, buttonLots, OBJPROP_ALIGN, ALIGN_CENTER);
      // ObjectSetInteger(0, buttonLots, OBJPROP_ANCHOR, ANCHOR_CENTER);
      ObjectSetInteger(0, buttonLots, OBJPROP_COLOR, clrOrange);
      ObjectSetString(0, buttonLots, OBJPROP_TOOLTIP, "Lot size?");
      ObjectSetInteger(0, buttonLots, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, buttonLots, OBJPROP_XDISTANCE, 720 - 200);
      ObjectSetInteger(0, buttonLots, OBJPROP_YDISTANCE, 100 + 100 + 100 + 100 + 100);
      ObjectSetInteger(0, buttonLots, OBJPROP_FONTSIZE, 14);
   }

   if (create_long_ == true) {
      ObjectCreate(0, buttonLong, OBJ_BUTTON, 0, 0, 0);
      // ObjectCreate(0, buttonLong, OBJ_EDIT, 0, 0, 0);
      ObjectSetInteger(0, buttonLong, OBJPROP_XSIZE, 500);
      ObjectSetInteger(0, buttonLong, OBJPROP_YSIZE, 80);
      ObjectSetString(0, buttonLong, OBJPROP_TEXT, "Long");
      ObjectSetInteger(0, buttonLong, OBJPROP_ALIGN, ALIGN_CENTER);
      // ObjectSetInteger(0, buttonLong, OBJPROP_ANCHOR, ANCHOR_CENTER);
      ObjectSetInteger(0, buttonLong, OBJPROP_COLOR, clrGreen);
      // ObjectSetInteger(0, buttonLong, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, buttonLong, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, buttonLong, OBJPROP_XDISTANCE, 720 - 200);
      ObjectSetInteger(0, buttonLong, OBJPROP_YDISTANCE, 100 + 100);
      ObjectSetInteger(0, buttonLong, OBJPROP_FONTSIZE, 14);
      // ObjectSetInteger(0,buttonLong,objprop_)
      // ObjectSetDouble(0, buttonLong, OBJPROP_ANGLE)
   }

   if (create_short_ == true) {
      ObjectCreate(0, buttonShort, OBJ_BUTTON, 0, 0, 0);
      // ObjectCreate(0, buttonShort, OBJ_EDIT, 0, 0, 0);
      ObjectSetInteger(0, buttonShort, OBJPROP_XSIZE, 500);
      ObjectSetInteger(0, buttonShort, OBJPROP_YSIZE, 80);
      ObjectSetString(0, buttonShort, OBJPROP_TEXT, "Short");
      ObjectSetInteger(0, buttonShort, OBJPROP_ALIGN, ALIGN_CENTER);
      // ObjectSetInteger(0, buttonShort, OBJPROP_ANCHOR, ANCHOR_CENTER);
      ObjectSetInteger(0, buttonShort, OBJPROP_COLOR, clrRed);
      // ObjectSetInteger(0, buttonShort, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, buttonShort, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, buttonShort, OBJPROP_XDISTANCE, 720 - 200);
      ObjectSetInteger(0, buttonShort, OBJPROP_YDISTANCE, 100 + 100 + 100);
      ObjectSetInteger(0, buttonShort, OBJPROP_FONTSIZE, 14);
   }

   if (create_closeall_ == true) {
      ObjectCreate(0, buttonCloseAll, OBJ_BUTTON, 0, 0, 0);
      // ObjectCreate(0, buttonCloseAll, OBJ_EDIT, 0, 0, 0);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_XSIZE, 500);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_YSIZE, 80);
      ObjectSetString(0, buttonCloseAll, OBJPROP_TEXT, "Close All");
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_ALIGN, ALIGN_CENTER);
      // ObjectSetInteger(0, buttonCloseAll, OBJPROP_ANCHOR, ANCHOR_CENTER);
      // ObjectSetInteger(0, buttonCloseAll, OBJPROP_COLOR, clrOrange);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_XDISTANCE, 720 - 200);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_YDISTANCE, 100 + 100 + 100 + 100);
      ObjectSetInteger(0, buttonCloseAll, OBJPROP_FONTSIZE, 14);
   }


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateButtonCurrentTime() {
   datetime datetime_ = iTime(_Symbol, PERIOD_CURRENT, 0);
   MqlDateTime dt_;
   TimeToStruct(datetime_, dt_);
   string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, day_of_week + " " + (string)datetime_);
}

//// ON CHART EVENT
// void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
//   {
//   if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam, "buttonNotifyOnOff") >=0)
//     {
//      Print("buttonNotifyOnOff clicked");
//      Sleep(20);
//      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
//
//      // PositionCloseAll();
//      NOTIFY_BOOL=!NOTIFY_BOOL;
//     }
////   else
////      if
//  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int FindInArray(long &Array[], long Value) {
   int res = -1;
   int size = ArraySize(Array);
   for (int i = 0; i < size; i++) {
      if (Array[i] == Value) {
         res = i;
         // return(i);
         break;
      }
   }
   // return(-1);
   return (res);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| GENERIC INIT INDICATOR                                           |
//+------------------------------------------------------------------+
// double                        MA_buffer[];      // array for the indicator iMA
// int                           MA_handle;        // handle of the indicator iMA
// bool                          AsSeries = true;

// double      MA_buffer_[];
// int         MA_handle_;
//
// double      ATR_buffer_[];
// int         ATR_handle_;

////+-------------------------- MA -----------------------------+
// void InitIndicatorMA(int EMA_LENGTH_) {
//
//// https://www.mql5.com/en/docs/basis/types/this
////void  CDemoClass::setArray(double &array[])
////  {
////   if(ArraySize(array)>0)
////     {
////     ArrayResize(m_array,ArraySize(array));
////     ArrayCopy(m_array, array);
////     }
////  }
//
//   //if (ArraySize(buffer)>0) {
//   //   ArrayResize(MA_buffer_,ArraySize(buffer));
//   //   ArrayCopy(MA_buffer_, buffer);
//   //   // MA_buffer_=buffer;
//   //}
//   //MA_handle_=handle;
//
//
//// DRAW INDICATOR BELOW CHART
//   SetIndexBuffer(0, MA_buffer_, INDICATOR_DATA);
//   ArraySetAsSeries(MA_buffer_, true); //AsSeries);
//   MA_handle_ = iMA(_Symbol, _Period, EMA_LENGTH_, 0, MODE_EMA, PRICE_CLOSE);
//   if(MA_handle_ < 0) {
//      Print("The creation of iMA has failed: Runtime error =", GetLastError());
//      // return(INIT_FAILED);
//   }
//   // return 1;
//}
//+------------------------------------------------------------------+
// double iMAGetGeneric(int index) {
//   // double &MA_buffer_[], const int MA_handle_
//   // double MA[1];
//   ResetLastError();
//   if(CopyBuffer(MA_handle_, 0, index, 1, MA_buffer_) < 0) {
//      int err_ = GetLastError();
//      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
//   } else {
//      return MA_buffer_[0];
//   }
//// ZeroMemory(MA_buffer);
////   ResetLastError();
//   return -1;
//}

////+-------------------------- ATR -----------------------------+
//// int InitIndicatorATR(double &atr_buffer[], int atr_handle) {
// int InitIndicatorATR() {
//    //if (ArraySize(atr_buffer)>0) {
//    //   ArrayResize(ATR_buffer_,ArraySize(atr_buffer));
//    //   ArrayCopy(ATR_buffer_, atr_buffer);
//    //}
//    //ATR_handle_=atr_handle;
//
//    SetIndexBuffer(0, ATR_buffer_, INDICATOR_DATA);
//    ArraySetAsSeries(ATR_buffer_, true); //  AsSeries);
//    ATR_handle_ = iATR(_Symbol, PERIOD_CURRENT, 14);
//    if(ATR_handle_ < 0) {
//       Print("The creation of iATR has failed: Runtime error =", GetLastError());
//       return(INIT_FAILED);
//    }
//    return(1);
// }
//+------------------------------------------------------------------+
// double iATRGet_Generic(int shift=0) {
//
//    int handle_ = iATR(_Symbol, PERIOD_CURRENT, 14);
//    if (handle_ == INVALID_HANDLE) {
//       Print("Failed to create handles");
//       int err_ = GetLastError();
//       return 0;
//    }
//
//    double buffer_[];
//    SetIndexBuffer(0, buffer_, INDICATOR_DATA);
//    ArraySetAsSeries(buffer_, true); // AsSeries);
//
//    ResetLastError();
//    if(CopyBuffer(handle_, 0, shift, 1, buffer_) < 0) {
//       int err_ = GetLastError();
//       PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
//    } else {
//       return(buffer_[0]);
//    }
//    return 0;
// }
//+------------------------------------------------------------------+

//// EMA
ENUM_TREND DetectTrendByEMAGeneric(double &slp,
                                   string symbol_, ENUM_TIMEFRAMES tf, int emaPeriod, double threshold = 0.0003) {

   // double &MA_buffer_[], int &MA_handle_,

   // double emaNow = iMAGet(MA_buffer_, MA_handle_, 0); // iMA(symbol, tf, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   // double emaPrev = iMAGet(MA_buffer_, MA_handle_,1); // iMA(symbol, tf, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);

   double emaNow = iMAGet_Generic(0);
   double emaPrev = iMAGet_Generic(1);
   double price_ = iClose(_Symbol, tf, 0);

   double slope = emaNow - emaPrev;
   double priceDistance = MathAbs(price_ - emaNow);

   // PrintFormat(" slope: %f price_distance: %f ", slope, priceDistance);
   // Print("");
   // PrintFormat(" slope: %f ", slope);
   slp = slope;

   if (price_ > emaNow && slope > threshold) {
      return TREND_UPTREND; // "Uptrend";
   }

   if (price_ < emaNow && slope < -threshold) {
      return TREND_DOWNTREND; // "Downtrend";
   }

   return TREND_SIDEWAYS; //"Sideways";
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSTORSI_KLINEGet_Generic(int shift = 0) {
   ResetLastError();
   int res = CopyBuffer(STO_handle_, 0, shift, 1, STO_buffer_);
   if (res < 0) {
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
      return (0.0);
   }
   return (STO_buffer_[0]);
}
// L LINE = SIGNAL LINE = ORANGE ?
double iSTORSI_DLINEGet_Generic(int shift = 0) {
   ResetLastError();
   int res = CopyBuffer(STO_handle_, 1, shift, 1, STO_buffer_);
   if (res < 0) {
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
      return (0.0);
   }
   return (STO_buffer_[0]);
}

// GET VALUE FROM INDICATOR ADX
ADX_VALUES iADXGet_Generic() {

   if (CopyBuffer(ADXCUSTOM_handle_, 0, 0, 3, ADXCUSTOM_buffer_) < 3 ||
         CopyBuffer(ADXCUSTOM_handle_, 1, 0, 1, ADXCUSTOM_DIplus_buffer_) < 0 ||
         CopyBuffer(ADXCUSTOM_handle_, 2, 0, 1, ADXCUSTOM_DIminus_buffer_) < 0) {
      Print("Failed to copy ADX buffer. Error: ", GetLastError());

      adx_values.adx_value_0 = 0;
      adx_values.adx_value_1 = 0;
      adx_values.adx_value_2 = 0;

      adx_values.di_plus = 0;
      adx_values.di_minus = 0;
      return adx_values;
   }

   double adx0 = ADXCUSTOM_buffer_[0];
   double adx1 = ADXCUSTOM_buffer_[1];
   double adx2 = ADXCUSTOM_buffer_[2];

   double plusDI = ADXCUSTOM_DIplus_buffer_[0];
   double minusDI = ADXCUSTOM_DIminus_buffer_[0];

   adx_values.adx_value_0 = adx0;
   adx_values.adx_value_1 = adx1;
   adx_values.adx_value_2 = adx2;
   adx_values.di_plus = plusDI;
   adx_values.di_minus = minusDI;

   // DEBUG

   if (adx_values.adx_value_2 < adx_values.adx_value_1 &&
         adx_values.adx_value_1 < adx_values.adx_value_0 &&
         20 < adx_values.adx_value_0 &&
         20 > adx_values.adx_value_1) {

      Print("up ?");
   }

   if (adx_values.adx_value_2 > adx_values.adx_value_1 &&
         adx_values.adx_value_1 > adx_values.adx_value_0 &&
         20 > adx_values.adx_value_0 &&
         20 < adx_values.adx_value_1) {
      Print("down ?");
   }

   return adx_values;
}

// GET VALUE FROM INDICATOR CUSTOM_ADX
void iADXCUSTOMGet_Generic(ADXCUSTOM_VALUES &adxcustom_, int count_ = 4) {

   // ArrayInitialize(ADXCUSTOM_buffer_,EMPTY_VALUE);
   // ArrayInitialize(ADXCUSTOM_DIplus_buffer_,EMPTY_VALUE);
   // ArrayInitialize(ADXCUSTOM_DIminus_buffer_,EMPTY_VALUE);

   ArrayFree(ADXCUSTOM_buffer_);
   ArrayFree(ADXCUSTOM_DIplus_buffer_);
   ArrayFree(ADXCUSTOM_DIminus_buffer_);

   if (CopyBuffer(ADXCUSTOM_handle_, 0, 0, count_, ADXCUSTOM_buffer_) < count_ ||
         CopyBuffer(ADXCUSTOM_handle_, 1, 0, count_, ADXCUSTOM_DIplus_buffer_) < count_ ||
         CopyBuffer(ADXCUSTOM_handle_, 2, 0, count_, ADXCUSTOM_DIminus_buffer_) < count_) {

      Print("Failed to copy ADX buffer. Error: ", GetLastError());

      ArrayResize(adxcustom_values.adx_value, 0);
      ArrayResize(adxcustom_values.di_plus, 0);
      ArrayResize(adxcustom_values.di_minus, 0);

      return;
   }

   // https://www.mql5.com/en/articles/567
   // ArraySetAsSeries
   ArrayCopy(adxcustom_.adx_value, ADXCUSTOM_buffer_);
   ArrayCopy(adxcustom_.di_plus, ADXCUSTOM_DIplus_buffer_);
   ArrayCopy(adxcustom_.di_minus, ADXCUSTOM_DIminus_buffer_);

   // Note
   // The ArraySetAsSeries() function does not move the array elements physically.
   //  Instead, it only changes the indexation direction backwards to arrange the access to the elements as in the timeseries.
   //  The ArrayReverse() function physically moves the array elements so that the array is "reversed".

   ArrayReverse(adxcustom_.adx_value);
   ArrayReverse(adxcustom_.di_plus);
   ArrayReverse(adxcustom_.di_minus);

   return;
}

// GET ADX SLOPE
double iADXCUSTOMGetSlope_Generic(int shift = 0) {

   ArrayFree(ADXCUSTOM_buffer_);

   double adxCurrent;
   double adxPrevious;

   if (CopyBuffer(ADXCUSTOM_handle_, 0, shift, 2, ADXCUSTOM_buffer_) < 2) {
      Print("Failed to copy ADX buffer. Error: ", GetLastError());
      return 0.0;
   }
   adxCurrent = ADXCUSTOM_buffer_[0];

   if (CopyBuffer(ADXCUSTOM_handle_, 0, shift + 1, 2, ADXCUSTOM_buffer_) < 2) {
      Print("Failed to copy ADX buffer. Error: ", GetLastError());
      return 0.0;
   }
   adxPrevious = ADXCUSTOM_buffer_[1];

   // Slope = Current ADX - Previous ADX
   double slope = adxCurrent - adxPrevious;

   return slope;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TREND ADX_DetectTrend(ENUM_ADX_THRESHOLD adxThreshold = ADX_THRESHOLD25) {

   // Just update struct ?
   iADXGet_Generic();

   int threshold_ = 25;

   switch (adxThreshold) {
   case ADX_THRESHOLD20:
      threshold_ = 20;
      break;
   case ADX_THRESHOLD25:
      threshold_ = 25;
      break;
   case ADX_THRESHOLD30:
      threshold_ = 30;
      break;
   default:
      break;
   }

   if (adx_values.adx_value_0 < threshold_)
      return TREND_SIDEWAYS;

   if (adx_values.di_plus > adx_values.di_minus) {
      return TREND_UPTREND;
   }

   if (adx_values.di_minus > adx_values.di_plus) {
      return TREND_DOWNTREND;
   }

   return TREND_SIDEWAYS; // TREND_NONE;
}

bool ADX_DetectCrossup(ENUM_ADX_THRESHOLD adxThreshold = ADX_THRESHOLD25) {

   // Just update struct ?
   iADXGet_Generic();

   int threshold_ = 25;

   switch (adxThreshold) {
   case ADX_THRESHOLD20:
      threshold_ = 20;
      break;
   case ADX_THRESHOLD25:
      threshold_ = 25;
      break;
   case ADX_THRESHOLD30:
      threshold_ = 30;
      break;
   default:
      break;
   }

   //-- crossing up ?
   if (adx_values.adx_value_2 < adx_values.adx_value_1 &&
         adx_values.adx_value_1 < adx_values.adx_value_0 &&
         threshold_ < adx_values.adx_value_0 &&
         threshold_ > adx_values.adx_value_1) {
      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ADX_DetectCrossdown(ENUM_ADX_THRESHOLD adxThreshold = ADX_THRESHOLD25) {
   // Just update struct ?
   iADXGet_Generic();

   int threshold_ = 25;

   switch (adxThreshold) {
   case ADX_THRESHOLD20:
      threshold_ = 20;
      break;
   case ADX_THRESHOLD25:
      threshold_ = 25;
      break;
   case ADX_THRESHOLD30:
      threshold_ = 30;
      break;
   default:
      break;
   }

   if (adx_values.adx_value_2 > adx_values.adx_value_1 &&
         adx_values.adx_value_1 > adx_values.adx_value_0 &&
         threshold_ > adx_values.adx_value_0 &&
         threshold_ < adx_values.adx_value_1) {
      return true;
   }

   return false;
}

// CHECK ADX DI+ DI-
ENUM_ADX_DIRECTION iADXGetDirection_Generic(ENUM_ADX_THRESHOLD adx_threshold_) {

   ADXCUSTOM_VALUES adxcustom_;
   iADXCUSTOMGet_Generic(adxcustom_, 1);

   double adx_[];
   double diplus_[];
   double diminus_[];
   ArrayCopy(adx_, adxcustom_.adx_value);
   ArrayCopy(diplus_, adxcustom_.di_plus);
   ArrayCopy(diminus_, adxcustom_.di_minus);

   // 0=no, 1=buy, 2=sell
   // int condition_state=0;

   // add slope must > 0.5

   double adx_slope_ = iADXCUSTOMGetSlope_Generic();
   if (adx_slope_ < 0.5 || adx_[0] < adx_threshold_) {
      return ADX_DIRECTION_NONE;
   }

   if (diplus_[0] > diminus_[0]) {
      return ADX_DIRECTION_BULLISH;
   } else if (diplus_[0] < diminus_[0]) {
      return ADX_DIRECTION_BEARISH;
   }

   return ADX_DIRECTION_NONE;
}

// CHECK ADX DI+ DI-
ENUM_ADX_DIRECTION iADXGetDirection_GenericV2(ENUM_ADX_THRESHOLD adx_threshold_) {

   ADXCUSTOM_VALUES adxcustom_;
   iADXCUSTOMGet_Generic(adxcustom_, 1);

   double adx_[];
   double diplus_[];
   double diminus_[];
   ArrayCopy(adx_, adxcustom_.adx_value);
   ArrayCopy(diplus_, adxcustom_.di_plus);
   ArrayCopy(diminus_, adxcustom_.di_minus);

   // 0=no, 1=buy, 2=sell
   // int condition_state=0;

   // add slope must > 0.5

   double adx_slope_ = iADXCUSTOMGetSlope_Generic();

   // fix 2
   // 1 - just adx crossup threshold line

   // 2 - ( di+ crossup di- || di+ crossup di- ) && slope > 0.5

   // 1
   int res = 0;
   if (adx_[0] > adx_threshold_ && adx_[0] < adx_threshold_) {
      // adx crossup
      return diplus_[0] > diminus_[0] ? ADX_DIRECTION_BULLISH : ADX_DIRECTION_BEARISH;
   }

   // 2
   if (adx_[0] > adx_threshold_ && adx_slope_ > 0.5) {

      if (diplus_[1] < diminus_[1] && diplus_[0] > diminus_[0]) {
         return ADX_DIRECTION_BULLISH;
      }

      if (diplus_[1] > diminus_[1] && diplus_[0] < diminus_[0]) {
         return ADX_DIRECTION_BEARISH;
      }
   }

   //   if (adx_slope_ < 0.5 || adx_[0] < adx_threshold_) {
   //      return ADX_DIRECTION_NONE;
   //   }
   //
   //   if ( diplus_[0] > diminus_[0] ) {
   //      return ADX_DIRECTION_BULLISH;
   //   } else if ( diplus_[0] < diminus_[0] ) {
   //      return ADX_DIRECTION_BEARISH;
   //   }

   return ADX_DIRECTION_NONE;
}

// Key level functions
// FOR KEYLEVEL
// double iSTORSI_KEYLEVEL_KLINEGet_Generic(int shift=0) {
//   ResetLastError();
//   int res=CopyBuffer(STORSI_KEYLEVEL_handle_,0,shift,1, STORSI_KEYLEVEL_buffer_);
//   if(res<0) {
//      PrintFormat("_KEYLEVEL Failed to copy data from the iRSI indicator, error code %d",GetLastError());
//      return(0.0);
//   }
//   return(STORSI_KEYLEVEL_buffer_[0]);
//}
// L LINE = SIGNAL LINE = ORANGE ?
// double iSTORSI_KEYLEVEL_DLINEGet_Generic(int shift=0) {
//   ResetLastError();
//   int res=CopyBuffer(STORSI_KEYLEVEL_handle_,1,shift,1, STORSI_KEYLEVEL_buffer_);
//   if(res<0) {
//      PrintFormat("_KEYLEVEL Failed to copy data from the iRSI indicator, error code %d",GetLastError());
//      return(0.0);
//   }
//   return(STORSI_KEYLEVEL_buffer_[0]);
//}

// BIAS WITH KEYLEVEL TIMEFRAME
// ENUM_TREND DetectKeylevelStochasticTrend_Generic() {
//   double kCurrent = iSTORSI_KEYLEVEL_KLINEGet_Generic(0); // iStochastic(symbol, tf, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_MAIN, 0);
//   double dCurrent = iSTORSI_KEYLEVEL_DLINEGet_Generic(0); // iStochastic(symbol, tf, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
//
//   if (kCurrent > dCurrent) {
//      return TREND_UPTREND;
//   }
//
//   if (kCurrent < dCurrent) {
//      return TREND_DOWNTREND;
//   }
//
//   return TREND_SIDEWAYS;
//}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ENUM_TREND KeyLevelTrend() {
//   return DetectKeylevelStochasticTrend_Generic();
//}

// keylevel candlestick  upward / downward
// CHECK CURRENT CANDLE STICK IS RED OR GREEN !
// ENUM_CANDLESTICK KeyLevelCandlestickUpwardDownward(ENUM_TIMEFRAMES KEYLEVEL_TIMEFRAME_) {
//   // ENUM_TIMEFRAMES STORSI_KEYLEVEL_TIMEFRAME_
//   double openNow = iOpen(_Symbol, KEYLEVEL_TIMEFRAME_, 0);
//
//   MqlTick tick;
//   if(!SymbolInfoTick(_Symbol,tick)) {
//      Print("no tick data available, error = ",GetLastError());
//      // ExpertRemove();
//      return CANDLESTICK_NOWARD;
//   }
//   double Ask=tick.ask;
//   double Bid=tick.bid;
//
//   if (openNow < Ask && openNow < Bid) {
//      return CANDLESTICK_UPWARD;
//   } else if ( openNow > Ask && openNow > Bid ) {
//      return CANDLESTICK_DOWNWARD;
//   }
//
//   return CANDLESTICK_NOWARD;
//}

//+------------------------------------------------------------------+

// FVG GENERIC ?

// Detect Bearish Fair Value Gap (FVG)
// const FVG& fvg_ <-- can not modify const ?
bool IsBullishFVG_Generic(FVG &fvg_, ENUM_TIMEFRAMES tf_ = PERIOD_CURRENT, int shift = 0, bool SHOW_FVG_MARKER_ = false) {
   double high2Ago = iHigh(_Symbol, tf_, 2 + shift);
   double lowNow = iLow(_Symbol, tf_, 0 + shift);
   datetime time_ = iTime(_Symbol, tf_, 0);

   // found error ?
   if (high2Ago < lowNow) {
      if (true) {
         fvg_.type_ = FVG_BULLISH;
         fvg_.top_ = lowNow;
         fvg_.bottom_ = high2Ago;
         fvg_.time_ = time_;

         if (SHOW_FVG_MARKER_ == true) {
            DrawFVGMarker(shift, true);
         }
      }
   }

   return (high2Ago < lowNow);
}

// Detect Bullish Fair Value Gap (FVG)
bool IsBearishFVG_Generic(FVG &fvg_, ENUM_TIMEFRAMES tf_ = PERIOD_CURRENT, int shift = 0, bool SHOW_FVG_MARKER_ = false) {
   double low2Ago = iLow(_Symbol, tf_, 2 + shift);
   double highNow = iHigh(_Symbol, tf_, 0 + shift);
   datetime time_ = iTime(_Symbol, tf_, 0);

   if (low2Ago > highNow) {
      fvg_.type_ = FVG_BEARISH;
      fvg_.top_ = low2Ago;
      fvg_.bottom_ = highNow;
      fvg_.time_ = time_;

      if (SHOW_FVG_MARKER_ == true) {
         DrawFVGMarker(shift, false);
      }
   }
   return (low2Ago > highNow);
}
//+------------------------------------------------------------------+

// https://www.mql5.com/en/forum/460895
// And usually it is better to add the indicator handle on the oninit() function

double MA_buffer_[];
int MA_handle_;

double MA_fast_buffer_[];
int MA_fast_handle_;

double MA_slow_buffer_[];
int MA_slow_handle_;

double STO_buffer_[];
int STO_handle_;

double ATR_buffer_[];
int ATR_handle_;

double VWAP_buffer_[];
int VWAP_handle_;

// int         ADX_handle_;
// double      ADX_buffer_[];
// double      ADX_DIplus_buffer_[];
// double      ADX_DIminus_buffer_[];

int ADXCUSTOM_handle_;
double ADXCUSTOM_buffer_[];
double ADXCUSTOM_DIplus_buffer_[];
double ADXCUSTOM_DIminus_buffer_[];

// bool        AsSeries=true;
int fastPeriod = 8;
int slowPeriod = 21;

// US30
//int fastPeriod = 20;
//int slowPeriod = 50;

ADX_VALUES adx_values = {0, 0, 0};
ADXCUSTOM_VALUES adxcustom_values; // = { {}, {}, {} };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitEMA(double ema_threshold = 0.3) {
   //|      FAST MA          |

   USE_EMA_BOOL___ = true;
   EMA_THRESHOLD___ = ema_threshold;

   string sym_name = _Symbol;
   if (StringToUpper(sym_name)) {
      if (sym_name == "US30CASH" ) {
         fastPeriod = 20;
         slowPeriod = 50;
      }
   }

   SetIndexBuffer(0, MA_fast_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(MA_fast_buffer_, true);
   MA_fast_handle_ = iMA(_Symbol, _Period, fastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if (MA_fast_handle_ < 0) {
      Print("The creation of iMA has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }

   //|      SLOW MA          |
   SetIndexBuffer(0, MA_slow_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(MA_slow_buffer_, true);
   MA_slow_handle_ = iMA(_Symbol, _Period, slowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if (MA_slow_handle_ < 0) {
      Print("The creation of iMA has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }

   return 1;
}

int InitSTO(ENUM_STORSI_KLINE sto_kperiod = KPERIOD14) {

   USE_STO_BOOL___ = true;
   STO_KPERIOD___ = sto_kperiod;

   //|         STORSI      |
   int KPeriod = 3;
   if (sto_kperiod == KPERIOD3) {
      KPeriod = 3;
   } else if (sto_kperiod == KPERIOD5) {
      KPeriod = 5;
   } else if (sto_kperiod == KPERIOD14) {
      KPeriod = 14;
   }
   SetIndexBuffer(0, STO_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(STO_buffer_, true);

   STO_handle_ = iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA, STO_LOWHIGH);
   if (STO_handle_ == INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(Period()), GetLastError());
      return (INIT_FAILED);
   }
   //| /STORSI |

   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitADX(ENUM_ADX_THRESHOLD adx_threshold = ADX_THRESHOLD20, int adx_version_int = 1) {

   USE_ADX_BOOL___ = true;
   ADX_THRESHOLD___ = adx_threshold;

   SetIndexBuffer(0, ADXCUSTOM_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(ADXCUSTOM_buffer_, true);

   if (adx_version_int == 1) {
      ADXCUSTOM_handle_ = iADX(_Symbol, _Period, 14);
   } else {
      ADXCUSTOM_handle_ = iADXWilder(_Symbol, _Period, 14);
   }

   if (ADXCUSTOM_handle_ < 0) {
      Print("The creation of iADX has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }
   return (1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitFIBONACCI(ENUM_TIMEFRAMES fibo_timeframe = PERIOD_H2) {
   USE_FIBONACCI_BOOL___ = true;
   FIBONACCI_TIMEFRAME___ = fibo_timeframe;
   return 1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitATR(ENUM_TIMEFRAMES atr_timeframe = PERIOD_H2, double atr_multiplier = 1.5) {
   //| ATR |

   USE_ATR_BOOL___ = true;
   ATR_TIMEFRAME___ = atr_timeframe;
   ATR_MULTIPLIER___ = atr_multiplier;

   SetIndexBuffer(0, ATR_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(ATR_buffer_, true);
   ATR_handle_ = iATR(_Symbol, atr_timeframe, 14);
   if (ATR_handle_ < 0) {
      Print("The creation of iATR has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }
   return 1;
   // | /ATR |}
}

// lots=? tp_option = ? (atr or fibo)
int InitEXIT(double lots, ENUM_TP_OPTION tp_option) {
   LOTS___ = lots;
   TP_OPTION___ = tp_option;
   return 1;
}

//ADXCUSTOM_handle_ = iCustom(_Symbol, Period(), "CUSTOM_ADX_V2");
int InitVWAP() {
   //| ATR |
   USE_VWAP_BOOL___ = true;
   SetIndexBuffer(0, VWAP_buffer_, INDICATOR_DATA);
   ArraySetAsSeries(VWAP_buffer_, true);
   VWAP_handle_ = iCustom(_Symbol, Period(), "VWAP_Lite"); // iATR(_Symbol, atr_timeframe, 14);
   if (VWAP_handle_ < 0) {
      Print("The creation of VWAP has failed: Runtime error =", GetLastError());
      return (INIT_FAILED);
   }
   return 1;
   // | /ATR |}

}

int IndicatorRelease_Generic() {

   IndicatorRelease(MA_handle_);
   IndicatorRelease(MA_fast_handle_);
   IndicatorRelease(MA_slow_handle_);
   IndicatorRelease(STO_handle_);
   IndicatorRelease(ATR_handle_);
   IndicatorRelease(VWAP_handle_);
   IndicatorRelease(ADXCUSTOM_handle_);

   return 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitIndicatorAll(bool useMA = false,
                     bool useSTO = false,
                     bool useADX = false,
                     bool useATR = false,
                     ENUM_STORSI_KLINE STO_KPeriod = KPERIOD14,
                     int adx_version_int = 1,
                     ENUM_TIMEFRAMES atr_timeframe = PERIOD_H2,
                     double position_size_ = 0
                    ) {

   

   // ENUM_ADX_THRESHOLD ADX_Threshold=ADX_THRESHOLD25

   if (useMA == true) {
      //|      FAST MA          |
      SetIndexBuffer(0, MA_fast_buffer_, INDICATOR_DATA);
      ArraySetAsSeries(MA_fast_buffer_, true);
      MA_fast_handle_ = iMA(_Symbol, _Period, fastPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if (MA_fast_handle_ < 0) {
         Print("The creation of iMA has failed: Runtime error =", GetLastError());
         return (INIT_FAILED);
      }

      //|      SLOW MA          |
      SetIndexBuffer(0, MA_slow_buffer_, INDICATOR_DATA);
      ArraySetAsSeries(MA_slow_buffer_, true);
      MA_slow_handle_ = iMA(_Symbol, _Period, slowPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if (MA_slow_handle_ < 0) {
         Print("The creation of iMA has failed: Runtime error =", GetLastError());
         return (INIT_FAILED);
      }
   }

   if (useSTO == true) {
      //|         STORSI      |
      int KPeriod = 3;
      if (STO_KPeriod == KPERIOD3) {
         KPeriod = 3;
      } else if (STO_KPeriod == KPERIOD5) {
         KPeriod = 5;
      } else if (STO_KPeriod == KPERIOD14) {
         KPeriod = 14;
      }
      SetIndexBuffer(0, STO_buffer_, INDICATOR_DATA);
      ArraySetAsSeries(STO_buffer_, true);
      // STORSI_handle_=iStochastic(_Symbol, STORSI_TIMEFRAME, KPeriod, DPeriod, 3, MODE_SMA,STO_LOWHIGH);
      //  STO_handle_=iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA,STO_LOWHIGH);
      //  STO_handle_=iStochastic(_Symbol, STO_TIMEFRAME_, KPeriod, 3, 3, MODE_SMA,STO_LOWHIGH);
      //  STO_handle_=iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA,STO_LOWHIGH);
      STO_handle_ = iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA, STO_LOWHIGH);
      if (STO_handle_ == INVALID_HANDLE) {
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(Period()), GetLastError());
         return (INIT_FAILED);
      }
      //| /STORSI |
   }

   if (useATR == true) {
      // | ATR |
      SetIndexBuffer(0, ATR_buffer_, INDICATOR_DATA);
      ArraySetAsSeries(ATR_buffer_, true);
      ATR_handle_ = iATR(_Symbol, atr_timeframe, 14);
      if (ATR_handle_ < 0) {
         Print("The creation of iATR has failed: Runtime error =", GetLastError());
         return (INIT_FAILED);
      }
      // | /ATR |
   }

   if (useADX == true) {
      // | ADX |
      // SetIndexBuffer(0, ADX_buffer_, INDICATOR_DATA);
      // ArraySetAsSeries(ADX_buffer_, true);
      // ADX_handle_ = iADXWilder(_Symbol, _Period, 14);
      // if(ADX_handle_ < 0) {
      //   Print("The creation of iADX has failed: Runtime error =", GetLastError());
      //   return(INIT_FAILED);
      //}

      SetIndexBuffer(0, ADXCUSTOM_buffer_, INDICATOR_DATA);
      ArraySetAsSeries(ADXCUSTOM_buffer_, true);

      if (adx_version_int == 1) {
         ADXCUSTOM_handle_ = iADX(_Symbol, _Period, 14);
      } else {
         ADXCUSTOM_handle_ = iADXWilder(_Symbol, _Period, 14);
      }

      if (ADXCUSTOM_handle_ < 0) {
         Print("The creation of iADX has failed: Runtime error =", GetLastError());
         return (INIT_FAILED);
      }
      // | /ADX |

      if (position_size_>0) {
         LOTS___=position_size_;
      }
   }

   return (INIT_SUCCEEDED);
}

// ADX + ATR
int InitIndicatorCustom(ENUM_STORSI_KLINE KPeriodSelect_ = KPERIOD14) {

  // handleCustomADX = iCustom(Symbol(), Period(), "CUSTOM_ADX", /* indicator input parameters if any */);
  // ADXCUSTOM_handle_ = iCustom(Symbol(), Period(), "CUSTOM_ADX", 14);
  // ADXCUSTOM_handle_ = iCustom(Symbol(), Period(), "CUSTOM_ADX_V2", 14);

  SetIndexBuffer(0, ADXCUSTOM_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(ADXCUSTOM_buffer_, true);

  SetIndexBuffer(0, ADXCUSTOM_DIplus_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(ADXCUSTOM_DIplus_buffer_, true);

  SetIndexBuffer(0, ADXCUSTOM_DIminus_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(ADXCUSTOM_DIminus_buffer_, true);

  // ADXCUSTOM_handle_ = iCustom(_Symbol, Period(), "CUSTOM_ADX_V2");
  // ADXCUSTOM_handle_ = iADXWilder(_Symbol,PERIOD_CURRENT,14);
  ADXCUSTOM_handle_ = iADX(_Symbol, PERIOD_CURRENT, 14);

  if (ADXCUSTOM_handle_ == INVALID_HANDLE) {
     Print("Failed to load custom indicator.");
     return INIT_FAILED;
  }

  // | ATR |
  SetIndexBuffer(0, ATR_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(ATR_buffer_, true);
  ATR_handle_ = iATR(_Symbol, PERIOD_CURRENT, 14);
  if (ATR_handle_ < 0) {
     Print("The creation of iATR has failed: Runtime error =", GetLastError());
     return (INIT_FAILED);
  }
  // | /ATR |

  // DebugBreak();
  // ENUM_TIMEFRAMES p_ = _Period;
  // string s_ = _Symbol;

  //|      FAST MA          |
  SetIndexBuffer(0, MA_fast_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(MA_fast_buffer_, true);
  MA_fast_handle_ = iMA(_Symbol, _Period, fastPeriod, 0, MODE_EMA, PRICE_CLOSE);
  if (MA_fast_handle_ < 0) {
     Print("The creation of iMA has failed: Runtime error =", GetLastError());
     return (INIT_FAILED);
  }

  //|      SLOW MA          |
  SetIndexBuffer(0, MA_slow_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(MA_slow_buffer_, true);
  MA_slow_handle_ = iMA(_Symbol, _Period, slowPeriod, 0, MODE_EMA, PRICE_CLOSE);
  if (MA_slow_handle_ < 0) {
     Print("The creation of iMA has failed: Runtime error =", GetLastError());
     return (INIT_FAILED);
  }

  //|         STORSI      |
  int KPeriod = 3;
  if (KPeriodSelect_ == KPERIOD3) {
     KPeriod = 3;
  } else if (KPeriodSelect_ == KPERIOD5) {
     KPeriod = 5;
  } else if (KPeriodSelect_ == KPERIOD14) {
     KPeriod = 14;
  }
  SetIndexBuffer(0, STO_buffer_, INDICATOR_DATA);
  ArraySetAsSeries(STO_buffer_, true);
  // STORSI_handle_=iStochastic(_Symbol, STORSI_TIMEFRAME, KPeriod, DPeriod, 3, MODE_SMA,STO_LOWHIGH);
  //  STO_handle_=iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA,STO_LOWHIGH);
  STO_handle_ = iStochastic(_Symbol, _Period, KPeriod, 3, 3, MODE_SMA, STO_LOWHIGH);
  if (STO_handle_ == INVALID_HANDLE) {
     PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(Period()), GetLastError());
     return (INIT_FAILED);
  }
  //| /STORSI |

  return (INIT_SUCCEEDED);
}

// Customize for:
// Scalping: use shorter EMAs like 8/21 on M 5
// Swing trading: use 20/50 or 50/200 on H1 or H4
// XAUUSD: increase slopeThreshold (e.g., 0.5–1.0) due to price scale

// Notes:
// slopeThreshold should be tuned per symbol & timeframe:
// XAUUSD: 0.3–0.8
// GBPJPY: 0.2–0.5
// US30: 1.0–3.0 (due to larger price range)
// You can also combine this with RSI or ATR for confluence-based entries

//+------------------------------------------------------------------+
//| Detect trend using EMA cross + EMA slope                        |
//| Returns: 1 = Strong Uptrend, -1 = Strong Downtrend, 0 = Neutral |
//+------------------------------------------------------------------+
ENUM_TREND EMA_DetectStrongTrend_Generic(double slopeThreshold) {

   string sym_name = _Symbol;
   if (StringToUpper(sym_name)) {
      if (sym_name == "US30CASH" ) {

         if (CopyBuffer(MA_fast_handle_, 0, 0, 5, MA_fast_buffer_) < 5 || CopyBuffer(MA_slow_handle_, 0, 0, 5, MA_slow_buffer_) < 5) {
            Print("Failed to copy EMA data");
            int err_ = GetLastError();
            return 0;
         }

         // Cross detection
         bool wasAbove = MA_fast_buffer_[1] > MA_slow_buffer_[1];
         bool isAbove = MA_fast_buffer_[0] > MA_slow_buffer_[0];

         double slope = MA_fast_buffer_[0] - MA_fast_buffer_[4];

         if (!wasAbove && isAbove && slope >= slopeThreshold)
            return TREND_UPTREND; // 1; // Strong Uptrend
         else if (wasAbove && !isAbove && slope <= -slopeThreshold)
            return TREND_DOWNTREND; // -1; // Strong Downtrend
         else
            return TREND_SIDEWAYS; // 0; // Sideways or weak cross


         return TREND_SIDEWAYS;
      }
   }




   if (CopyBuffer(MA_fast_handle_, 0, 0, 3, MA_fast_buffer_) < 3 || CopyBuffer(MA_slow_handle_, 0, 0, 3, MA_slow_buffer_) < 3) {
      Print("Failed to copy EMA data");
      int err_ = GetLastError();
      return 0;
   }

   // Cross detection
   bool wasAbove = MA_fast_buffer_[1] > MA_slow_buffer_[1];
   bool isAbove = MA_fast_buffer_[0] > MA_slow_buffer_[0];

   double slope = MA_fast_buffer_[0] - MA_fast_buffer_[1];

   if (!wasAbove && isAbove && slope >= slopeThreshold)
      return TREND_UPTREND; // 1; // Strong Uptrend
   else if (wasAbove && !isAbove && slope <= -slopeThreshold)
      return TREND_DOWNTREND; // -1; // Strong Downtrend
   else
      return TREND_SIDEWAYS; // 0; // Sideways or weak cross
}

// BIAS WITH KEYLEVEL TIMEFRAME
// ENUM_TREND STO_DetectTrend_Generic(ENUM_STORSI_KLINE KPeriodSelect_) {
ENUM_TREND STO_DetectTrend_Generic() {

   if (CopyBuffer(STO_handle_, 0, 0, 2, STO_buffer_) < 2) {
      Print("Failed to copy STO data");
      int err_ = GetLastError();
      return 0;
   }

   double kCurrent = STO_buffer_[0];
   double dCurrent = STO_buffer_[1];

   if (kCurrent > dCurrent) {
      return TREND_UPTREND;
   }

   if (kCurrent < dCurrent) {
      return TREND_DOWNTREND;
   }

   return TREND_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| Detects Stochastic K and D line cross                           |
//| Returns: 1 = Bullish Cross (K crosses above D)                  |
//|         -1 = Bearish Cross (K crosses below D)                  |
//|          0 = No cross                                           |
//+------------------------------------------------------------------+
// ENUM_TREND STO_DetectStochasticCross_Generic(string symbol, ENUM_TIMEFRAMES tf, int kPeriod = 14, int dPeriod = 3, int slowing = 3) {
ENUM_TREND STO_DetectStochasticCross_Generic() {

   double kCurrent = iSTORSI_KLINEGet_Generic(0);
   double dCurrent = iSTORSI_DLINEGet_Generic(0);

   double kPrevious = iSTORSI_KLINEGet_Generic(1);
   double dPrevious = iSTORSI_DLINEGet_Generic(1);

   if (kPrevious < dPrevious && kCurrent > dCurrent) {
      // return 1; // Bullish cross
      return TREND_UPTREND;
   }

   if (kPrevious > dPrevious && kCurrent < dCurrent) {
      // return -1; // Bearish cross
      return TREND_DOWNTREND;
   }

   // return 0; // No cross
   return TREND_SIDEWAYS;
}

// CONFIRM FVG IN LOW TIMEFRAME (M1)

// CONFIRM - Detect Bearish Fair Value Gap (FVG)
bool FVG_DetectBullishFVG(ENUM_TIMEFRAMES tf = PERIOD_M1, int shift = 1) {
   // double high2Ago = iHigh(_Symbol, tf, 2 + shift);
   // double lowNow = iLow(_Symbol, tf, 0 + shift);
   // return (high2Ago < lowNow);
   return FVG_DetectBullishFVG_Generic(tf, shift);
}

// CONFIRM - Detect Bullish Fair Value Gap (FVG)
bool FVG_DetectBearishFVG(ENUM_TIMEFRAMES tf = PERIOD_M1, int shift = 1) {
   // double low2Ago = iLow(_Symbol, PERIOD_CURRENT, 2 + shift);
   // double highNow = iHigh(_Symbol, PERIOD_CURRENT, 0 + shift);
   // return (low2Ago > highNow);
   return FVG_DetectBearishFVG_Generic(tf, shift);
}

// CONFIRM - Detect Bearish Fair Value Gap (FVG)
bool FVG_DetectBullishFVG_Generic(ENUM_TIMEFRAMES tf = PERIOD_M1, int shift = 1) {
   double high2Ago = iHigh(_Symbol, tf, 2 + shift);
   double lowNow = iLow(_Symbol, tf, 0 + shift);
   return (high2Ago < lowNow);
}

// CONFIRM - Detect Bullish Fair Value Gap (FVG)
bool FVG_DetectBearishFVG_Generic(ENUM_TIMEFRAMES tf = PERIOD_M1, int shift = 1) {
   double low2Ago = iLow(_Symbol, PERIOD_CURRENT, 2 + shift);
   double highNow = iHigh(_Symbol, PERIOD_CURRENT, 0 + shift);
   return (low2Ago > highNow);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iATRGet_Generic(int shift = 0) {
   // double buffer_[];
   ResetLastError();
   if (CopyBuffer(ATR_handle_, 0, shift, 1, ATR_buffer_) < 0) {
      int err_ = GetLastError();
      PrintFormat("Failed to copy data from the iATR indicator, error code %d", GetLastError());
   } else {
      return (ATR_buffer_[0]);
   }
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iVWAPGet_Generic(int shift = 0) {
   // double buffer_[];
   ResetLastError();
   if (CopyBuffer(VWAP_handle_, 0, shift, 1, VWAP_buffer_) < 0) {
      int err_ = GetLastError();
      PrintFormat("Failed to copy data from the VWAP indicator, error code %d", GetLastError());
   } else {
      return (VWAP_buffer_[0]);
   }
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAGet_Generic(int index) {
   ResetLastError();
   if (CopyBuffer(MA_handle_, 0, index, 1, MA_buffer_) < 0) {
      int err_ = GetLastError();
      PrintFormat("Failed to copy data from the iMA indicator, error code %d", GetLastError());
   } else {
      return MA_buffer_[0];
   }
   // ZeroMemory(MA_buffer);
   //   ResetLastError();
   return -1;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

// COMBO ? IS VALID CONDITION
// return  0 - NO ACTION, 1 - BUY, 2 - SELL
// input double                                       EMA_THRESHOLD=0.5;
int IsValidCondition_Generic(ENUM_CONDITION_COMBO condition_combo_ = CONDITION_COMBO_EMA_ADX,
                             ENUM_ADX_THRESHOLD adx_threshold_ = ADX_THRESHOLD20,
                             double ema_threshold = 0.5,
                             bool use_adx_v2 = false) {

   if (condition_combo_ == CONDITION_COMBO_EMA_STO) {
      ENUM_TREND ema_trend = EMA_DetectStrongTrend_Generic(ema_threshold);
      if (ema_trend == TREND_SIDEWAYS) {
         return 0;
      }
      ENUM_TREND sto_signal = STO_DetectTrend_Generic();
      if (sto_signal == TREND_SIDEWAYS) {
         return 0;
      }
      if (ema_trend == TREND_UPTREND && sto_signal == TREND_UPTREND) {
         return 1;
      } else if (ema_trend == TREND_DOWNTREND && sto_signal == TREND_DOWNTREND) {
         return 2;
      }
   } else if (condition_combo_ == CONDITION_COMBO_EMA_ADX) {
      ENUM_TREND ema_trend = EMA_DetectStrongTrend_Generic(ema_threshold);
      if (ema_trend == TREND_SIDEWAYS) {
         return 0;
      }
      // ENUM_ADX_DIRECTION adx_direction=iADXGet();
      ENUM_ADX_DIRECTION adx_direction = use_adx_v2 == true ? iADXGetDirection_GenericV2(adx_threshold_) : iADXGetDirection_Generic(adx_threshold_);
      if (adx_direction == ADX_DIRECTION_NONE) {
         return 0;
      }
      if (adx_direction == ADX_DIRECTION_BULLISH && ema_trend == TREND_UPTREND) {
         return 1;
      } else if (adx_direction == ADX_DIRECTION_BEARISH && ema_trend == TREND_DOWNTREND) {
         return 2;
      }
   } else if (condition_combo_ == CONDITION_COMBO_STO_ADX) {
      ENUM_TREND sto_signal = STO_DetectTrend_Generic();
      if (sto_signal == TREND_SIDEWAYS) {
         return 0;
      }
      // ENUM_ADX_DIRECTION adx_direction=iADXGet();
      ENUM_ADX_DIRECTION adx_direction = use_adx_v2 == true ? iADXGetDirection_GenericV2(adx_threshold_) : iADXGetDirection_Generic(adx_threshold_);
      if (adx_direction == ADX_DIRECTION_NONE) {
         return 0;
      }
      if (adx_direction == ADX_DIRECTION_BULLISH && sto_signal == TREND_UPTREND) {
         return 1;
      } else if (adx_direction == ADX_DIRECTION_BEARISH && sto_signal == TREND_DOWNTREND) {
         return 2;
      }
   } else if (condition_combo_ == CONDITION_COMBO_EMA_STO_ADX) {
      ENUM_TREND ema_trend = EMA_DetectStrongTrend_Generic(ema_threshold);
      if (ema_trend == TREND_SIDEWAYS) {
         return 0;
      }
      ENUM_TREND sto_signal = STO_DetectTrend_Generic();
      if (sto_signal == TREND_SIDEWAYS) {
         return 0;
      }
      // ENUM_ADX_DIRECTION adx_direction=iADXGet();
      ENUM_ADX_DIRECTION adx_direction = use_adx_v2 == true ? iADXGetDirection_GenericV2(adx_threshold_) : iADXGetDirection_Generic(adx_threshold_);
      if (adx_direction == ADX_DIRECTION_NONE) {
         return 0;
      }
      if (adx_direction == ADX_DIRECTION_BULLISH && ema_trend == TREND_UPTREND && sto_signal == TREND_UPTREND) {
         return 1;
      } else if (adx_direction == ADX_DIRECTION_BEARISH && ema_trend == TREND_DOWNTREND && sto_signal == TREND_DOWNTREND) {
         return 2;
      }
   }

   return 0;
}

//+------------------------------------------------------------------+
//| FIBONACCI RETREATMENT                                            |
//+------------------------------------------------------------------+
double FibLevel_BUY_Generic(double high, double low, double ratio) {
   return low + (high - low) * ratio;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FibLevel_SELL_Generic(double high, double low, double ratio) {
   return high - (high - low) * ratio;
}

// conditions
int condition_data[];
void ConditiondataInsert(int direction = 1) {
   int size = ArraySize(condition_data);
   ArrayResize(condition_data, size + 1);
   condition_data[size] = direction;
}

// 1 all in condition = uptrend
// 2 all in condition = downtrend
int ConditiondataDirection() {
   int size = ArraySize(condition_data);
   if (size <= 0) {
      return 0; // sideway ?
   }

   int one = 0;
   int two = 0;
   for (int i = 0; i < ArraySize(condition_data); i++) {
      if (condition_data[i] == 1) {
         one++;
      }
      if (condition_data[i] == 2) {
         two++;
      }
   }

   if (size == one || size == two) {
      return condition_data[0];
   }

   return 0; // sideway

   // count in array
   //   Go through each element and see if it is equal to the first. One difference, not all the same.
   //   Keep a running count of buys and sells. If you get a count equal to "total amount of strategies," then they all must be the same.
}

// ENTRY CONDITION - EMA + ADX + FIBO

//+------------------------------------------------------------------+
//| return  0 - NO ACTION, 1 - BUY, 2 - SELL                         |
//| return  ENUM_TREND                                               |
//+------------------------------------------------------------------+
//,
//
//   ENUM_TIMEFRAMES fibo_tf_,
//   ENUM_ADX_THRESHOLD adx_threshold_=ADX_THRESHOLD20,
//   bool use_ema=false,
//   double ema_threshold=0.5
//
ENUM_TREND IsValidCondition_FIBO_Generic(ENUM_ORDER_TYPE order_type_) {

   // int result[];
   ArrayFree(condition_data);

   ENUM_TREND fibo_trend = TREND_SIDEWAYS;

   // FIBO HOW ?
   if (order_type_ == ORDER_TYPE_BUY) {
      double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double currentLow = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 0);

      double fib_1 = FibLevel_BUY_Generic(lastHigh, lastLow, 1);
      double fib_50 = FibLevel_BUY_Generic(lastHigh, lastLow, 0.5);

      MqlTick tick[1] = {};
      if (!SymbolInfoTick(_Symbol, tick[0])) {
         Print("SymbolInfoTick() failed. Error ", GetLastError());
         fibo_trend = TREND_SIDEWAYS;
      }
      double currentPrice = tick[0].bid;

      //+--------------------------- IMPORTANT? ---------------------------+
      // https://www.babypips.com/learn/forex/fibonacci-retracement
      // 0 is down / 1 is top
      // it ready to rally up
      if (currentPrice >= fib_50 && currentPrice <= fib_1) {
         fibo_trend = TREND_UPTREND;
      }
   } else if (order_type_ == ORDER_TYPE_SELL) {
      // FIBO ?
      double lastHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double lastLow = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double currentHigh = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 0);

      double fib_50 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.5);
      double fib_1 = FibLevel_SELL_Generic(lastHigh, lastLow, 1);

      MqlTick tick[1] = {};
      if (!SymbolInfoTick(_Symbol, tick[0])) {
         Print("SymbolInfoTick() failed. Error ", GetLastError());
         fibo_trend = TREND_SIDEWAYS;
      }
      double currentPrice = tick[0].ask;

      // https://www.babypips.com/learn/forex/fibonacci-retracement
      //  0 is top / 1 is down
      //  it ready to rally down
      if (currentPrice <= fib_50 && currentPrice >= fib_1) {
         fibo_trend = TREND_DOWNTREND;
      }
   }

   // FIBO
   if (USE_FIBONACCI_BOOL___ == true) {
      ConditiondataInsert((int)fibo_trend);
   }

   // ADX
   if (USE_ADX_BOOL___ == true) {
      ENUM_ADX_DIRECTION adx_direction = iADXGetDirection_Generic(ADX_THRESHOLD___);
      ConditiondataInsert((int)adx_direction);
   }
   // EMA
   if (USE_EMA_BOOL___ == true) {
      ENUM_TREND ema_trend = EMA_DetectStrongTrend_Generic(EMA_THRESHOLD___);
      ConditiondataInsert((int)ema_trend);
   }
   // STO
   if (USE_STO_BOOL___ == true) {
      ENUM_TREND sto_signal = STO_DetectTrend_Generic();
      ConditiondataInsert((int)sto_signal);
   }
   // VWAP
   if (USE_VWAP_BOOL___==true) {
      double vwap_ = iVWAPGet_Generic();
      double close0 = iClose(_Symbol,PERIOD_CURRENT,0);
      ConditiondataInsert( close0 > vwap_ ? 1 : 2 );
   }

   int direction_ = ConditiondataDirection();
   return (ENUM_TREND)direction_;
}


// ENUM_TREND IsValidCondition_FIBO_Generic backup(
//    ENUM_ORDER_TYPE order_type_,
//
//    ENUM_TIMEFRAMES fibo_tf_,
//    ENUM_ADX_THRESHOLD adx_threshold_=ADX_THRESHOLD20,
//    bool use_ema=false,
//    double ema_threshold=0.5
//
//    ) {
//
//    ENUM_TREND fibo_trend_ = TREND_SIDEWAYS;
//
//// FIBO HOW ?
//   if (order_type_==ORDER_TYPE_BUY) {
//      double lastHigh = iHigh(_Symbol, fibo_tf_, 1);
//      double lastLow = iLow(_Symbol, fibo_tf_, 1);
//      double currentLow = iLow(_Symbol, fibo_tf_, 0);
//
//      //double fib_1618 = FibLevel_BUY_Generic(lastHigh, lastLow, 1.618); // FOR TP
//      double fib_1 = FibLevel_BUY_Generic(lastHigh, lastLow, 1);
//      //double fib_786 = FibLevel_BUY_Generic(lastHigh, lastLow, 0.786);
//      //double fib_618 = FibLevel_BUY_Generic(lastHigh, lastLow, 0.618);
//      double fib_50 = FibLevel_BUY_Generic(lastHigh, lastLow, 0.5);
//      //double fib_236 = FibLevel_BUY_Generic(lastHigh, lastLow, 0.236);
//
//      MqlTick tick[1]= {};
//      if(!SymbolInfoTick(_Symbol, tick[0])) {
//         Print("SymbolInfoTick() failed. Error ", GetLastError());
//         return TREND_SIDEWAYS;
//      }
//      double currentPrice = tick[0].bid;
//
//      //+--------------------------- IMPORTANT? ---------------------------+
//      //https://www.babypips.com/learn/forex/fibonacci-retracement
//      // 0 is down / 1 is top
//      // it ready to rally up
//      if(currentPrice >= fib_50 && currentPrice <= fib_1) {
//         fibo_trend_=TREND_UPTREND;
//      }
//   } else if (order_type_==ORDER_TYPE_SELL) {
//
//      // FIBO ?
//      double lastHigh = iHigh(_Symbol, fibo_tf_, 1);
//      double lastLow = iLow(_Symbol, fibo_tf_, 1);
//      double currentHigh = iHigh(_Symbol, fibo_tf_, 0);
//
//      //double fib_236 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.236);
//      //double fib_382 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.382);
//      double fib_50 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.5);
//      //double fib_618 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.618);
//      //double fib_786 = FibLevel_SELL_Generic(lastHigh, lastLow, 0.786);
//      double fib_1 = FibLevel_SELL_Generic(lastHigh, lastLow, 1);
//      //double fib_1618 = FibLevel_SELL_Generic(lastHigh, lastLow, 1.618);
//
//      MqlTick tick[1]= {};
//      if(!SymbolInfoTick(_Symbol, tick[0])) {
//         Print("SymbolInfoTick() failed. Error ", GetLastError());
//         return TREND_SIDEWAYS;
//      }
//      double currentPrice = tick[0].ask;
//
//      //https://www.babypips.com/learn/forex/fibonacci-retracement
//      // 0 is top / 1 is down
//      // it ready to rally down
//      if(currentPrice <= fib_50 && currentPrice >= fib_1) {
//         // if(currentPrice >= fib_50 && currentPrice <= fib_1) {
//         // Order_(ORDER_TYPE_SELL, lastLow, lastHigh, currentHigh );
//         fibo_trend_=TREND_DOWNTREND;
//      }
//
//   }
//
//   // ADX
//   ENUM_ADX_DIRECTION adx_direction= iADXGetDirection_Generic(adx_threshold_);
//   if (adx_direction==ADX_DIRECTION_NONE) {
//      return TREND_SIDEWAYS;
//   }
//
//   if (use_ema==true) {
//      // EMA
//      ENUM_TREND ema_trend = EMA_DetectStrongTrend_Generic(ema_threshold);
//      if (ema_trend==TREND_SIDEWAYS) {
//         return 0;
//      }
//
//      if (adx_direction==ADX_DIRECTION_BULLISH && fibo_trend_==TREND_UPTREND && ema_trend==TREND_UPTREND ) {
//         return TREND_UPTREND;
//      } else if (adx_direction==ADX_DIRECTION_BEARISH && fibo_trend_==TREND_DOWNTREND && ema_trend==TREND_DOWNTREND ) {
//         return TREND_DOWNTREND;
//      }
//
//   } else {
//      if (adx_direction==ADX_DIRECTION_BULLISH && fibo_trend_==TREND_UPTREND  ) {
//         return TREND_UPTREND;
//      } else if (adx_direction==ADX_DIRECTION_BEARISH && fibo_trend_==TREND_DOWNTREND  ) {
//         return TREND_DOWNTREND;
//      }
//   }
//
//   return TREND_SIDEWAYS;
//}

// FIBO GENERIC ?

// Calculate Fibonacci Extension Take Profit for Buy
// Get TP & SL
void FIBONACCI_GetTP_GetSL_Generic(double &tp, double &sl,
                                   ENUM_ORDER_TYPE order_type, int fibo_tp_int = 1) {

   // double swing_low, double swing_high, double retrace

   if (order_type == ORDER_TYPE_BUY) {
      double swing_high = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double swing_low = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double retrace = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 0);

      double diff = swing_high - swing_low;
      double tp127 = retrace + (diff * 1.272);
      double tp1618 = retrace + (diff * 1.618);

      if (fibo_tp_int == 1) {
         tp = NormalizeDouble(tp127, _Digits);
      }
      tp = NormalizeDouble(tp1618, _Digits);
      sl = swing_low;
   } else {
      double swing_high = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double swing_low = iLow(_Symbol, FIBONACCI_TIMEFRAME___, 1);
      double retrace = iHigh(_Symbol, FIBONACCI_TIMEFRAME___, 0);

      double diff = swing_high - swing_low;
      double tp127 = retrace - (diff * 1.272);
      double tp1618 = retrace - (diff * 1.618);

      if (fibo_tp_int == 1) {
         tp = NormalizeDouble(tp127, _Digits);
      }
      tp = NormalizeDouble(tp1618, _Digits);
      sl = swing_high;
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

MqlTick Tick_Generic() {

   MqlTick last_tick;
   //---
   //if (SymbolInfoTick(_Symbol, last_tick)) {
   //   Print(last_tick.time, ": Bid = ", last_tick.bid, " Ask = ", last_tick.ask, "  Volume = ", last_tick.volume);
   //} else {
   //   Print("SymbolInfoTick() failed, error = ", GetLastError());
   //}

   if (!SymbolInfoTick(_Symbol, last_tick)) {
      Print("SymbolInfoTick() failed, error = ", GetLastError());
   }

   //---
   return last_tick;
}
//+------------------------------------------------------------------+
