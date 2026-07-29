# Import Libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick

sns.set(style="whitegrid")
# Load Datasets
import pandas as pd
import os

BASE_DIR = os.path.join("..", "data")

# Load datasets
trips = pd.read_csv(os.path.join(BASE_DIR, "raw_data", "Uber Trip Details.csv"))
locations = pd.read_csv(os.path.join(BASE_DIR, "raw_data", "Location Table.csv"))
# Inspect
trips.head(5)
trips.shape
trips.info()
locations.head(5)
locations.shape
locations.info()
