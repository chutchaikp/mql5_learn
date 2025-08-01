//+------------------------------------------------------------------+
//|                                                       HELPER.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//#property copyright "Copyright 2025, MetaQuotes Ltd."
//#property link "https://www.mql5.com"
//
//#include <Trade\Trade.mqh>
//#include <Trade\PositionInfo.mqh>
//#include <_ICT6.2\TYPES.mqh>
//
//CPositionInfo m_position;
//CTrade trade;

// Telegram.mqh - Telegram Communication Include File              

bool SendMessageToTelegram(string message_, string chatId_, string botToken_)
  {
   string url = "https://api.telegram.org/bot" + botToken_ + "/sendMessage";
   string jsonMessage = "{\"chat_id\":\"" + chatId_ + "\", \"text\":\"" + message_ + "\"}";

   char postData[];
   ArrayResize(postData, StringToCharArray(jsonMessage, postData) - 1);

   int timeout = 5000;
   char result[];
   string responseHeaders;
   int responseCode = WebRequest("POST", url, "Content-Type: application/json\r\n", timeout, postData, result, responseHeaders);

   if (responseCode == 200)
     {
      Print("Message sent successfully: ", message_);
      return true;
     }
   else
     {
      Print("Failed to send message. HTTP code: ", responseCode, " Error code: ", GetLastError());
      Print("Response: ", CharArrayToString(result));
      return false;
     }
  }
//+------------------------------------------------------------------+