-- =============================================


-- UBER TRIP ANALYSIS - SQL QUERIES


-- =============================================


-- Developed by Ryadul Seam


-- =============================================


-- check the data type  


-- =============================================


SELECT * FROM "Trip_Details";

SELECT * FROM "Location_Table";

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'Trip_Details';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'Location_Table';


-- Overview KPIs

SELECT
    COUNT(*)                                   AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)         AS total_booking_value,
    ROUND(AVG(total_fare)::numeric, 2)         AS avg_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)      AS total_trip_distance_miles,
    ROUND(AVG(trip_distance)::numeric, 2)      AS avg_trip_distance_miles,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time_minutes
FROM "Trip_Details";


-- Payment Type Distribution

SELECT
    payment_type,
    COUNT(*) AS bookings,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND((100.0 * SUM(total_fare) / SUM(SUM(total_fare)) OVER ())::numeric, 1) AS pct_value
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY bookings DESC;


-- Day vs Night Split


SELECT
    CASE 
        WHEN hour BETWEEN 6 AND 17 THEN 'Day Trip'
        ELSE 'Night Trip'
    END AS trip_type,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY bookings DESC;


--Vehicle Type Analysis

SELECT
    vehicle,
    COUNT(*)                                          AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 0)                AS total_booking_value,
    ROUND(AVG(trip_duration_minutes)::numeric, 0)     AS avg_trip_time_min,
    ROUND(SUM(trip_distance)::numeric, 1)             AS total_trip_distance,
    ROUND(AVG(trip_distance)::numeric, 2)             AS avg_trip_distance,
    ROUND(AVG(total_fare)::numeric, 2)                AS avg_fare
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY total_bookings DESC;


-- Most frequent pickup

SELECT location AS most_frequent_pickup, COUNT(*) AS trips
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Most frequent drop-off

SELECT location_dropoff AS most_frequent_dropoff, COUNT(*) AS trips
FROM "Trip_Details"
WHERE location_dropoff IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Top 10 locations by booking value

SELECT
    location,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY 1
ORDER BY booking_value DESC
LIMIT 10;

-- Farthest Trip

SELECT
    DATE(pickup_time) AS trip_date,
    COUNT(*) AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;


-- Daily Trend

SELECT
    DATE(pickup_time) AS trip_date,
    COUNT(*) AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;

-- Time Analysis – By Hour

SELECT
    hour,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;

-- Time Analysis – By Day of Week

SELECT
    weekday,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY weekday
ORDER BY 
    CASE weekday
        WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


-- Hour × Day Heatmap Data

SELECT
    hour,
    weekday,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value
FROM "Trip_Details"
GROUP BY hour, weekday
ORDER BY hour, 
    CASE weekday
        WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


-- Details / Drill-through Table

SELECT
    trip_id,
    city,
    location,
    vehicle,
    pickup_time,
    drop_off_time,
    surge_fee,
    trip_distance,
    passenger_count,
    payment_type,
    'Qtr ' || EXTRACT(QUARTER FROM pickup_time) AS quarter,
    TO_CHAR(pickup_time, 'Month') AS month,
    ROUND(total_fare::numeric, 1) AS avg_booking_value
FROM "Trip_Details"
ORDER BY pickup_time
LIMIT 100;   


-- Peak Hours for Driver Allocation

SELECT
    hour,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(surge_fee)::numeric, 0) AS total_surge_revenue
FROM "Trip_Details"
GROUP BY hour
ORDER BY trips DESC;

-- Revenue per Vehicle Type (Upsell Opportunity)

SELECT
    vehicle,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS revenue_per_trip,
    ROUND((100.0 * SUM(total_fare) / SUM(SUM(total_fare)) OVER ())::numeric, 1) AS revenue_share_pct
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY revenue_per_trip DESC;











