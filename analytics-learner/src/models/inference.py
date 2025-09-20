import onnxruntime as ort
import numpy as np

def run_onnx_inference(onnx_path: str, features: np.ndarray):
    session = ort.InferenceSession(onnx_path)
    input_name = session.get_inputs()[0].name
    output = session.run(None, {input_name: features.astype(np.float32)})
    return output[0]

if __name__ == "__main__":
    features = np.array([[0.001, 0.01, 0.05]])
    preds = run_onnx_inference("xgb_model.onnx", features)
    print("Predictions:", preds)
