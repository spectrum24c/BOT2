import pandas as pd
import numpy as np

def add_features(df: pd.DataFrame) -> pd.DataFrame:
    """Add basic features to market data."""
    df['returns'] = df['close'].pct_change().fillna(0)
    df['volatility'] = df['returns'].rolling(window=5).std().fillna(0)
    df['momentum'] = df['close'] - df['open']
    return df

if __name__ == "__main__":
    import loader
    df = loader.load_market_data("sample_market_data.csv")
    df = add_features(df)
    print(df.head())
