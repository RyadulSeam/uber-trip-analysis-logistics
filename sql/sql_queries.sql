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

-- =============================================

-- Overview KPIs

-- =============================================


SELECT
    COUNT(*)                                   AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)         AS total_booking_value,
    ROUND(AVG(total_fare)::numeric, 2)         AS avg_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)      AS total_trip_distance_miles,
    ROUND(AVG(trip_distance)::numeric, 2)      AS avg_trip_distance_miles,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time_minutes
FROM "Trip_Details";


-- =============================================

-- Payment Type Distribution

-- =============================================


SELECT
    payment_type,
    COUNT(*) AS bookings,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND((100.0 * SUM(total_fare) / SUM(SUM(total_fare)) OVER ())::numeric, 1) AS pct_value
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY bookings DESC;

-- =============================================


-- Day vs Night Split

-- =============================================


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


-- =============================================

--Vehicle Type Analysis


-- =============================================


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


-- =============================================


-- Most frequent pickup


-- =============================================


SELECT location AS most_frequent_pickup, COUNT(*) AS trips
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- =============================================


-- Most frequent drop-off


-- =============================================


SELECT location_dropoff AS most_frequent_dropoff, COUNT(*) AS trips
FROM "Trip_Details"
WHERE location_dropoff IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- =============================================


-- Top 10 locations by booking value


-- =============================================


SELECT
    location,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY 1
ORDER BY booking_value DESC
LIMIT 10;


-- =============================================


-- Farthest Trip


-- =============================================


SELECT
    DATE(pickup_time) AS trip_date,
    COUNT(*) AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;

-- =============================================


-- Daily Trend


-- =============================================


SELECT
    DATE(pickup_time) AS trip_date,
    COUNT(*) AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;

-- =============================================


-- Time Analysis – By Hour


-- =============================================


SELECT
    hour,
    COUNT(*) AS bookings,
    ROUND(SUM(total_fare)::numeric, 0) AS booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;


-- =============================================


-- Time Analysis – By Day of Week


-- =============================================


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

-- =============================================


-- Hour × Day Heatmap Data


-- =============================================


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

-- =============================================


-- Details / Drill-through Table


-- =============================================


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

-- =============================================


-- Peak Hours for Driver Allocation


-- =============================================


SELECT
    hour,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(surge_fee)::numeric, 0) AS total_surge_revenue
FROM "Trip_Details"
GROUP BY hour
ORDER BY trips DESC;


-- =============================================


-- Revenue per Vehicle Type (Upsell Opportunity)


-- =============================================


SELECT
    vehicle,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS revenue_per_trip,
    ROUND((100.0 * SUM(total_fare) / SUM(SUM(total_fare)) OVER ())::numeric, 1) AS revenue_share_pct
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY revenue_per_trip DESC;

-- =============================================


-- High-Value Customer Segments (Long + High Fare)


-- =============================================


SELECT
    CASE
        WHEN trip_distance < 2 AND total_fare < 12 THEN 'Short Low-Fare'
        WHEN trip_distance BETWEEN 2 AND 6 AND total_fare BETWEEN 12 AND 25 THEN 'Medium Standard'
        WHEN trip_distance > 6 AND total_fare > 25 THEN 'Long High-Fare'
        WHEN passenger_count >= 3 THEN 'Group Ride'
        ELSE 'Other'
    END AS segment,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 0) AS total_revenue
FROM "Trip_Details"
GROUP BY 1
ORDER BY total_revenue DESC;


-- =============================================


-- Surge Pricing Effectiveness


-- =============================================


SELECT
    hour,
    COUNT(*) FILTER (WHERE surge_fee > 0) AS surged_trips,
    COUNT(*) AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE surge_fee > 0) / COUNT(*), 1) AS surge_pct,
    ROUND(SUM(surge_fee)::numeric, 0) AS surge_revenue
FROM "Trip_Details"
GROUP BY hour
ORDER BY surge_revenue DESC;

-- =============================================


-- Top Revenue Routes (Pickup → Drop-off)


-- =============================================


SELECT
    location || ' → ' || location_dropoff AS route,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM "Trip_Details"
WHERE location IS NOT NULL AND location_dropoff IS NOT NULL
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;

-- =============================================


