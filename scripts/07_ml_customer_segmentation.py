import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns

trips = pd.read_csv(r"F:\ubar-trip-analysis-logistics\data\cleaned_data\Trip_Details_Cleaned.csv")

X = trips[['trip_distance','total_fare','passenger_count']]
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
trips['cluster'] = kmeans.fit_predict(X_scaled)

cluster_summary = trips.groupby('cluster')[['trip_distance','total_fare','passenger_count']].mean()
print("Cluster Summary:\n", cluster_summary)

plt.figure(figsize=(10,6))
sns.scatterplot(x='trip_distance', y='total_fare', hue='cluster', palette='Set2', data=trips, alpha=0.6)
plt.title("Customer Segmentation: Distance vs Fare", fontsize=14, fontweight='bold')
plt.show()
