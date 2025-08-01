//+------------------------------------------------------------------+
//|                                                   EA_IB_GOLD.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.01"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>

#include <_HELPER.V6\HELPER.mqh>
#include <_HELPER.V6\HELPER.ext.mqh>

CSymbolInfo          m_symbol;
COrderInfo           m_order;

//_______________________________<INPUTS>_______________________________

input group "GENERAL S E T T I N G S";          // ------------------------------------------------------
input double                                          POSITION_SIZE_DOUBLE = 1;

//|------------ START HERE ------------|
int OnInit() {
   return (INIT_SUCCEEDED);
}

// CLEAN UP
void OnDeinit(const int reason) {
   Comment("");
   //EventKillTimer();
   ObjectsDeleteAll(0);
   IndicatorRelease_Generic();
}

// datetime last_execute_time = 0;
int today_bar_index__ = 0;
string today_time_date__ = "";

int bar_index__ = 0;
datetime time_of_bar__ = 0;

double IB_HIGH = 0;
double IB_LOW = 0;

double TP_BUY_LEVEL=-1;
double TP_SELL_LEVEL=-1;

ulong history_ticket_=0;

void OnTick() {

   int shift_ = 0;
   datetime time = iTime(Symbol(), Period(), shift_);
   double open = iOpen(Symbol(), Period(), shift_);
   double high = iHigh(Symbol(), Period(), shift_);
   double low = iLow(Symbol(), Period(), shift_);
   double close = iClose(NULL, PERIOD_CURRENT, shift_);
   long volume = iVolume(Symbol(), 0, shift_);
   int bars = iBars(NULL, 0);

   // current price
   MqlTick last_tick;
   if (!SymbolInfoTick(Symbol(), last_tick)) {
      return;
   }
   double spread_ = MathAbs(last_tick.bid-last_tick.ask);

   string time_date_ = TimeToString(time,TIME_DATE);
   string time_minutes_ = TimeToString(time,TIME_MINUTES);
   string time_seconds_ = TimeToString(time,TIME_SECONDS);

   // if new day
   if (time_date_ != today_time_date__) {
      if ( OrdersTotal() > 0 ) {
         DeletePendingOrders();
      }

      today_bar_index__ = 0;
      today_time_date__ = time_date_;

      IB_LOW = 0;
      IB_HIGH = 0;

      TP_BUY_LEVEL=-1;
      TP_SELL_LEVEL=-1;

      history_ticket_=0;
   }

   // if new bar
   if ( time != time_of_bar__ ) {
      time_of_bar__ = time;
      today_bar_index__ = today_bar_index__ + 1;
      
      // PrintFormat("%s - bar: %d high: %f low: %f ", today_time_date__, today_bar_index__, high, low);
      
      // ? current price 
      if ( today_bar_index__ == 3 ) {

         // seek initial_balance_high/ initial_balance_low

         double high1_ = iHigh(Symbol(), Period(), 1);
         double high2_ = iHigh(Symbol(), Period(), 2);
         double low1_ = iLow(Symbol(), Period(), 1);
         double low2_ = iLow(Symbol(), Period(), 2);

         double initial_balance_high = high1_ > high2_ ? high1_ : high2_;
         double initial_balance_low = low1_ < low2_ ? low1_ : low2_;

         IB_HIGH = ceil(initial_balance_high);
         IB_LOW = floor(initial_balance_low) ;
         double threshold_ = MathAbs(IB_HIGH-IB_LOW);

         // CLOSE ALL POSITION ?
         //PositionCloseAll(POSITION_TYPE_SELL);
         //PositionCloseAll(POSITION_TYPE_SELL);

         DeletePendingOrders();

         PrintFormat("EXECUTE PENDING ORDER NOW ...", 1);
         // BUY_STOP
         OrderV3_(ORDER_TYPE_BUY_LIMIT, POSITION_SIZE_DOUBLE,IB_HIGH,IB_LOW, IB_HIGH + (1.5*threshold_) + spread_ );

         // SELL_STOP
         OrderV3_(ORDER_TYPE_SELL_LIMIT, POSITION_SIZE_DOUBLE,IB_LOW,IB_HIGH, IB_LOW - (1.5*threshold_) - spread_);

         TP_BUY_LEVEL=IB_HIGH + (1.5*threshold_);
         TP_SELL_LEVEL=IB_LOW - (1.5*threshold_);
         // IF TP BUY OR SELL : TODAY NO TRADE ANYMORE ?
         // HOW TO
         // TP_BUY_LEVEL=X
         // TP_SELL_LEVEL=X

         int err_ = GetLastError();
         if (err_>0) {
            Print(err_);
         }

      }

   }

//   MqlTradeCheckResult trade_res;
//   trade.CheckResult(trade_res);
//
//   string str_ = trade.CheckResultComment();
//   string str2_ = trade.ResultComment();
//
//   if (trade_res.comment != NULL) {
//      DebugBreak();
//      PrintFormat("comment is not NULL");
//   }

//   //int total_history_ = HistoryOrdersTotal();  // OrdersHistoryTotal
//   //orderse
   datetime from_date=0;         // from the very beginning
   datetime to_date=TimeCurrent();// till the current moment
   HistorySelect(from_date,to_date);
   int deals=HistoryDealsTotal();
   ulong ticket=HistoryDealGetTicket(deals-1);
//   if(deal_ticket>0) // deal has been selected, let's proceed ot
//     {
//      //--- ticket of the order, opened the deal
//      ulong order=HistoryDealGetInteger(deal_ticket,DEAL_ORDER);
//      long order_magic=HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
//      long pos_ID=HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
//      double  deal_price=HistoryDealGetDouble(deal_ticket,DEAL_PRICE);
//      double deal_volume=HistoryDealGetDouble(deal_ticket,DEAL_VOLUME);
//      string comment_=HistoryDealGetString(deal_ticket,DEAL_COMMENT);
//
//      PrintFormat("Deal: #%d opened by order: #%d with ORDER_MAGIC: %d was in position: #%d price: #%d volume:",
//                  deals-1,order,order_magic,pos_ID,deal_price,deal_volume);
//
//     }

   if(ticket>0) {
//--- get the type and direction of the deal and display the header for the list of real properties of the selected deal
      string typex=DealTypeDescription((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE));
      ENUM_DEAL_TYPE type_=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      string entry=DealEntryDescription((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY));
      
      // if (history_ticket_ < ticket && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT ) {
      if (history_ticket_ < ticket && ( type_==DEAL_TYPE_BUY || type_==DEAL_TYPE_SELL  ) ) {
         PrintFormat(" %s : %s : #%I64u:", type_, entry, ticket);

         string comment_=HistoryDealGetString(ticket,DEAL_COMMENT);
         if ( StringFind(comment_, "tp") >= 0 ) {
            // DebugBreak();
            Print("TP");
            
            DeletePendingOrders();
         }
         
         if ( StringFind(comment_, "sl") >= 0 ) {
            // DebugBreak();
            Print("SL");
         }

         PrintFormat("comment: %s", comment_);
         history_ticket_ = ticket;
      }


   }


   //// if tp 1 side / no trade anymore
   //if ( TP_BUY_LEVEL>0 && TP_SELL_LEVEL>0) {
   //   if (last_tick.bid>=TP_BUY_LEVEL || last_tick.ask<=TP_SELL_LEVEL ) {
   //      DeletePendingOrders();
   //      TP_BUY_LEVEL=-1;
   //      TP_SELL_LEVEL=-1;
   //   }
   //}


}

