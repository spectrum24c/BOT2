import pytest
import pandas as pd
from src.data.features import add_features
from src.data.loader import load_market_data

def test_add_features():
    df = load_market_data('src/data/sample_market_data.csv')
    df = add_features(df)
    assert 'returns' in df.columns
    assert 'volatility' in df.columns
    assert 'momentum' in df.columns
    assert abs(df['returns'].iloc[0]) < 1
