
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
import joblib

iris = load_iris()

X = iris.data
y = iris.target

model = RandomForestClassifier(
    n_estimators=100,
    random_state=42
)

model.fit(X, y)

joblib.dump(
    {
        "model": model,
        "target_names": iris.target_names.tolist()
    },
    "iris_model.joblib"
)

print("Iris model trained and saved successfully.")
