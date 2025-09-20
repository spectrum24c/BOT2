import json
import hashlib
import pandas as pd
from src.data.features import add_features
from src.data.loader import load_market_data
from src.models.inference import run_onnx_inference

def generate_signal(data_path: str, onnx_path: str, out_path: str):
    df = load_market_data(data_path)
    df = add_features(df)
    features = df[['returns', 'volatility', 'momentum']].iloc[-1].values.reshape(1, -1)
    pred = run_onnx_inference(onnx_path, features)
    side = "BUY" if pred[0] > 0.5 else "SELL"
    signal = {
        "timestamp": int(df['timestamp'].iloc[-1]),
        "symbol": df['symbol'].iloc[-1],
        "side": side,
        "volume": 0.01,
        "price": float(df['close'].iloc[-1]),
        "modelId": "ensemble-v1",
        "model_version": "2025-09-19",
        "features_hash": "sha256:" + hashlib.sha256(str(features).encode()).hexdigest()[:8],
        "meta": {"reason": "auto", "confidence": float(pred[0])}
    }
    with open(out_path, "w") as f:
        json.dump(signal, f, indent=2)
    print(f"Signal written to {out_path}")

if __name__ == "__main__":
    generate_signal("../../data/sample_market_data.csv", "../models/xgb_model.onnx", "../../sample_signals/latest.json")
