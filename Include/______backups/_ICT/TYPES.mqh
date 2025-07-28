//+------------------------------------------------------------------+
//|                                                        TYPES.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link "https://www.mql5.com"

struct ANALYSER_FVG
{
   int type_; // ENUM_FVGS
   double top_;
   double bottom_;
   datetime time_;
   double major_sl_; // for update sl - trailing stop.
   double atr_;

   int last_fvg_type_;      // ENUM_FVGS
   datetime last_fvg_time_; //
};

struct FVG
{
   int type_; // ENUM_FVGS
   double top_;
   double bottom_;
   datetime time_;
   double atr_;
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