-- Payment Method by Vehicle (Cross-sell / Incentive)


-- =============================================


SELECT
    vehicle,
    payment_type,
    COUNT(*) AS trips,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY vehicle), 1) AS pct_within_vehicle
FROM "Trip_Details"
GROUP BY vehicle, payment_type
ORDER BY vehicle, trips DESC;


-- =============================================


-- Weekend vs Weekday Performance


-- =============================================


SELECT
    CASE WHEN weekday IN ('Saturday', 'Sunday') THEN 'Weekend' ELSE 'Weekday' END AS period,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM "Trip_Details"
GROUP BY 1;

-- =============================================


-- Under-performing Locations (Low trips but high avg fare – potential growth)


-- =============================================


SELECT
    location,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY 1
HAVING COUNT(*) BETWEEN 50 AND 300          -- medium volume
ORDER BY avg_fare DESC
LIMIT 10;

-- =============================================


-- Revenue Leakage – Low-Fare Long Trips (Pricing Opportunity)

-- =============================================

-- "Trip_Details" that are long but have unusually low fare → possible underpricing


SELECT
    location || ' → ' || location_dropoff AS route,
    trip_distance,
    total_fare,
    ROUND((total_fare / NULLIF(trip_distance, 0))::numeric, 2) AS fare_per_mile,
    vehicle,
    hour,
    weekday
FROM "Trip_Details"
WHERE trip_distance > 8
  AND (total_fare / NULLIF(trip_distance, 0)) < 3.5   -- adjust threshold
ORDER BY trip_distance DESC
LIMIT 30;


-- =============================================


-- Best Hours to Push Premium Vehicles (Upsell Window)


-- =============================================


SELECT
    hour,
    COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) AS premium_trips,
    COUNT(*) AS total_trips,
    ROUND((100.0 * COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) 
           / COUNT(*))::numeric, 1) AS premium_share_pct,
    ROUND(AVG(total_fare) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL'))::numeric, 2) AS avg_premium_fare
FROM "Trip_Details"
GROUP BY hour
ORDER BY premium_share_pct DESC;


-- =============================================


-- Cash vs Digital Payment by Time of Day (Reduce Cash Handling Cost)


-- =============================================


SELECT
    hour,
    COUNT(*) FILTER (WHERE payment_type = 'Cash') AS cash_trips,
    COUNT(*) FILTER (WHERE payment_type != 'Cash') AS digital_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type = 'Cash') / COUNT(*), 1) AS cash_pct
FROM "Trip_Details"
GROUP BY hour
ORDER BY cash_pct DESC;



-- =============================================


-- High-Demand Low-Supply Locations (Expansion / Driver Incentive Zones)


-- =============================================


SELECT
    location AS pickup_zone,
    COUNT(*) AS demand,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_duration_minutes)::numeric, 1) AS avg_duration,
    ROUND(SUM(surge_fee)::numeric, 0) AS total_surge
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) > 200
ORDER BY demand DESC
LIMIT 15;


-- =============================================


-- Weekend Night Revenue Opportunity


-- =============================================


SELECT
    weekday,
    CASE 
        WHEN hour BETWEEN 22 AND 23 OR hour BETWEEN 0 AND 4 
        THEN 'Late Night' 
        ELSE 'Other' 
    END AS period,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(surge_fee)::numeric, 0) AS surge_revenue
FROM "Trip_Details"
WHERE weekday IN ('Friday', 'Saturday', 'Sunday')
GROUP BY weekday, period
ORDER BY revenue DESC;


-- =============================================


-- Vehicle Mix Efficiency (Revenue per Mile)


-- =============================================


SELECT
    vehicle,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_miles,
    ROUND((SUM(total_fare) / NULLIF(SUM(trip_distance), 0))::numeric, 2) AS revenue_per_mile,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare_per_trip
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY revenue_per_mile DESC;


-- =============================================


-- Short-Trip Heavy Zones (Good for High Frequency / Loyalty)


-- =============================================


SELECT
    location,
    COUNT(*) AS short_trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM "Trip_Details"
WHERE trip_distance < 2.5
  AND location IS NOT NULL
GROUP BY location
HAVING COUNT(*) > 150
ORDER BY short_trips DESC
LIMIT 10;


-- =============================================


-- Surge Effectiveness by Zone


