
//+------------------------------------------------------------------+
//|                                             CustomADX.mq5       |
//|                  ADX with DI+ / DI- and Level Line              |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.06"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4

//--- inputs
input int    InpADXPeriod = 14;         // ADX Period
input double LevelLine    = 25.0;       // Level Line for trend threshold

//--- buffers
double adxBuffer[];
double plusDIBuffer[];
double minusDIBuffer[];
double levelBuffer[];

//--- plot styles
#property indicator_label1 "ADX"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue

#property indicator_label2 "+DI"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrLime

#property indicator_label3 "-DI"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrRed

#property indicator_label4 "Level Line"
#property indicator_type4  DRAW_LINE
#property indicator_style4 STYLE_DASH
#property indicator_color4 clrSilver

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, adxBuffer,      INDICATOR_DATA);
   SetIndexBuffer(1, plusDIBuffer,   INDICATOR_DATA);
   SetIndexBuffer(2, minusDIBuffer,  INDICATOR_DATA);
   SetIndexBuffer(3, levelBuffer,    INDICATOR_DATA);
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
   if(rates_total < InpADXPeriod + 1)
      return(0);

   for(int i = 0; i < rates_total; i++)
   {
      adxBuffer[i]     = iADX(NULL, 0, InpADXPeriod, PRICE_CLOSE, MODE_MAIN, i);
      plusDIBuffer[i]  = iADX(NULL, 0, InpADXPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
      minusDIBuffer[i] = iADX(NULL, 0, InpADXPeriod, PRICE_CLOSE, MODE_MINUSDI, i);
      levelBuffer[i]   = LevelLine;
   }

   return(rates_total);
  }
