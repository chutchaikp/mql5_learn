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
#include <_HELPER.V6\TYPES.mqh>
//
//CPositionInfo m_position;
//CTrade trade;

// Telegram.mqh - Telegram Communication Include File

const ushort MONEYBAG      = 0xF4B0;
const ushort UP_TREND      = 0xF4C8;
const ushort DOWN_TREND    = 0xF4C9;
const ushort BAR_CHART     = 0xF4CA;
const ushort SPEAKER       = 0xF4E2;
const ushort MEMO          = 0xF4DD;
const ushort SL            = 0xF621;
const ushort TP            = 0xF600;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const string MONEYBAG_code = ShortToString(MONEYBAG);
const string UP_TREND_code  = ShortToString(UP_TREND);
const string DOWN_TREND_code  = ShortToString(DOWN_TREND);
const string BAR_CHART_code  = ShortToString(BAR_CHART);
const string SPEAKER_code  = ShortToString(SPEAKER);
const string MEMO_code  = ShortToString(MEMO);
const string SL_code = ShortToString(SL);
const string TP_code = ShortToString(TP);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SendMessageToTelegram(string message_, string chatId_, string botToken_) {
   string url = "https://api.telegram.org/bot" + botToken_ + "/sendMessage";
   string jsonMessage = "{\"chat_id\":\"" + chatId_ + "\", \"text\":\"" + message_ + "\"}";

   char postData[];
   ArrayResize(postData, StringToCharArray(jsonMessage, postData) - 1);

   int timeout = 5000;
   char result[];
   string responseHeaders;
// int responseCode = WebRequest("POST", url, "Content-Type: application/json", timeout, postData, result, responseHeaders);
   // Send the web request to the Telegram API
   int responseCode = WebRequest("POST", url, "Content-Type: application/json", timeout, postData, result, responseHeaders);

   if (responseCode == 200) {
      Print("Message sent successfully: ", message_);
      return true;
   } else {
      Print("Failed to send message. HTTP code: ", responseCode, " Error code: ", GetLastError());
      Print("Response: ", CharArrayToString(result));
      return false;
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TG_SendOrderMessage(string chatId_="", string botToken_="", ENUM_ORDER_TYPE order_type_=ORDER_TYPE_BUY, double tp_=100, double sl_=50) {

   char data[];
   char res[];
   string resHeaders;

   string TG_API_URL = "https://api.telegram.org";

   string msg = "" + ( order_type_==ORDER_TYPE_BUY ? UP_TREND_code + " LONG "  : DOWN_TREND_code + " SHORT " ) + " " + _Symbol
                +"\nTP = " + (string)tp_
                +"\nSL = " + (string)sl_
                +"\nBalance = " + (string)AccountInfoDouble(ACCOUNT_BALANCE)
                +"\n\xF551\  " + TimeToString(TimeLocal(),TIME_DATE)+" @ "+TimeToString(TimeLocal(),TIME_SECONDS) ;
   string encloded_msg = UrlEncode(msg);
   msg = encloded_msg;

   // Construct the URL for the Telegram API request to send a message
   // Format: https://api.telegram.org/bot{HTTP_API_TOKEN}/sendmessage?chat_id={CHAT_ID}&text={MESSAGE_TEXT}
   const string url = TG_API_URL + "/bot" + botToken_ + "/sendmessage?chat_id=" + chatId_ +
                      "&text=" + msg;

   // Send the web request to the Telegram API
   int send_res = WebRequest("POST", url, "", 10000, data, res, resHeaders);

   // Check the response status of the web request
   if (send_res == 200) {
      // If the response status is 200 (OK), print a success message
      Print("TELEGRAM MESSAGE SENT SUCCESSFULLY");
   } else if (send_res == -1) {
      // If the response status is -1 (error), check the specific error code
      if (GetLastError() == 4014) {
         // If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
         Print("PLEASE ADD THE ", TG_API_URL, " TO THE TERMINAL");
      }
      // Print a general error message if the request fails
      Print("UNABLE TO SEND THE TELEGRAM MESSAGE");
   } else if (send_res != 200) {
      // If the response status is not 200 or -1, print the unexpected response code and error code
      Print("UNEXPECTED RESPONSE ", send_res, " ERR CODE = ", GetLastError());
   }

   return true;
}

//+------------------------------------------------------------------+
bool TG_SendInfoMessage(string chatId_="", string botToken_="", string info_="") {

   char data[];
   char res[];
   string resHeaders;

   string TG_API_URL = "https://api.telegram.org";

   string msg = SPEAKER_code + "" + info_ + " - " + _Symbol               
                +"\nBalance = " + (string)AccountInfoDouble(ACCOUNT_BALANCE)
                +"\n\xF551\  " + TimeToString(TimeLocal(),TIME_DATE)+" @ "+TimeToString(TimeLocal(),TIME_SECONDS) ;
   string encloded_msg = UrlEncode(msg);
   msg = encloded_msg;

   // Construct the URL for the Telegram API request to send a message
   // Format: https://api.telegram.org/bot{HTTP_API_TOKEN}/sendmessage?chat_id={CHAT_ID}&text={MESSAGE_TEXT}
   const string url = TG_API_URL + "/bot" + botToken_ + "/sendmessage?chat_id=" + chatId_ +
                      "&text=" + msg;

   // Send the web request to the Telegram API
   int send_res = WebRequest("POST", url, "", 10000, data, res, resHeaders);

   // Check the response status of the web request
   if (send_res == 200) {
      // If the response status is 200 (OK), print a success message
      Print("TELEGRAM MESSAGE SENT SUCCESSFULLY");
   } else if (send_res == -1) {
      // If the response status is -1 (error), check the specific error code
      if (GetLastError() == 4014) {
         // If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
         Print("PLEASE ADD THE ", TG_API_URL, " TO THE TERMINAL");
      }
      // Print a general error message if the request fails
      Print("UNABLE TO SEND THE TELEGRAM MESSAGE");
   } else if (send_res != 200) {
      // If the response status is not 200 or -1, print the unexpected response code and error code
      Print("UNEXPECTED RESPONSE ", send_res, " ERR CODE = ", GetLastError());
   }

   return true;
}

//+------------------------------------------------------------------+
// TO GROUP (chatId) 
// FROM (botToken)
//+------------------------------------------------------------------+
bool TG_SendInfoMessage(const string chatId_, const string botToken_, const CONDITION_INFO &condition_info_, const string info_="") {

   char data[];
   char res[];
   string resHeaders;

   string TG_API_URL = "https://api.telegram.org";
   MqlTick tk;
   if (!SymbolInfoTick(Symbol(), tk)) {
      return false;
   }
   
   double cur_price = (tk.bid + tk.ask)/2;
   
   string msg = SPEAKER_code + "" + info_ + " - " + _Symbol       
                  + "\nEMA slope = " + (string)condition_info_.ema_slope
                  + "\nADX slope = " + (string)condition_info_.adx_slope
                  
                  + "\nPRICE = " + (string)cur_price
                  + "\nVWAP value = " + (string)condition_info_.vwap_is_over_price  + " " 
                        + ( cur_price > condition_info_.vwap_is_over_price ? " (over)" : " (under)" )
                                    
                +"\nBalance = " + (string)AccountInfoDouble(ACCOUNT_BALANCE)
                +"\n\xF551\  " + TimeToString(TimeLocal(),TIME_DATE)+" @ "+TimeToString(TimeLocal(),TIME_SECONDS) ;
   string encloded_msg = UrlEncode(msg);
   msg = encloded_msg;

   // Construct the URL for the Telegram API request to send a message
   // Format: https://api.telegram.org/bot{HTTP_API_TOKEN}/sendmessage?chat_id={CHAT_ID}&text={MESSAGE_TEXT}
   const string url = TG_API_URL + "/bot" + botToken_ + "/sendmessage?chat_id=" + chatId_ +
                      "&text=" + msg;

   // Send the web request to the Telegram API
   int send_res = WebRequest("POST", url, "", 10000, data, res, resHeaders);

   // Check the response status of the web request
   if (send_res == 200) {
      // If the response status is 200 (OK), print a success message
      Print("TELEGRAM MESSAGE SENT SUCCESSFULLY");
   } else if (send_res == -1) {
      // If the response status is -1 (error), check the specific error code
      if (GetLastError() == 4014) {
         // If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
         Print("PLEASE ADD THE ", TG_API_URL, " TO THE TERMINAL");
      }
      // Print a general error message if the request fails
      Print("UNABLE TO SEND THE TELEGRAM MESSAGE");
   } else if (send_res != 200) {
      // If the response status is not 200 or -1, print the unexpected response code and error code
      Print("UNEXPECTED RESPONSE ", send_res, " ERR CODE = ", GetLastError());
   }

   return true;
}


// FUNCTION TO ENCODE A STRING FOR USE IN URL
string UrlEncode(const string text) {
   string encodedText = ""; // Initialize the encoded text as an empty string
   int textLength = StringLen(text); // Get the length of the input text

   // Loop through each character in the input string
   for (int i = 0; i < textLength; i++) {
      ushort character = StringGetCharacter(text, i); // Get the character at the current position

      // Check if the character is alphanumeric or one of the unreserved characters
      if ((character >= 48 && character <= 57) ||  // Check if character is a digit (0-9)
            (character >= 65 && character <= 90) ||  // Check if character is an uppercase letter (A-Z)
            (character >= 97 && character <= 122) || // Check if character is a lowercase letter (a-z)
            character == '!' || character == '\'' || character == '(' ||
            character == ')' || character == '*' || character == '-' ||
            character == '.' || character == '_' || character == '~') {

         // Append the character to the encoded string without encoding
         encodedText += ShortToString(character);
      }
      // Check if the character is a space
      else if (character == ' ') {
         // Encode space as '+'
         encodedText += ShortToString('+');
      }
      // For all other characters, encode them using UTF-8
      else {
         uchar utf8Bytes[]; // Array to hold the UTF-8 bytes
         int utf8Length = ShortToUtf8(character, utf8Bytes); // Convert the character to UTF-8
         for (int j = 0; j < utf8Length; j++) {
            // Convert each byte to its hexadecimal representation prefixed with '%'
            encodedText += StringFormat("%%%02X", utf8Bytes[j]);
         }
      }
   }
   return encodedText; // Return the URL-encoded string
}

//+-----------------------------------------------------------------------+
//| Function to convert a ushort character to its UTF-8 representation    |
//+-----------------------------------------------------------------------+
int ShortToUtf8(const ushort character, uchar &utf8Output[]) {
   // Handle single byte characters (0x00 to 0x7F)
   if (character < 0x80) {
      ArrayResize(utf8Output, 1); // Resize the array to hold one byte
      utf8Output[0] = (uchar)character; // Store the character in the array
      return 1; // Return the length of the UTF-8 representation
   }
   // Handle two-byte characters (0x80 to 0x7FF)
   if (character < 0x800) {
      ArrayResize(utf8Output, 2); // Resize the array to hold two bytes
      utf8Output[0] = (uchar)((character >> 6) | 0xC0); // Store the first byte
      utf8Output[1] = (uchar)((character & 0x3F) | 0x80); // Store the second byte
      return 2; // Return the length of the UTF-8 representation
   }
   // Handle three-byte characters (0x800 to 0xFFFF)
   if (character < 0xFFFF) {
      if (character >= 0xD800 && character <= 0xDFFF) { // Ill-formed characters
         ArrayResize(utf8Output, 1); // Resize the array to hold one byte
         utf8Output[0] = ' '; // Replace with a space character
         return 1; // Return the length of the UTF-8 representation
      } else if (character >= 0xE000 && character <= 0xF8FF) { // Emoji characters
         int extendedCharacter = 0x10000 | character; // Extend the character to four bytes
         ArrayResize(utf8Output, 4); // Resize the array to hold four bytes
         utf8Output[0] = (uchar)(0xF0 | (extendedCharacter >> 18)); // Store the first byte
         utf8Output[1] = (uchar)(0x80 | ((extendedCharacter >> 12) & 0x3F)); // Store the second byte
         utf8Output[2] = (uchar)(0x80 | ((extendedCharacter >> 6) & 0x3F)); // Store the third byte
         utf8Output[3] = (uchar)(0x80 | (extendedCharacter & 0x3F)); // Store the fourth byte
         return 4; // Return the length of the UTF-8 representation
      } else {
         ArrayResize(utf8Output, 3); // Resize the array to hold three bytes
         utf8Output[0] = (uchar)((character >> 12) | 0xE0); // Store the first byte
         utf8Output[1] = (uchar)(((character >> 6) & 0x3F) | 0x80); // Store the second byte
         utf8Output[2] = (uchar)((character & 0x3F) | 0x80); // Store the third byte
         return 3; // Return the length of the UTF-8 representation
      }
   }
   // Handle invalid characters by replacing with the Unicode replacement character (U+FFFD)
   ArrayResize(utf8Output, 3); // Resize the array to hold three bytes
   utf8Output[0] = 0xEF; // Store the first byte
   utf8Output[1] = 0xBF; // Store the second byte
   utf8Output[2] = 0xBD; // Store the third byte
   return 3; // Return the length of the UTF-8 representation
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TG_GetBotToken() {
   string botToken = "7893921760:AAEKT10F8qvivrWiO2exmGNracbHA8iD4cU"; // Your Telegram bot token
   return botToken;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TG_GetChatID() {
   string chatId   = "-1002518559669"; // Your Telegram chat ID
   return chatId;
}


//+------------------------------------------------------------------+
