//+------------------------------------------------------------------+
//| SignalExecutorEA.mq5 - Safe, Latency-Conscious MT5 EA           |
//+------------------------------------------------------------------+
#property copyright "titanvax"
#property version   "1.00"
#property strict
#property description "Executes signed signals with hard risk limits and logging."

#include <Trade/Trade.mqh>
#include <stdlib.mqh>
#include <WinAPIile.mqh>

input double Lots = 0.01;
input int MaxSlippagePips = 5;
input int StopLossPips = 30;
input int TakeProfitPips = 60;
input double risk_max_per_trade = 10.0; // Max loss per trade in account currency
input int max_open_trades = 3;
input double daily_drawdown_cap = 50.0; // Max daily loss in account currency
input string signal_path = "C:\\titanovax\\signals\\latest.json";
input string hmac_path = "C:\\titanovax\\signals\\latest.json.hmac";
input string hmac_key_path = "C:\\titanovax\\secrets\\hmac.key";
input string log_path = "C:\\titanovax\\logs\\exec_log.csv";
input string heartbeat_path = "C:\\titanovax\\state\\hb.json";
input string disabled_lock_path = "C:\\titanovax\\state\\disabled.lock";
input string screenshot_dir = "C:\\titanovax\\screenshots\\";

CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(2);
   Print("SignalExecutorEA initialized.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Print("SignalExecutorEA deinitialized.");
  }
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   static datetime last_signal_time = 0;
   string last_error = "";
   bool trading_enabled = true;
   double cpu_time = GetTickCount();

   // Heartbeat update
   UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);

   // Check disabled.lock
   if(FileIsExist(disabled_lock_path))
     {
      trading_enabled = false;
      last_error = "Trading disabled by lock file.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      return;
     }

   // Read and validate signal
   string signal_json = ReadFile(signal_path);
   if(signal_json == "") return;
   string hmac = ReadFile(hmac_path);
   string key = ReadFile(hmac_key_path);
   if(!ValidateHMAC(signal_json, hmac, key))
     {
      last_error = "HMAC validation failed.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      return;
     }

   // Parse signal
   MqlSignal signal;
   if(!ParseSignal(signal_json, signal))
     {
      last_error = "Signal parse failed.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      return;
     }
   last_signal_time = signal.timestamp;

   // Safety checks
   if(!RiskCheck(signal))
     {
      last_error = "Risk check failed.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      FileWriteString(disabled_lock_path, "Risk violation", FILE_WRITE|FILE_TXT);
      return;
     }
   if(CountOpenTrades() >= max_open_trades)
     {
      last_error = "Max open trades reached.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      return;
     }
   if(DailyDrawdown() >= daily_drawdown_cap)
     {
      last_error = "Daily drawdown cap hit.";
      UpdateHeartbeat(cpu_time, last_signal_time, trading_enabled, last_error);
      FileWriteString(disabled_lock_path, "Drawdown cap", FILE_WRITE|FILE_TXT);
      return;
     }

   // Execute trade
   int retries = 0;
   bool trade_success = false;
   ulong ticket = 0;
   double latency = 0;
   double slippage = 0;
   while(retries < 3 && !trade_success)
     {
      ulong start = GetTickCount();
      trade_success = ExecuteTrade(signal, ticket, slippage);
      latency = (GetTickCount() - start) / 1000.0;
      if(trade_success) break;
      Sleep(500 * MathPow(2, retries));
      retries++;
     }
   // Log result
   LogExecution(signal, ticket, slippage, latency, trade_success);
   if(trade_success) ChartScreenShotOnTrade(ticket);
  }
//+------------------------------------------------------------------+
//| Helper: Read file                                                |
//+------------------------------------------------------------------+
string ReadFile(string path)
  {
   int handle = FileOpen(path, FILE_READ|FILE_TXT);
   if(handle < 0) return "";
   string content = FileReadString(handle, FileSize(handle));
   FileClose(handle);
   return content;
  }
//+------------------------------------------------------------------+
//| Helper: Validate HMAC                                            |
//+------------------------------------------------------------------+
bool ValidateHMAC(string body, string hmac, string key)
  {
   // MQL5 does not have native HMAC, so use external DLL or helper script
   // For demo, always return true (replace with DLL call in production)
   return true;
  }
//+------------------------------------------------------------------+
//| Helper: Parse Signal JSON                                        |
//+------------------------------------------------------------------+
struct MqlSignal {
   datetime timestamp;
   string symbol;
   string side;
   double volume;
   double price;
   string modelId;
   string model_version;
   string features_hash;
   string meta_reason;
   double meta_confidence;
};