-- =============================================


SELECT
    location,
    COUNT(*) FILTER (WHERE surge_fee > 0) AS surged_trips,
    COUNT(*) AS total_trips,
    ROUND((100.0 * COUNT(*) FILTER (WHERE surge_fee > 0) / COUNT(*))::numeric, 1) AS surge_rate_pct,
    ROUND(SUM(surge_fee)::numeric, 0) AS surge_revenue,
    ROUND(AVG(total_fare) FILTER (WHERE surge_fee > 0)::numeric, 2) AS avg_fare_when_surged
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) > 100
ORDER BY surge_revenue DESC
LIMIT 15;


-- =============================================


-- Passenger Count Impact on Revenue


-- =============================================
SELECT
    passenger_count,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 0) AS total_revenue,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM "Trip_Details"
GROUP BY passenger_count
ORDER BY passenger_count;



-- =============================================


-- Day-of-Week × Vehicle Performance Matrix


-- =============================================


SELECT
    weekday,
    vehicle,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
GROUP BY weekday, vehicle
ORDER BY 
    CASE weekday
        WHEN 'Monday' THEN 1 
        WHEN 'Tuesday' THEN 2 
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 
        WHEN 'Friday' THEN 5 
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    revenue DESC;


-- =============================================


-- Top Cross-Borough Routes (Longer, Higher Value)


-- =============================================


SELECT
    city AS pickup_city,
    city_dropoff AS dropoff_city,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance
FROM "Trip_Details"
WHERE city IS NOT NULL 
  AND city_dropoff IS NOT NULL
  AND city != city_dropoff
GROUP BY city, city_dropoff
ORDER BY revenue DESC
LIMIT 15;


-- =============================================


-- Top 10 Locations by Revenue


-- =============================================


SELECT location, SUM(total_fare) AS revenue
FROM "Trip_Details"
GROUP BY location
ORDER BY revenue DESC
LIMIT 10;


-- =============================================


-- Top 10 Locations by Number of Trips


-- =============================================


SELECT location, COUNT(*) AS total_trips
FROM "Trip_Details"
GROUP BY location
ORDER BY total_trips DESC
LIMIT 10;


-- =============================================


-- Top 10 Locations by Average Fare


-- =============================================

SELECT 
    location, 
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    COUNT(*) AS trips
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 50          -- ignore very low volume locations
ORDER BY avg_fare DESC
LIMIT 10;


-- =============================================


-- Top 10 Locations by Total Distance


-- =============================================


SELECT 
    location, 
    ROUND(SUM(trip_distance)::numeric, 1) AS total_distance,
    COUNT(*) AS trips
FROM "Trip_Details"
GROUP BY location
ORDER BY total_distance DESC
LIMIT 10;


-- =============================================


-- Top 10 Locations by Surge Revenue


-- =============================================


SELECT 
    location, 
    ROUND(SUM(surge_fee)::numeric, 0) AS surge_revenue,
    COUNT(*) FILTER (WHERE surge_fee > 0) AS surged_trips
FROM "Trip_Details"
GROUP BY location
ORDER BY surge_revenue DESC
LIMIT 10;


-- =============================================


-- Locations with Highest Average Trip Duration


-- =============================================


SELECT 
    location, 
    ROUND(AVG(trip_duration_minutes)::numeric, 1) AS avg_duration_min,
    COUNT(*) AS trips
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 50
ORDER BY avg_duration_min DESC
LIMIT 10;


-- =============================================


-- Best Locations for Premium Vehicles


-- =============================================


SELECT 
    location,
    COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) AS premium_trips,
    COUNT(*) AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) / COUNT(*), 1) AS premium_share_pct,
    ROUND(SUM(total_fare) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL'))::numeric, 0) AS premium_revenue
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 80
ORDER BY premium_revenue DESC
LIMIT 10;



-- =============================================


-- Locations with Highest Cash Payment Share


-- =============================================


SELECT 
    location,
    COUNT(*) FILTER (WHERE payment_type = 'Cash') AS cash_trips,
    COUNT(*) AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type = 'Cash') / COUNT(*), 1) AS cash_pct
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 50
ORDER BY cash_pct DESC
LIMIT 10;


-- =============================================


-- Top Pickup → Drop-off Routes by Revenue


