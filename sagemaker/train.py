import pandas as pd
from sklearn.linear_model import LinearRegression
import joblib
import os

data = pd.read_parquet("/opt/ml/input/data/train/")

X = data[["avg_temperature"]]
y = data["avg_humidity"]

model = LinearRegression()
model.fit(X, y)

joblib.dump(model, os.path.join("/opt/ml/model", "model.joblib"))
