# mt5-executor

Production-grade MetaTrader 5 Expert Advisor for safe, automated trading via signed local signals.

## Features
- Reads signed JSON signals from `C:\titanovax\signals\latest.json`.
- Validates HMAC-SHA256 signature using key from encrypted file.
- Executes trades with strict risk controls (max loss, max open trades, daily drawdown).
- Logs all executions to `C:\titanovax\logs\exec_log.csv`.
- Heartbeat/status file at `C:\titanovax\state\hb.json`.
- Chart screenshot routine on trade.
- PowerShell scripts for deployment and signal simulation.

## Quick Start
1. **Compile EA**: Open `SignalExecutorEA.mq5` in MetaEditor, compile (no warnings).
2. **Deploy**: Run `deploy.ps1` in PowerShell (as Administrator) to set up folders and demo HMAC key.
3. **Attach EA**: In MT5, attach EA to EURUSD M1 chart, enable AlgoTrading.
4. **Simulate Signals**: Run `simulate_signals.ps1` to write demo signals and trigger EA.
5. **Check Logs**: View `C:\titanovax\logs\exec_log.csv` and `C:\titanovax\state\hb.json` for activity.

## Acceptance Criteria
- EA compiles and runs in MT5, executes demo trades on demo account.
- Refuses to trade if risk limits or disabled.lock present.
- Writes logs and heartbeat as specified.
- All secrets handled securely (local files only).

## Security Checklist
- HMAC key stored encrypted, never hardcoded.
- No external network calls in EA.
- All sensitive files (keys, logs) have restricted permissions.
- Manual unlock required after daily drawdown stop.

## Architecture Diagram
```
+-------------------+
| Signal JSON File  |
+-------------------+
         |
         v
+-------------------+
| SignalExecutorEA  |
+-------------------+
   |   |   |   |   |
   v   v   v   v   v
Logs  HB  Orders  Screenshots  Disabled.lock
```

## Test Commands
- `powershell -ExecutionPolicy Bypass -File .\deploy.ps1`
- `powershell -ExecutionPolicy Bypass -File .\simulate_signals.ps1`

## Integration Test Steps
- Compile EA, deploy, run simulation, verify logs and status files.

## Files
- SignalExecutorEA.mq5
- signal_schema.json
- deploy.ps1
- simulate_signals.ps1
- sample_signals/latest.json
- sample_signals/latest.json.hmac
