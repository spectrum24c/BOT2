import pandas as pd
import xgboost as xgb
from src.data.features import add_features
from src.data.loader import load_market_data

def walkforward_validation(data_path: str):
    df = load_market_data(data_path)
    df = add_features(df)
    X = df[['returns', 'volatility', 'momentum']]
    y = (df['returns'] > 0).astype(int)
    split = int(len(df) * 0.7)
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]
    model = xgb.XGBClassifier(n_estimators=10, max_depth=3)
    model.fit(X_train, y_train)
    acc = model.score(X_test, y_test)
    print(f"Walk-forward accuracy: {acc:.2f}")

if __name__ == "__main__":
    walkforward_validation("../../data/sample_market_data.csv")
