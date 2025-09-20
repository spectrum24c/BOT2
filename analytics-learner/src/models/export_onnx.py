import joblib
import onnxruntime as ort
import skl2onnx
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

def export_xgb_to_onnx(model_path: str, onnx_path: str):
    model = joblib.load(model_path)
    initial_type = [('float_input', FloatTensorType([None, 3]))]
    onnx_model = convert_sklearn(model, initial_types=initial_type)
    with open(onnx_path, "wb") as f:
        f.write(onnx_model.SerializeToString())
    print(f"ONNX model exported to {onnx_path}")

if __name__ == "__main__":
    export_xgb_to_onnx("xgb_model.joblib", "xgb_model.onnx")
