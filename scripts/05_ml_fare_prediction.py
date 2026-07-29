import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_squared_error, r2_score 
import numpy as np


BASE_DIR = os.path.join("..", "data")
trips = pd.read_csv(os.path.join(BASE_DIR, "cleaned_data", "Trip_Details_Cleaned.csv"))

X = trips[['trip_distance', 'trip_duration_minutes', 'passenger_count']]
y = trips['fare_amount']   

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

fare_model = RandomForestRegressor(n_estimators=200, random_state=42)
fare_model.fit(X_train, y_train)

y_pred = fare_model.predict(X_test)

rmse = np.sqrt(mean_squared_error(y_test, y_pred))
r2 = r2_score(y_test, y_pred)

print("Fare Prediction RMSE:", rmse)
print("Fare Prediction R²:", r2)
