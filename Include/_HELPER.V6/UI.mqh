
#include <_ICT6.2\TYPES.mqh>

//+------------------------------------------------------------------+
// DISPLAY BUTTONS

//string buttonLastAnalyserFVG_     ="buttonLastAnalyserFVG_";
//string buttonAnalyseFVG_          ="buttonAnalyseFVG_";
//string buttonEntryFVG_            ="buttonEntryFVG_";
string buttonNotifyOnOff_         ="buttonNotifyOnOff_";
string buttonCurrentTime_         ="buttonCurrentTime_";
//string buttonTrailingDiff_        ="buttonTrailingDiff_";
string buttonATR_                 ="buttonATR_";
//string buttonRSI1RSI0_            ="buttonRSI1RSI0_";
string buttonSTORSI_              ="buttonSTORSI_";
string buttonEmaThreadhold_       ="buttonEmaThreadhold_";

string buttonPrice_                 ="buttonPrice_";
string buttonAdxValue_            ="buttonAdxValue_";
string buttonAdxDiPlus_           ="buttonAdxDiPlus_";
string buttonAdxDiMinus_          ="buttonAdxDiMinus_";

// simple button
void CreateButton_Generic() {

// LEFT LOWER 4
// PRICE
   ObjectCreate(0, buttonPrice_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonPrice_, OBJPROP_TEXT, "buttonPrice_");
   ObjectSetInteger(0, buttonPrice_, OBJPROP_COLOR, clrAqua);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_YDISTANCE, 500);
   ObjectSetInteger(0, buttonPrice_, OBJPROP_FONTSIZE, 16);


// LEFT LOWER 3
// ATR
   ObjectCreate(0, buttonATR_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonATR_, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonATR_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonATR_, OBJPROP_TEXT, "buttonATR_");
   ObjectSetInteger(0, buttonATR_, OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, buttonATR_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonATR_, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonATR_, OBJPROP_YDISTANCE, 400);
   ObjectSetInteger(0, buttonATR_, OBJPROP_FONTSIZE, 16);


// LEFT LOWER 2
// ADX
   ObjectCreate(0, buttonAdxValue_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxValue_, OBJPROP_TEXT, "buttonAdxValue_");
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_YDISTANCE, 300);
   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_FONTSIZE, 16);
   //ObjectSetInteger(0, buttonAdxValue_, OBJPROP_ANCHOR, ANCHOR_LEFT);


// LEFT LOWER 1
   // ADX - DIplus
   ObjectCreate(0, buttonAdxDiPlus_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxDiPlus_, OBJPROP_TEXT, "buttonAdxDiPlus_");
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_YDISTANCE, 200);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_ALIGN, ALIGN_LEFT);

// LEFT LOWER 0
   // ADX - DIminus
   ObjectCreate(0, buttonAdxDiMinus_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonAdxDiMinus_, OBJPROP_TEXT, "buttonAdxDiMinus_");
   //ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_COLOR, clrRed); default is red
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, buttonAdxDiMinus_, OBJPROP_ALIGN, ALIGN_LEFT);


// RIGHT LOWER 0
// TIME
   ObjectCreate(0, buttonCurrentTime_, OBJ_BUTTON, 0, 0, 0);
   //ObjectCreate(0, buttonCurrentTime_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_XSIZE, 700);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonCurrentTime_, OBJPROP_TEXT, "buttonCurrentTime_");
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_ALIGN, ALIGN_CENTER);
   //ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_ANCHOR, ANCHOR_CENTER);
   //ObjectSetInteger(0,buttonCurrentTime_,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_XDISTANCE, 720);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_FONTSIZE, 14);


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatebuttonCurrentTime_Generic() {
   datetime datetime_ = iTime(_Symbol,PERIOD_CURRENT,0);
   MqlDateTime dt_;
   TimeToStruct(datetime_, dt_);
   string day_of_week = EnumToString((ENUM_DAY_OF_WEEK)dt_.day_of_week);
   ObjectSetString(0, buttonCurrentTime_, OBJPROP_TEXT, day_of_week + " " + (string)datetime_);
}

