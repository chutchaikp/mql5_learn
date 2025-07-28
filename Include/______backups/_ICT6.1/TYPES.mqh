//+------------------------------------------------------------------+
//|                                                        TYPES.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"

struct ANALYSER_FVG_RSI
{
   int         type_; // ENUM_FVGS
   double      top_;
   double      bottom_;
   datetime    time_;
   double      major_sl_; // for update sl - trailing stop.
   double      atr_;

   int         last_fvg_type_;      // ENUM_FVGS
   datetime    last_fvg_time_; //
   
   int         rsi_0;
   int         rsi_1;
};

struct FVG
{
   int      type_; // ENUM_FVGS
   double   top_;
   double   bottom_;
   datetime time_;
   double   atr_;
};

enum ENUM_FVGS
{
   FVG_NONE = 0,
   FVG_BULLISH = 0x1,
   FVG_BEARISH = 0x2
};

string FvgTypeToString(int type_)
{
   if (type_ == FVG_NONE)
   {
      return "NONE";
   }
   else if (type_ == FVG_BULLISH)
   {
      return "BULL";
   }
   else
   {
      return "BEAR";
   }
}

enum ENUM_RSIS
{
   RSI_NONE=0,
   RSI_OVERBOUGHT=0x1,
   RSI_OVERSOLD=0x2
};
