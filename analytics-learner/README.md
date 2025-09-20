# analytics-learner

Modular Python stack for data collection, feature engineering, model training (XGBoost + Transformer), ONNX export, walk-forward/backtest, and signal generation.

## Features
- Loads market/trade data and features
- Trains XGBoost and small Transformer ensembles
- Exports models to ONNX for fast inference
- Walk-forward validation and backtest pipeline
- Generates compact trading signals
- Unit tests (pytest)
- Dockerized for reproducible runs
- CI workflow for lint, tests, and build

## Quick Start
1. `docker build -t analytics-learner .`
2. `docker run --rm analytics-learner`
3. Or run locally:
   ```
   pip install -r requirements.txt
   pytest src/tests
   python src/models/train_xgb.py
   python src/models/export_onnx.py
   python src/signals/generate_signal.py
   ```

## Architecture Diagram
```
+-------------------+
| sample_market_data|
+-------------------+
         |
         v
+-------------------+
| Data Loader       |
+-------------------+
         |
         v
+-------------------+
| Feature Pipeline  |
+-------------------+
         |
         v
+-------------------+
| Model Training    |
+-------------------+
         |
         v
+-------------------+
| ONNX Export       |
+-------------------+
         |
         v
+-------------------+
| Signal Generator  |
+-------------------+
```

## Security Checklist
- No secrets in code; use environment variables for sensitive configs
- TLS recommended for remote data sources
- Model files and signals stored with restricted permissions

## Acceptance Criteria
- All modules run and pass tests
- Models export to ONNX and can be loaded for inference
- Signals generated in correct format
- CI workflow passes

## Files
- requirements.txt
- Dockerfile
- src/data/loader.py, features.py, sample_market_data.csv
- src/models/train_xgb.py, train_transformer.py, export_onnx.py, inference.py, walkforward.py
- src/signals/generate_signal.py
- src/tests/
- sample_signals/latest.json
