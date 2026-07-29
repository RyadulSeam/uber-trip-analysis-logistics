import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.preprocessing import LabelEncoder

BASE_DIR = os.path.join("..", "data")
trips = pd.read_csv(os.path.join(BASE_DIR, "cleaned_data", "Trip_Details_Cleaned.csv"))
locations = pd.read_csv(os.path.join(BASE_DIR, "cleaned_data", "Location_Table_Cleaned.csv"))

le = LabelEncoder()
trips['payment_encoded'] = le.fit_transform(trips['payment_type'])

X = trips[['trip_distance','trip_duration_minutes','total_fare','surge_fee']]
y = trips['payment_encoded']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y   
)


clf = RandomForestClassifier(n_estimators=200, random_state=42, class_weight='balanced')
clf.fit(X_train, y_train)

y_pred = clf.predict(X_test)
print(classification_report(y_test, y_pred, target_names=le.classes_))