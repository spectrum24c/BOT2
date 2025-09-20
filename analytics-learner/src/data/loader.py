import pandas as pd

def load_market_data(path: str) -> pd.DataFrame:
    """Load market data from CSV."""
    return pd.read_csv(path)

if __name__ == "__main__":
    df = load_market_data("sample_market_data.csv")
    print(df.head())