-- =============================================


SELECT 
    location || ' → ' || location_dropoff AS route,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
WHERE location IS NOT NULL AND location_dropoff IS NOT NULL
GROUP BY location, location_dropoff
ORDER BY revenue DESC
LIMIT 15;


-- =============================================


-- High Demand but Low Average Fare Locations (Growth Opportunity)


-- =============================================


SELECT 
    location,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 0) AS total_revenue
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 200 AND AVG(total_fare) < 14
ORDER BY trips DESC
LIMIT 10;



-- =============================================


-- Locations with Most Group Rides (3+ passengers)


-- =============================================


SELECT 
    location,
    COUNT(*) AS group_trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
WHERE passenger_count >= 3
GROUP BY location
ORDER BY group_trips DESC
LIMIT 10;

-- =============================================


-- Top Locations by Revenue per Trip


-- =============================================


SELECT 
    location,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS revenue_per_trip
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 80
ORDER BY revenue_per_trip DESC
LIMIT 10;

-- =============================================


-- Location Performance Score (Revenue + Demand + Efficiency)


-- =============================================


WITH loc_stats AS (
    SELECT 
        location,
        COUNT(*) AS trips,
        SUM(total_fare) AS revenue,
        AVG(total_fare) AS avg_fare,
        AVG(trip_distance) AS avg_distance,
        SUM(surge_fee) AS surge_revenue,
        AVG(trip_duration_minutes) AS avg_duration
    FROM "Trip_Details"
    WHERE location IS NOT NULL
    GROUP BY location
    HAVING COUNT(*) >= 50
)
SELECT 
    location,
    trips,
    ROUND(revenue::numeric, 0) AS revenue,
    ROUND(avg_fare::numeric, 2) AS avg_fare,
    ROUND(surge_revenue::numeric, 0) AS surge_revenue,
    ROUND((
        (revenue / NULLIF(SUM(revenue) OVER (), 0) * 0.4) +
        (trips::numeric / NULLIF(SUM(trips) OVER (), 0) * 0.3) +
        (avg_fare / NULLIF(MAX(avg_fare) OVER (), 0) * 0.3)
    )::numeric, 3) AS performance_score
FROM loc_stats
ORDER BY performance_score DESC
LIMIT 15;


-- =============================================


-- Underperforming High-Demand Locations (Pricing / Supply Opportunity)


-- =============================================


SELECT 
    location,
    COUNT(*) AS trips,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare / NULLIF(trip_distance, 0))::numeric, 2) AS fare_per_mile
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) > 300 
   AND AVG(total_fare) < (SELECT AVG(total_fare) * 0.85 FROM "Trip_Details")
ORDER BY trips DESC
LIMIT 10;


-- =============================================


-- Best Hours for Premium Upsell by Location


-- =============================================


SELECT 
    location,
    hour,
    COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) AS premium_trips,
    COUNT(*) AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL')) 
          / NULLIF(COUNT(*), 0), 1) AS premium_share_pct,
    ROUND(AVG(total_fare) FILTER (WHERE vehicle IN ('Uber Black', 'Uber Comfort', 'UberXL'))::numeric, 2) AS avg_premium_fare
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location, hour
HAVING COUNT(*) >= 20
ORDER BY premium_share_pct DESC, avg_premium_fare DESC
LIMIT 20;


-- =============================================


-- Revenue Concentration Risk (Top Locations Dependency)


-- =============================================


WITH ranked AS (
    SELECT 
        location,
        SUM(total_fare) AS revenue,
        SUM(SUM(total_fare)) OVER () AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(total_fare) DESC) AS rn
    FROM "Trip_Details"
    WHERE location IS NOT NULL
    GROUP BY location
)
SELECT 
    rn AS rank,
    location,
    ROUND(revenue::numeric, 0) AS revenue,
    ROUND((100.0 * revenue / total_revenue)::numeric, 1) AS revenue_share_pct,
    ROUND(SUM((100.0 * revenue / total_revenue)) OVER (ORDER BY rn)::numeric, 1) AS cumulative_share_pct
FROM ranked
WHERE rn <= 20
ORDER BY rn;


-- =============================================


-- High-Value Routes with Low Competition Signal


-- =============================================


