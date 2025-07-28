//+------------------------------------------------------------------+
//|                                                CUSTOM_ADX_V2.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


// todo: add horizontal line ... 




//#property copyright "Copyright 2025, MetaQuotes Ltd."
//#property link      "https://www.mql5.com"
//#property version   "1.00"
//#property indicator_chart_window
////+------------------------------------------------------------------+
////| Custom indicator initialization function                         |
////+------------------------------------------------------------------+
//int OnInit()
//  {
////--- indicator buffers mapping
//   
////---
//   return(INIT_SUCCEEDED);
//  }
////+------------------------------------------------------------------+
////| Custom indicator iteration function                              |
////+------------------------------------------------------------------+
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
//  {
////---
//   
//   iADX
//   
////--- return value of prev_calculated for next call
//   return(rates_total);
//  }
////+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//|                                                    CUSTOM_ADX_V2.mq5 | 
//|                        Copyright 2011, MetaQuotes Software Corp. | 
//|                                              https://www.mql5.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2000-2024, MetaQuotes Ltd." 
#property link      "https://www.mql5.com" 
#property version   "1.07" 
#property description "The indicator demonstrates how to obtain data" 
#property description "of indicator buffers for the iADX technical indicator." 
#property description "A symbol and timeframe used for calculation of the indicator," 
#property description "are set by the symbol and period parameters." 
#property description "The method of creation of the handle is set through the 'type' parameter (function type)." 
  
#property indicator_separate_window 

//https://www.mql5.com/en/docs/customind/indicatorsetinteger
#property indicator_minimum 0
#property indicator_maximum 100
//--- display three horizontal levels in a separate indicator window
#property indicator_level1 20
//#property indicator_level2 50
//#property indicator_level3 80
//--- set thickness of horizontal levels
#property indicator_levelwidth 1
//--- set color of horizontal levels
#property indicator_levelcolor clrYellow
//clrAliceBlue
//--- set style of horizontal levels
#property indicator_levelstyle STYLE_DOT


#property indicator_buffers 3 
#property indicator_plots   3 
//--- plot ADX 
#property indicator_label1  "ADX" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrWhite
// clrLightSeaGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  5 

//--- plot DI_plus 
#property indicator_label2  "DI_plus" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrLawnGreen
// clrYellowGreen 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1 
//--- plot DI_minus 
#property indicator_label3  "DI_minus" 
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrRed
// clrWheat 
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1 

//#property indicator_label4 "Level Line"
//#property indicator_type4  DRAW_LINE
//#property indicator_style2  STYLE_SOLID 
//#property indicator_color4 clrRed

//+------------------------------------------------------------------+ 
//| Enumeration of the methods of handle creation                    | 
//+------------------------------------------------------------------+ 
enum Creation 
  { 
   Call_iADX,              // use iADX 
   Call_IndicatorCreate    // use IndicatorCreate 
  }; 
//--- input parameters 
// SEEM NOT WORKING ?
// OK WORKING NOW
input double               LevelLine=25;       // Level Line for trend threshold
input Creation             type=Call_iADX;         // type of the function  
input int                  adx_period=14;          // period of calculation 

input string               symbol=" ";             // symbol 
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;  // timeframe 
//--- indicator buffers 
double         ADXBuffer[]; 
double         DI_plusBuffer[]; 
double         DI_minusBuffer[]; 

//double levelBuffer[];

//--- variable for storing the handle of the iADX indicator 
int    handle; 
//--- variable for storing 
string name=symbol; 
//--- name of the indicator on a chart 
string short_name; 
//--- we will keep the number of values in the Average Directional Movement Index indicator 
int    bars_calculated=0; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- assignment of arrays to indicator buffers 
   SetIndexBuffer(0,ADXBuffer,INDICATOR_DATA); 
   SetIndexBuffer(1,DI_plusBuffer,INDICATOR_DATA); 
   SetIndexBuffer(2,DI_minusBuffer,INDICATOR_DATA); 
   
   //SetIndexBuffer(3, levelBuffer,    INDICATOR_DATA);
   //--- set descriptions of horizontal levels
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"ADX THRESHOLD");
   //IndicatorSetString(INDICATOR_LEVELTEXT,1,"Second Level (index 1)");
   //IndicatorSetString(INDICATOR_LEVELTEXT,2,"Third Level (index 2)");
   
   // #property indicator_level1 20
   //change from input 
   
   // IndicatorSetInteger(INDICATOR_LEVELS,,level,colors[index]);
   //IndicatorSetInteger(INDICATOR_LEVELS,0,LevelLine);
   //IndicatorSetInteger(INDICATOR_LEVELS,1,LevelLine);
   //IndicatorSetInteger(INDICATOR_LE,2,LevelLine);   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelLine);
   
