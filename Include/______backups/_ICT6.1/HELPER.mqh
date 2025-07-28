//+------------------------------------------------------------------+
//|                                                       HELPER.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

CPositionInfo m_position;
CTrade trade;

// HAS LONG POSITION
bool HasBuy()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (m_position.SelectByIndex(i))
      {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_BUY)
         {
            return true;
         }
      }
   }
   return false;
}

// HAS SHORT POSITION
bool HasSell()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (m_position.SelectByIndex(i))
      {
         // if(m_position.Symbol() == Symbol())
         //   {
         //    trade.PositionClose(m_position.Ticket());
         //   }
         if (m_position.PositionType() == POSITION_TYPE_SELL)
         {
            return true;
         }
      }
   }
   return false;
}

// Close all positions BY POSITION TYPE
void PositionCloseAll( ENUM_POSITION_TYPE position_type_ = POSITION_TYPE_BUY )
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (m_position.SelectByIndex(i))
      {
         if (m_position.Symbol() == Symbol() && m_position.PositionType() == position_type_)
         {
            ulong ticket_ = m_position.Ticket();            
            trade.PositionClose(ticket_);
         }         
      }
   }
}

void PositionCloseAllV1()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (m_position.SelectByIndex(i))
      {
         if (m_position.Symbol() == Symbol())
         {
            ulong ticket_ = m_position.Ticket();            
            trade.PositionClose(ticket_);
         }         
      }
   }
}

// Prevent dup calculation
bool IsNewBar(datetime &lastbar_timeopen_, bool print_log = true)
{
   static datetime bartime = 0; // store open time of the current bar
                                //--- get open time of the zero bar
   datetime currbar_time = iTime(_Symbol, _Period, 0);
   //--- if open time changes, a new bar has arrived
   if (bartime != currbar_time)
   {
      bartime = currbar_time;
      lastbar_timeopen_ = bartime;
      // LOR_=bartime;
      //--- display data on open time of a new bar in the log
      if (print_log && !(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER)))
      {
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

//// TODO: Dynamic Lot size - sell_buy_percent 1% - 10%
//double LotSize_(  )
//{
//   double balance_ = AccountInfoDouble(ACCOUNT_BALANCE);
//   //
//   //      analyser_fvg.atr_
//   //      ;
//   //      atr
//   //      balance
//   //      risk_percent
//   return 1.0;
//}

// Draw FVG to chart
void DrawFVGMarker(int shift, bool bullish)
{
   color markerColor = bullish ? clrYellow : clrBlue;
   string markerName = bullish ? "BullishFVG_" : "BearishFVG_";

   // TODO: create a button for clear FVG
   // TODO: delete all object name start with BullishFVG or BearishFVG_

   // StringFind
   int total_object = ObjectsTotal(0, 0, -1) + 1;
   // markerName += IntegerToString(shift);
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

//+------------------------------------------------------------------+
// DISPLAY BUTTONS

// CHANGES buttonPriceAction TO buttonLastAnalyserFVG
// string buttonPriceAction               = "buttonPriceAction";
string buttonLastAnalyserFVG = "buttonLastAnalyserFVG";

string buttonAnalyseFVG = "buttonAnalyseFVG";
string buttonEntryFVG = "buttonEntryFVG";
string buttonCurrentTime = "buttonCurrentTime";
// string button4 = "current_to_sl";
string buttonTrailingDiff = "buttonTrailingDiff";
string buttonATR = "buttonATR";

// sample button
void CreateButton()
{

// LINE 1
   ObjectCreate(0, buttonLastAnalyserFVG, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XSIZE, 400);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonLastAnalyserFVG, OBJPROP_TEXT, "buttonLastAnalyserFVG");
   // ObjectSetInteger(0,buttonLastAnalyserFVG,OBJPROP_COLOR,clrOrange);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XDISTANCE, 380);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_YDISTANCE, 124);
   ObjectSetInteger(0, buttonLastAnalyserFVG, OBJPROP_FONTSIZE, 16);

   ObjectCreate(0, buttonAnalyseFVG, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_XSIZE, 400);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonAnalyseFVG, OBJPROP_TEXT, "buttonAnalyseFVG");
   // ObjectSetInteger(0,buttonAnalyseFVG,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_XDISTANCE, 430);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_YDISTANCE, 124);
   ObjectSetInteger(0, buttonAnalyseFVG, OBJPROP_FONTSIZE, 16);
   
   
   
   

   // LINE 2
   ObjectCreate(0, buttonEntryFVG, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_XSIZE, 400); // 160
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonEntryFVG, OBJPROP_TEXT, "buttonEntryFVG");
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_XDISTANCE, 20); // 210 -> 20
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_YDISTANCE, 65);
   ObjectSetInteger(0, buttonEntryFVG, OBJPROP_FONTSIZE, 16);

   ObjectCreate(0, buttonATR, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonATR, OBJPROP_XSIZE, 160);
   ObjectSetInteger(0, buttonATR, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonATR, OBJPROP_TEXT, "ATR");
   // ObjectSetInteger(0,button4,OBJPROP_COLOR,clrOrange);
   ObjectSetInteger(0, buttonATR, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   // ObjectSetInteger(0, buttonATR, OBJPROP_XDISTANCE, 550);
   ObjectSetInteger(0, buttonATR, OBJPROP_XDISTANCE, 430); // + 240
   ObjectSetInteger(0, buttonATR, OBJPROP_YDISTANCE, 65);
   ObjectSetInteger(0, buttonATR, OBJPROP_FONTSIZE, 16);

   ObjectCreate(0, buttonTrailingDiff, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_XSIZE, 300);
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonTrailingDiff, OBJPROP_TEXT, "buttonTrailingDiff");
   // ObjectSetInteger(0,buttonTrailingDiff,OBJPROP_COLOR,clrOrange);
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_XDISTANCE, 600); // // + 240
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_YDISTANCE, 65);
   ObjectSetInteger(0, buttonTrailingDiff, OBJPROP_FONTSIZE, 12);

   // TIME
   ObjectCreate(0, buttonCurrentTime, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XSIZE, 230);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YSIZE, 50);
   ObjectSetString(0, buttonCurrentTime, OBJPROP_TEXT, "buttonCurrentTime");
   // ObjectSetInteger(0,buttonCurrentTime,OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_XDISTANCE, 250);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_YDISTANCE, 65);
   ObjectSetInteger(0, buttonCurrentTime, OBJPROP_FONTSIZE, 16);
}

//// ON CHART EVENT
// void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
//   {
////   if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam, "ANALYSER_FVG") >=0)
////     {
////      Print("buttonAnalyseFVG clicked");
////      Sleep(20);
////      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
////
////      PositionCloseAll();
////     }
////   else
////      if
//  }
//+------------------------------------------------------------------+

// TIMEFRAME H4, m5
// TIMEFRAME H1, m1

// ATR = use for setup SL ?

//+------------------------------------------------------------------+