SELECT 
    location || ' → ' || location_dropoff AS route,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance,
    ROUND(AVG(surge_fee)::numeric, 2) AS avg_surge
FROM "Trip_Details"
WHERE location IS NOT NULL 
  AND location_dropoff IS NOT NULL
  AND location != location_dropoff
GROUP BY location, location_dropoff
HAVING COUNT(*) BETWEEN 40 AND 180          
   AND AVG(total_fare) > 22
ORDER BY revenue DESC
LIMIT 15;

-- =============================================


-- Cash-Heavy Locations During Peak Hours (Digital Conversion Target)


SELECT 
    location,
    hour,
    COUNT(*) AS trips,
    COUNT(*) FILTER (WHERE payment_type = 'Cash') AS cash_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type = 'Cash') / COUNT(*), 1) AS cash_pct,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue
FROM "Trip_Details"
WHERE location IS NOT NULL
  AND hour BETWEEN 7 AND 10 OR hour BETWEEN 17 AND 21
GROUP BY location, hour
HAVING COUNT(*) >= 25 
   AND COUNT(*) FILTER (WHERE payment_type = 'Cash') * 1.0 / COUNT(*) > 0.35
ORDER BY cash_pct DESC, revenue DESC
LIMIT 15;


-- =============================================


-- Weekend vs Weekday Location Shift


-- =============================================


SELECT 
    location,
    COUNT(*) FILTER (WHERE weekday IN ('Saturday', 'Sunday')) AS weekend_trips,
    COUNT(*) FILTER (WHERE weekday NOT IN ('Saturday', 'Sunday')) AS weekday_trips,
    ROUND(SUM(total_fare) FILTER (WHERE weekday IN ('Saturday', 'Sunday'))::numeric, 0) AS weekend_revenue,
    ROUND(SUM(total_fare) FILTER (WHERE weekday NOT IN ('Saturday', 'Sunday'))::numeric, 0) AS weekday_revenue,
    ROUND(
        (AVG(total_fare) FILTER (WHERE weekday IN ('Saturday', 'Sunday'))::numeric -
         AVG(total_fare) FILTER (WHERE weekday NOT IN ('Saturday', 'Sunday'))::numeric)
    , 2) AS fare_difference
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) >= 80
ORDER BY weekend_revenue DESC
LIMIT 12;


-- =============================================


-- Potential Lost Revenue from Low Surge


-- =============================================


SELECT 
    location,
    hour,
    COUNT(*) AS trips,
    ROUND(AVG(surge_fee)::numeric, 2) AS avg_surge,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 0) AS current_revenue,
    ROUND((SUM(total_fare) * 1.12)::numeric, 0) AS potential_revenue_12pct_uplift
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location, hour
HAVING COUNT(*) >= 30 
   AND AVG(surge_fee) < 1.0
ORDER BY trips DESC
LIMIT 15;

-- =============================================


-- Group Ride Hotspots (XL / Family Opportunity)


-- =============================================


SELECT 
    location,
    COUNT(*) FILTER (WHERE passenger_count >= 3) AS group_trips,
    COUNT(*) AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE passenger_count >= 3) / COUNT(*), 1) AS group_share_pct,
    ROUND(AVG(total_fare) FILTER (WHERE passenger_count >= 3)::numeric, 2) AS avg_group_fare,
    ROUND(SUM(total_fare) FILTER (WHERE passenger_count >= 3)::numeric, 0) AS group_revenue
FROM "Trip_Details"
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) FILTER (WHERE passenger_count >= 3) >= 20
ORDER BY group_revenue DESC
LIMIT 10;



-- =============================================


-- Location Efficiency Ranking (Revenue per Minute)


-- =============================================



SELECT 
    location,
    COUNT(*) AS trips,
    ROUND(SUM(total_fare)::numeric, 0) AS revenue,
    ROUND(SUM(trip_duration_minutes)::numeric, 0) AS total_minutes,
    ROUND((SUM(total_fare) / NULLIF(SUM(trip_duration_minutes), 0))::numeric, 3) AS revenue_per_minute
FROM "Trip_Details"
WHERE location IS NOT NULL
  AND trip_duration_minutes > 0
GROUP BY location
HAVING COUNT(*) >= 60
ORDER BY revenue_per_minute DESC
LIMIT 12;

-- =============================================

