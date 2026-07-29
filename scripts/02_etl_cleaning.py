import pandas as pd

import pandas as pd
import os

BASE_DIR = os.path.join("..", "data")

# Load datasets
trips = pd.read_csv(os.path.join(BASE_DIR, "raw_data", "Uber Trip Details.csv"))
locations = pd.read_csv(os.path.join(BASE_DIR, "raw_data", "Location Table.csv"))

# Clean column names
trips.columns = trips.columns.str.strip().str.lower().str.replace(" ", "_")
locations.columns = locations.columns.str.strip().str.lower().str.replace(" ", "_")

# Convert datetime
trips['pickup_time'] = pd.to_datetime(trips['pickup_time'])
trips['drop_off_time'] = pd.to_datetime(trips['drop_off_time'])

# Feature engineering
trips['trip_duration_minutes'] = (trips['drop_off_time'] - trips['pickup_time']).dt.total_seconds()/60
trips['total_fare'] = trips['fare_amount'] + trips['surge_fee']
trips['hour'] = trips['pickup_time'].dt.hour
trips['day'] = trips['pickup_time'].dt.day
trips['month'] = trips['pickup_time'].dt.month
trips['weekday'] = trips['pickup_time'].dt.day_name()

# Merge pickup & dropoff locations
trips = trips.merge(locations, left_on="pulocationid", right_on="locationid", how="left", suffixes=("", "_pickup"))
trips = trips.merge(locations, left_on="dolocationid", right_on="locationid", how="left", suffixes=("", "_dropoff"))

# Save cleaned data
trip_details_path = r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv"
location_table_path = r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Location_Table_Cleaned.csv"

trips.to_csv(trip_details_path, index=False)
locations.to_csv(location_table_path, index=False)

print("Cleaned data saved successfully!")
