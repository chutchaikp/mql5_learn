//+------------------------------------------------------------------+
//|                                                       Indi01.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//      MqlTick tick[1] = {};
//
//      if (!SymbolInfoTick("EURUSD#", tick[0])) {
//         Print("SymbolInforTick() failed. Error ", GetLastError());
//         return -1;
//      }
//
//      PrintFormat("Latest price data for the '%s' symbol:", _Symbol);
//      ArrayPrint(tick);

// Tick value
//        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
//        PrintFormat("Tick value of %s is %f ", _Symbol, tickValue);//
//        tickValue = SymbolInfoDouble("GOLD#", SYMBOL_TRADE_TICK_VALUE);
//        PrintFormat("Tick value of GOLD# is %f ", tickValue);
//SymbolInfoDouble(_Symbol, symbol_trade_)

//double tickValue = SymbolInfoDouble("BTCUSD#", SYMBOL_TRADE_TICK_VALUE);
//PrintFormat("Tick value of BTCUSD# is %f ", tickValue);

//double x =    MathAbs(-1);
//double x = 1.23456789;
//Print( DoubleToString(x, 3));

//double point = Point();
//PrintFormat("Point is %f ", point);

// Get High, Low series
//double high1 = iHigh(_Symbol, PERIOD_CURRENT, 1);
//double low1 = iLow(_Symbol, _Period, 2);
//Print(high1);
//Print(low1);
//Print( MathAbs(low1 - high1));

//        // Math
//        double x = 13;
//        double y = 2;
//        Print( MathMax(x, y) );
//
//        //iTime()
//
//        PrintFormat()



//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {



   return(rates_total);
  }
//+------------------------------------------------------------------+
