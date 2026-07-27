# Import Libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick

sns.set(style="whitegrid")
# Load Datasets
trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\raw_data\Uber Trip Details.csv")
locations = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\raw_data\Location Table.csv")
# Inspect
trips.head(5)
trips.shape
trips.info()
locations.head(5)
locations.shape
locations.info()
