import pytest
import numpy as np
from src.models.inference import run_onnx_inference

@pytest.mark.skip(reason="Requires ONNX model export first.")
def test_run_onnx_inference():
    features = np.array([[0.001, 0.01, 0.05]])
    preds = run_onnx_inference('src/models/xgb_model.onnx', features)
    assert preds.shape[0] == 1
