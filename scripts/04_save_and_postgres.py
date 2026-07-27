import pandas as pd
from sqlalchemy import create_engine
import psycopg2

# Load cleaned data
trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv")
locations = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Location_Table_Cleaned.csv")

# PostgreSQL connection
username = "postgres"
password = "1234"
host = "localhost"
port = "5432"
database = "ubar_trip_analysis"

engine = create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")

try:
    conn = psycopg2.connect(dbname=database, user=username, password=password, host=host, port=port)
    print("Connection successful!")
    conn.close()
except Exception as e:
    print("Connection failed:", e)

# Upload tables
trips.to_sql("Trip_Details", engine, if_exists="replace", index=False)
locations.to_sql("Location_Table", engine, if_exists="replace", index=False)

print("Data successfully loaded into PostgreSQL!")
