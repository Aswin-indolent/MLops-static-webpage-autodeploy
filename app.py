
from flask import Flask, request, jsonify
import joblib
import os

app = Flask(__name__)

MODEL_PATH = os.path.join(
    os.path.dirname(__file__),
    "iris_model.joblib"
)

model_data = joblib.load(MODEL_PATH)
model = model_data["model"]
target_names = model_data["target_names"]


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Iris ML API is running",
        "usage": "Send POST requests to /predict"
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"})


@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "Send a JSON object"}), 400

    features = [
        "sepal_length",
        "sepal_width",
        "petal_length",
        "petal_width"
    ]

    try:
        values = [float(data[key]) for key in features]
    except (KeyError, TypeError, ValueError):
        return jsonify({
            "error": "Provide all four flower measurements as numbers"
        }), 400

    if not all(0 < value <= 10 for value in values):
        return jsonify({
            "error": "Measurements must be greater than 0 and at most 10"
        }), 400

    prediction = int(model.predict([values])[0])

    return jsonify({
        "prediction": target_names[prediction],
        "class_id": prediction
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
