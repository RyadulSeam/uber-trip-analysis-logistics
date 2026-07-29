import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
import psycopg2
import pandas as pd

BASE_DIR = os.path.join("..", "data")
trips = pd.read_csv(os.path.join(BASE_DIR, "cleaned_data", "Trip_Details_Cleaned.csv"))
locations = pd.read_csv(os.path.join(BASE_DIR, "cleaned_data", "Location_Table_Cleaned.csv"))

load_dotenv()

username = os.getenv("DB_USERNAME")
password = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
database = os.getenv("DB_NAME")

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