//// ON CHART EVENT
// void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
//   {
//   if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam, "buttonNotifyOnOff_") >=0)
//     {
//      Print("buttonNotifyOnOff_ clicked");
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


string labelLeftLower4 = "labelLeftLower4";
string labelLeftLower3 = "labelLeftLower3";
string labelLeftLower2 = "labelLeftLower2";
string labelLeftLower1 = "labelLeftLower1";
string labelLeftLower0 = "labelLeftLower0";

void CreateLabel_Generic() {

//// LEFT LOWER 4
//// PRICE
//   ObjectCreate(0, buttonPrice_, OBJ_EDIT, 0, 0, 0);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_XSIZE, 1500);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_YSIZE, 80);
//   ObjectSetString(0, buttonPrice_, OBJPROP_TEXT, "buttonPrice_");
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_COLOR, clrAqua);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_XDISTANCE, 20);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_YDISTANCE, 500);
//   ObjectSetInteger(0, buttonPrice_, OBJPROP_FONTSIZE, 16);
//
//
//// LEFT LOWER 3
//// ATR
//   ObjectCreate(0, buttonATR_, OBJ_EDIT, 0, 0, 0);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_XSIZE, 1500);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_YSIZE, 80);
//   ObjectSetString(0, buttonATR_, OBJPROP_TEXT, "buttonATR_");
//   ObjectSetInteger(0, buttonATR_, OBJPROP_COLOR, clrYellow);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_XDISTANCE, 20);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_YDISTANCE, 400);
//   ObjectSetInteger(0, buttonATR_, OBJPROP_FONTSIZE, 16);
//
//
//// LEFT LOWER 2
//// ADX
//   ObjectCreate(0, buttonAdxValue_, OBJ_EDIT, 0, 0, 0);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_XSIZE, 1500);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_YSIZE, 80);
//   ObjectSetString(0, buttonAdxValue_, OBJPROP_TEXT, "buttonAdxValue_");
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_COLOR, clrWhite);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_XDISTANCE, 20);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_YDISTANCE, 300);
//   ObjectSetInteger(0, buttonAdxValue_, OBJPROP_FONTSIZE, 16);
//   //ObjectSetInteger(0, buttonAdxValue_, OBJPROP_ANCHOR, ANCHOR_LEFT);
//
//
//// LEFT LOWER 1
//   // ADX - DIplus
//   ObjectCreate(0, buttonAdxDiPlus_, OBJ_EDIT, 0, 0, 0);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_XSIZE, 1500);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_YSIZE, 80);
//   ObjectSetString(0, buttonAdxDiPlus_, OBJPROP_TEXT, "buttonAdxDiPlus_");
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_COLOR, clrGreen);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_XDISTANCE, 20);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_YDISTANCE, 200);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_FONTSIZE, 16);
//   ObjectSetInteger(0, buttonAdxDiPlus_, OBJPROP_ALIGN, ALIGN_LEFT);

// LEFT LOWER 0   
   ObjectCreate(0, labelLeftLower0, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_XSIZE, 1500);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_YSIZE, 80);
   ObjectSetString(0, labelLeftLower0, OBJPROP_TEXT, "labelLeftLower0");
   //ObjectSetInteger(0, labelLeftLower0, OBJPROP_COLOR, clrRed); default is red
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, labelLeftLower0, OBJPROP_ALIGN, ALIGN_LEFT);


// RIGHT LOWER 0
// TIME
   ObjectCreate(0, buttonCurrentTime_, OBJ_BUTTON, 0, 0, 0);
   //ObjectCreate(0, buttonCurrentTime_, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_XSIZE, 700);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_YSIZE, 80);
   ObjectSetString(0, buttonCurrentTime_, OBJPROP_TEXT, "buttonCurrentTime_");
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_ALIGN, ALIGN_CENTER);   
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_XDISTANCE, 720);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, buttonCurrentTime_, OBJPROP_FONTSIZE, 14);


}