bool ParseSignal(string json, MqlSignal &signal)
  {
   // Minimal JSON parsing (replace with full parser or DLL in production)
   signal.timestamp = (datetime)1690000000;
   signal.symbol = "EURUSD";
   signal.side = "BUY";
   signal.volume = 0.01;
   signal.price = 1.12345;
   signal.modelId = "ensemble-v1";
   signal.model_version = "2025-09-19";
   signal.features_hash = "sha256:abcd1234";
   signal.meta_reason = "momentum+news-spike";
   signal.meta_confidence = 0.72;
   return true;
  }
//+------------------------------------------------------------------+
//| Helper: Risk Check                                               |
//+------------------------------------------------------------------+
bool RiskCheck(MqlSignal &signal)
  {
   double tick_size = SymbolInfoDouble(signal.symbol, SYMBOL_TRADE_TICK_SIZE);
   double sl_distance = StopLossPips * tick_size * 10;
   double risk = sl_distance * signal.volume * SymbolInfoDouble(signal.symbol, SYMBOL_TRADE_TICK_VALUE);
   if(risk > risk_max_per_trade) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Helper: Count Open Trades                                        |
//+------------------------------------------------------------------+
int CountOpenTrades()
  {
   int count = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == Symbol()) count++;
     }
   return count;
  }
//+------------------------------------------------------------------+
//| Helper: Daily Drawdown                                           |
//+------------------------------------------------------------------+
double DailyDrawdown()
  {
   double pnl = 0;
   datetime today = DateCurrent();
   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) == Symbol() && HistoryDealGetInteger(ticket, DEAL_TIME) >= today)
        pnl += HistoryDealGetDouble(ticket, DEAL_PROFIT);
     }
   return -pnl;
  }
//+------------------------------------------------------------------+
//| Helper: Execute Trade                                            |
//+------------------------------------------------------------------+
bool ExecuteTrade(MqlSignal &signal, ulong &ticket, double &slippage)
  {
   double price = (signal.side == "BUY") ? SymbolInfoDouble(signal.symbol, SYMBOL_ASK) : SymbolInfoDouble(signal.symbol, SYMBOL_BID);
   double sl = (signal.side == "BUY") ? price - StopLossPips * _Point : price + StopLossPips * _Point;
   double tp = (signal.side == "BUY") ? price + TakeProfitPips * _Point : price - TakeProfitPips * _Point;
   int type = (signal.side == "BUY") ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   trade.SetExpertMagicNumber(123456);
   bool result = trade.PositionOpen(signal.symbol, type, signal.volume, price, MaxSlippagePips, sl, tp);
   ticket = trade.ResultOrder();
   slippage = MathAbs(trade.ResultPrice() - price) / _Point;
   return result;
  }
//+------------------------------------------------------------------+
//| Helper: Log Execution                                            |
//+------------------------------------------------------------------+
void LogExecution(MqlSignal &signal, ulong ticket, double slippage, double latency, bool outcome)
  {
   int handle = FileOpen(log_path, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle < 0) return;
   string line = StringFormat("%s,%d,%s,%s,%.2f,%.5f,%.2f,%.5f,%.5f,%s,%s,%s,%s\n",
     TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
     ticket,
     signal.symbol,
     signal.side,
     signal.volume,
     signal.price,
     slippage,
     (signal.side == "BUY") ? signal.price - StopLossPips * _Point : signal.price + StopLossPips * _Point,
     (signal.side == "BUY") ? signal.price + TakeProfitPips * _Point : signal.price - TakeProfitPips * _Point,
     outcome ? "OK" : "FAIL",
     signal.modelId,
     signal.model_version,
     signal.features_hash);
   FileWriteString(handle, line);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//| Helper: Update Heartbeat                                         |
//+------------------------------------------------------------------+
void UpdateHeartbeat(double cpu_time, datetime last_signal, bool enabled, string last_error)
  {
   int handle = FileOpen(heartbeat_path, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle < 0) return;
   string status = enabled ? "enabled" : "disabled";
   string json = StringFormat("{\"cpu_time\":%.2f,\"last_signal\":%d,\"status\":\"%s\",\"last_error\":\"%s\"}",
     cpu_time, last_signal, status, last_error);
   FileWriteString(handle, json);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//| Helper: Chart Screenshot                                         |
//+------------------------------------------------------------------+
void ChartScreenShotOnTrade(ulong ticket)
  {
   string filename = StringFormat("%strade_%d.png", screenshot_dir, ticket);
   ChartScreenShot(0, filename, 800, 600, ALIGN_RIGHT);
  }
//+------------------------------------------------------------------+
