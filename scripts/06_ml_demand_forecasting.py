import pandas as pd
import matplotlib.pyplot as plt
from prophet import Prophet

trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv")

demand = trips.groupby('pickup_time').size().reset_index(name='trips')
demand.rename(columns={'pickup_time':'ds','trips':'y'}, inplace=True)

model = Prophet()
model.fit(demand)

future = model.make_future_dataframe(periods=168, freq='H')
forecast = model.predict(future)

model.plot(forecast)
plt.title("Forecasted Trip Demand (Next 7 Days)", fontsize=14, fontweight='bold')
plt.show()
