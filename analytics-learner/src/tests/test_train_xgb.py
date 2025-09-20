import pytest
import os
from src.models.train_xgb import train_xgb_model

def test_train_xgb_model(tmp_path):
    model_path = tmp_path / 'xgb_model.joblib'
    train_xgb_model('src/data/sample_market_data.csv', str(model_path))
    assert os.path.exists(model_path)
