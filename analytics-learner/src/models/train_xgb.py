import pandas as pd
import xgboost as xgb
import joblib
from src.data.features import add_features
from src.data.loader import load_market_data

def train_xgb_model(data_path: str, model_path: str):
    df = load_market_data(data_path)
    df = add_features(df)
    X = df[['returns', 'volatility', 'momentum']]
    y = (df['returns'] > 0).astype(int)
    model = xgb.XGBClassifier(n_estimators=10, max_depth=3)
    model.fit(X, y)
    joblib.dump(model, model_path)
    print(f"Model saved to {model_path}")

if __name__ == "__main__":
    train_xgb_model("../../data/sample_market_data.csv", "xgb_model.joblib")