//--- determine the symbol the indicator is drawn for 
   name=symbol; 
//--- delete spaces to the right and to the left 
   StringTrimRight(name); 
   StringTrimLeft(name); 
//--- if it results in zero length of the 'name' string 
   if(StringLen(name)==0) 
     { 
      //--- take the symbol of the chart the indicator is attached to 
      name=_Symbol; 
     } 
//--- create handle of the indicator 
   if(type==Call_iADX) 
      handle=iADX(name,period,adx_period); 
   else 
     { 
      //--- fill the structure with parameters of the indicator 
      MqlParam pars[1]; 
      pars[0].type=TYPE_INT; 
      pars[0].integer_value=adx_period; 
      handle=IndicatorCreate(name,period,IND_ADX,1,pars); 
     } 
//--- if the handle is not created 
   if(handle==INVALID_HANDLE) 
     { 
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d", 
                  name, 
                  EnumToString(period), 
                  GetLastError()); 
      //--- the indicator is stopped early 
      return(INIT_FAILED); 
     } 
//--- show the symbol/timeframe the Average Directional Movement Index indicator is calculated for 
   short_name=StringFormat("iADX_CUSTOM (%s/%s period=%d)",name,EnumToString(period),adx_period); 
   IndicatorSetString(INDICATOR_SHORTNAME,short_name); 
//--- normal initialization of the indicator     
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
//--- number of values copied from the iADX indicator 
   int values_to_copy; 
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle); 
   if(calculated<=0) 
     { 
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError()); 
      return(0); 
     } 
//--- if it is the first start of calculation of the indicator or if the number of values in the iADX indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1) 
     { 
      //--- if the iADXBuffer array is greater than the number of values in the iADX indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total; 
      else                       values_to_copy=calculated; 
     } 
   else 
     { 
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1; 
     } 
//--- fill the array with values of the Average Directional Movement Index indicator 
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArraysFromBuffers(ADXBuffer,DI_plusBuffer,DI_minusBuffer,handle,values_to_copy)) return(0); 
//--- form the message 
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d", 
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), 
                            short_name, 
                            values_to_copy); 
//--- display the service message on the chart 
   Comment(comm); 
//--- memorize the number of values in the Average Directional Movement Index indicator 
   bars_calculated=calculated; 
   
   // FROM CHATGPT SEEM NOT WORKING ?
   
   // DRAW LINE ?
   //for(int i = 0; i < rates_total; i++) {
   //   levelBuffer[i]   = LevelLine;
   //}
   
   //for(int i = prev_calculated;i<rates_total;i++){ 
   //   levelBuffer[i]   = LevelLine;
   //}
   
//--- return the prev_calculated value for the next call 
   return(rates_total); 
  } 
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iADX indicator                | 
//+------------------------------------------------------------------+ 
bool FillArraysFromBuffers(double &adx_values[],      // indicator buffer of the ADX line 
                           double &DIplus_values[],   // indicator buffer for DI+ 
                           double &DIminus_values[],  // indicator buffer for DI- 
                           int ind_handle,            // handle of the iADX indicator 
                           int amount                 // number of copied values 
                           ) 
  { 
//--- reset error code 
   ResetLastError(); 
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,adx_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
  
//--- fill a part of the DI_plusBuffer array with values from the indicator buffer that has index 1 
   if(CopyBuffer(ind_handle,1,0,amount,DIplus_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
  
//--- fill a part of the DI_minusBuffer array with values from the indicator buffer that has index 2 
   if(CopyBuffer(ind_handle,2,0,amount,DIminus_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
//--- everything is fine 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
   if(handle!=INVALID_HANDLE) 
      IndicatorRelease(handle); 
//--- clear the chart after deleting the indicator 
   Comment(""); 
  }
