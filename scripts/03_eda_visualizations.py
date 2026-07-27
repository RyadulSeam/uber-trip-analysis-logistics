import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

sns.set(style="whitegrid")

# Load cleaned data
trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv")

# EDA: Exploratory Data Analysis
print("Missing values:\n", trips.isnull().sum())
print("Summary statistics:\n", trips.describe(include="all"))

# Missing Data Heatmap
plt.figure(figsize=(10,6))
sns.heatmap(trips.isnull(), cbar=False, cmap='Reds')
plt.title("Missing Data Heatmap", fontsize=14, fontweight='bold')
plt.xlabel("Columns")
plt.ylabel("Rows")
plt.show()

# Trips by Hour
plt.figure(figsize=(10,6))
sns.countplot(x='hour', data=trips, palette="viridis")
plt.title("Trips by Hour of Day", fontsize=14, fontweight='bold')
plt.xlabel("Hour of Day")
plt.ylabel("Number of Trips")
plt.xticks(rotation=0)
plt.show()

# Revenue by Vehicle Type
plt.figure(figsize=(10,6))
revenue_by_vehicle = trips.groupby('vehicle')['total_fare'].sum().sort_values(ascending=False)
sns.barplot(x=revenue_by_vehicle.index, y=revenue_by_vehicle.values, palette="Blues_d")
plt.title("Revenue by Vehicle Type", fontsize=14, fontweight='bold')
plt.xlabel("Vehicle Type")
plt.ylabel("Total Revenue ($)")
plt.xticks(rotation=45)
plt.show()

# Payment Type Distribution
plt.figure(figsize=(8,6))
sns.countplot(x='payment_type', data=trips, palette="Set2", order=trips['payment_type'].value_counts().index)
plt.title("Payment Type Distribution", fontsize=14, fontweight='bold')
plt.xlabel("Payment Method")
plt.ylabel("Number of Trips")
plt.xticks(rotation=30)
plt.show()

# Average Trip Duration by Pickup City
plt.figure(figsize=(12,6))
avg_duration_city = trips.groupby('city')['trip_duration_minutes'].mean().sort_values(ascending=False)
sns.barplot(x=avg_duration_city.index, y=avg_duration_city.values, palette="OrRd")
plt.title("Average Trip Duration by Pickup City", fontsize=14, fontweight='bold')
plt.xlabel("City")
plt.ylabel("Average Duration (Minutes)")
plt.xticks(rotation=75)
plt.show()

# Surge Fee Contribution
plt.figure(figsize=(6,6))
plt.pie([trips['surge_fee'].sum(), trips['fare_amount'].sum()],
        labels=['Surge Fee','Base Fare'],
        autopct='%1.1f%%',
        colors=['#ff9999','#66b3ff'],
        startangle=90)
plt.title("Surge Fee vs Base Fare Contribution", fontsize=14, fontweight='bold')
plt.show()

# Trips per Day
plt.figure(figsize=(12,6))
trips_per_day = trips.groupby('day')['trip_id'].count()
sns.lineplot(x=trips_per_day.index, y=trips_per_day.values, marker="o", color="navy")
plt.title("Trips per Day of Month", fontsize=14, fontweight='bold')
plt.xlabel("Day of Month")
plt.ylabel("Number of Trips")
plt.grid(True)
plt.show()

# Revenue Trend by Hour
plt.figure(figsize=(12,6))
revenue_by_hour = trips.groupby('hour')['total_fare'].sum()
sns.lineplot(x=revenue_by_hour.index, y=revenue_by_hour.values, marker="o", color="darkgreen")
plt.title("Revenue by Hour of Day", fontsize=14, fontweight='bold')
plt.xlabel("Hour of Day")
plt.ylabel("Total Revenue ($)")
plt.grid(True)
plt.show()

# Passenger Count Distribution
plt.figure(figsize=(8,6))
sns.countplot(x='passenger_count', data=trips, palette="coolwarm")
plt.title("Passenger Count Distribution", fontsize=14, fontweight='bold')
plt.xlabel("Passenger Count")
plt.ylabel("Number of Trips")
plt.show()

# Trip Distance Distribution
plt.figure(figsize=(10,6))
sns.histplot(trips['trip_distance'], bins=30, kde=True, color="purple")
plt.title("Trip Distance Distribution", fontsize=14, fontweight='bold')
plt.xlabel("Distance (miles)")
plt.ylabel("Frequency")
plt.show()

# Fare vs Distance Scatter
plt.figure(figsize=(10,6))
sns.scatterplot(x='trip_distance', y='total_fare', data=trips, hue='vehicle', alpha=0.7)
plt.title("Fare vs Trip Distance by Vehicle Type", fontsize=14, fontweight='bold')
plt.xlabel("Trip Distance (miles)")
plt.ylabel("Total Fare ($)")
plt.legend(title="Vehicle Type", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.show()

# Top 10 Pickup Locations
plt.figure(figsize=(12,6))
top_pickups = trips['location'].value_counts().head(10)
sns.barplot(x=top_pickups.index, y=top_pickups.values, palette="crest")
plt.title("Top 10 Pickup Locations", fontsize=16, fontweight='bold')
plt.xlabel("Pickup Location", fontsize=12)
plt.ylabel("Number of Trips", fontsize=12)
plt.xticks(rotation=75, ha="right")
plt.grid(axis='y', linestyle='--', alpha=0.7)
for i, v in enumerate(top_pickups.values):
    plt.text(i, v + 0.5, str(v), ha='center', fontweight='bold')
plt.tight_layout()
plt.show()

# Top 10 Dropoff Locations
plt.figure(figsize=(12,6))
top_dropoffs = trips['location_dropoff'].value_counts().head(10)
sns.barplot(x=top_dropoffs.index, y=top_dropoffs.values, palette="mako")
plt.title("Top 10 Dropoff Locations", fontsize=16, fontweight='bold')
plt.xlabel("Dropoff Location", fontsize=12)
plt.ylabel("Number of Trips", fontsize=12)
plt.xticks(rotation=75, ha="right")
plt.grid(axis='y', linestyle='--', alpha=0.7)
for i, v in enumerate(top_dropoffs.values):
    plt.text(i, v + 0.5, str(v), ha='center', fontweight='bold')
plt.tight_layout()
plt.show()