// Delte pending orders
void DeletePendingOrders() {

   ResetLastError();
   
   for(int i=OrdersTotal()-1; i>=0; i--) {

      ulong order_ticket_ = OrderGetTicket(i);
      // m_order.SelectByIndex(i);

      // ?
      //if ( m_order.Symbol()==_Symbol) {
         trade.OrderDelete(order_ticket_);
      // }
   }

   int err_ = GetLastError();
   if (err_>0) {
      // DebugBreak();
      Print("Error: ", err_);
   }
}

//+------------------------------------------------------------------+
//| Return the deal type description                                 |
//+------------------------------------------------------------------+
string DealTypeDescription(const ENUM_DEAL_TYPE type) {
   switch(type) {
   case DEAL_TYPE_BUY                     :
      return("Buy");
   case DEAL_TYPE_SELL                    :
      return("Sell");
   case DEAL_TYPE_BALANCE                 :
      return("Balance");
   case DEAL_TYPE_CREDIT                  :
      return("Credit");
   case DEAL_TYPE_CHARGE                  :
      return("Additional charge");
   case DEAL_TYPE_CORRECTION              :
      return("Correction");
   case DEAL_TYPE_BONUS                   :
      return("Bonus");
   case DEAL_TYPE_COMMISSION              :
      return("Additional commission");
   case DEAL_TYPE_COMMISSION_DAILY        :
      return("Daily commission");
   case DEAL_TYPE_COMMISSION_MONTHLY      :
      return("Monthly commission");
   case DEAL_TYPE_COMMISSION_AGENT_DAILY  :
      return("Daily agent commission");
   case DEAL_TYPE_COMMISSION_AGENT_MONTHLY:
      return("Monthly agent commission");
   case DEAL_TYPE_INTEREST                :
      return("Interest rate");
   case DEAL_TYPE_BUY_CANCELED            :
      return("Canceled buy deal");
   case DEAL_TYPE_SELL_CANCELED           :
      return("Canceled sell deal");
   case DEAL_DIVIDEND                     :
      return("Dividend operations");
   case DEAL_DIVIDEND_FRANKED             :
      return("Franked (non-taxable) dividend operations");
   case DEAL_TAX                          :
      return("Tax charges");
   default                                :
      return("Unknown deal type: "+(string)type);
   }
}
//+------------------------------------------------------------------+
//| Return position change method                                    |
//+------------------------------------------------------------------+
string DealEntryDescription(const ENUM_DEAL_ENTRY entry) {
   switch(entry) {
   case DEAL_ENTRY_IN      :
      return("In");
   case DEAL_ENTRY_OUT     :
      return("Out");
   case DEAL_ENTRY_INOUT   :
      return("Reverce");
   case DEAL_ENTRY_OUT_BY  :
      return("Out by");
   case DEAL_ENTRY_STATE   :
      return("Status record");
   default                 :
      return("Unknown deal entry: "+(string)entry);
   }
}
//+------------------------------------------------------------------+
