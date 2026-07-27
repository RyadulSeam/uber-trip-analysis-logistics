import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
import numpy as np

trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv")

X = trips[['trip_distance','trip_duration_minutes','passenger_count','surge_fee']]
y = trips['total_fare']

X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2,random_state=42)

model = RandomForestRegressor(n_estimators=200, random_state=42)
model.fit(X_train,y_train)

y_pred = model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test,y_pred))

print("Fare Prediction RMSE:", rmse)
