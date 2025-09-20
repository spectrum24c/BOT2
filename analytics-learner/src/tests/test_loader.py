import pytest
from src.data.loader import load_market_data

def test_load_market_data():
    df = load_market_data('src/data/sample_market_data.csv')
    assert not df.empty
    assert 'symbol' in df.columns
    assert df['symbol'].iloc[0] == 'EURUSD'
