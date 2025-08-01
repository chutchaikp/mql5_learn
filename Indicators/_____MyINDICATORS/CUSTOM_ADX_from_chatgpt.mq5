
//+------------------------------------------------------------------+
//|                                             CUSTOM_ADX.mq5       |
//|                  ADX with DI+ / DI- and Level Line              |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.06"


// Here's the enhanced version of the custom ADX indicator in MQL5 that:
// - Plots ADX, +DI, and −DI.
// - Uses color-coded lines for visual clarity.
// - Can be extended to generate buy/sell signals based on ADX strength and DI crossovers.


// Usage Tip
// 1 Use ADX > 25 as a trend filter (strong trend).
// 2 Use crossovers of +DI and −DI:
// 2.1 +DI crosses above −DI → potential Buy.
// 2.2 −DI crosses above +DI → potential Sell.


//Add horizental line as input to "Custom ADX Indicator with DI Lines"


//+------------------------------------------------------------------+
//|               Custom ADX Indicator with DI Lines                 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

// Plot settings
#property indicator_label1  "ADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "+DI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLime
#property indicator_width2  1

#property indicator_label3  "-DI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_width3  1

input int Period = 14;

// Buffers
double ADXBuffer[];
double PlusDIBuffer[];
double MinusDIBuffer[];

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ADXBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, PlusDIBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, MinusDIBuffer, INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "Custom ADX (" + IntegerToString(Period) + ")");
   return(INIT_SUCCEEDED);
  }


//int OnCalculate(const int rates_total,
//                const int prev_calculated,
//                const datetime &time[],
//                const double &open[],
//                const double &high[],
//                const double &low[],
//                const double &close[],
//                const long &tick_volume[],
//                const long &volume[],
//                const int &spread[])

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                //const int begin,
                //const double &price[],
                //const double &high[],
                //const double &low[],
                //const double &close[])
                
                                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
                
  {
   if(rates_total < Period + 2)
      return(0);

   int start = MathMax(1, prev_calculated - 1);

   for(int i = start; i < rates_total; i++)
     {
      double upMove   = high[i] - high[i - 1];
      double downMove = low[i - 1] - low[i];

      double plusDM = (upMove > downMove && upMove > 0) ? upMove : 0;
      double minusDM = (downMove > upMove && downMove > 0) ? downMove : 0;

      // True Range
      double tr1 = high[i] - low[i];
      double tr2 = MathAbs(high[i] - close[i - 1]);
      double tr3 = MathAbs(low[i] - close[i - 1]);
      double TR  = MathMax(tr1, MathMax(tr2, tr3));

      static double sumTR = 0.0, sumPlusDM = 0.0, sumMinusDM = 0.0;

      if(i < Period + 1)
        {
         sumTR += TR;
         sumPlusDM += plusDM;
         sumMinusDM += minusDM;
         ADXBuffer[i] = 0;
         PlusDIBuffer[i] = 0;
         MinusDIBuffer[i] = 0;
         continue;
        }

      if(i == Period + 1)
        {
         sumTR = 0;
         sumPlusDM = 0;
         sumMinusDM = 0;
         for(int j = i - Period + 1; j <= i; j++)
           {
            double up = high[j] - high[j - 1];
            double down = low[j - 1] - low[j];

            double dmPlus = (up > down && up > 0) ? up : 0;
            double dmMinus = (down > up && down > 0) ? down : 0;

            double tr1j = high[j] - low[j];
            double tr2j = MathAbs(high[j] - close[j - 1]);
            double tr3j = MathAbs(low[j] - close[j - 1]);
            double trj = MathMax(tr1j, MathMax(tr2j, tr3j));

            sumTR += trj;
            sumPlusDM += dmPlus;
            sumMinusDM += dmMinus;
           }
        }
      else
        {
         sumTR = sumTR - (sumTR / Period) + TR;
         sumPlusDM = sumPlusDM - (sumPlusDM / Period) + plusDM;
         sumMinusDM = sumMinusDM - (sumMinusDM / Period) + minusDM;
        }

      double plusDI = 100 * (sumPlusDM / sumTR);
      double minusDI = 100 * (sumMinusDM / sumTR);
      double dx = 100 * MathAbs(plusDI - minusDI) / (plusDI + minusDI);

      // Smooth ADX
      if(i == Period * 2)
         ADXBuffer[i] = dx;
      else if(i > Period * 2)
         ADXBuffer[i] = (ADXBuffer[i - 1] * (Period - 1) + dx) / Period;

      PlusDIBuffer[i] = plusDI;
      MinusDIBuffer[i] = minusDI;
     }

   return(rates_total);
  }
