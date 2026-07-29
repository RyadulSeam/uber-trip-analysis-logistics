-- =====================================================================
-- Uber Trip Analysis — PostgreSQL Query Reference
-- Matches: Home / Overview Analysis / Time Analysis / Details pages
-- Tables : "Trip_Details" (fact), "Location_Table" (dimension)
-- Note   : total_fare = fare_amount + surge_fee  -> this is "Booking Value"
--          Day/Night split assumed as 06:00-17:59 = Day, else Night
--          (Power BI screenshots don't show the exact cutoff - adjust
--          the CASE statement below if your PBI logic differs)
-- =====================================================================


-- =====================================================================
-- HOME / OVERVIEW PAGE - KPI CARDS
-- 103.7K bookings | $1.6M value | $15.0 avg | 349K miles | 3 mi avg | 16 min avg
-- =====================================================================

SELECT
    COUNT(*)                                   AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)         AS total_booking_value,
    ROUND(AVG(total_fare)::numeric, 2)         AS avg_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)      AS total_trip_distance_miles,
    ROUND(AVG(trip_distance)::numeric, 2)      AS avg_trip_distance_miles,
    ROUND(AVG(trip_duration_minutes)::numeric, 0) AS avg_trip_time_minutes
FROM "Trip_Details"
WHERE pickup_time BETWEEN '2024-06-01' AND '2024-06-30 23:59:59';
-- Add: AND city = 'Manhattan'  (or the selected slicer value) to mirror the City filter


-- =====================================================================
-- OVERVIEW PAGE - Total Bookings / Value / Distance by Payment Type (donut)
-- =====================================================================

SELECT
    payment_type,
    COUNT(*)                            AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)  AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_bookings
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY total_bookings DESC;


-- =====================================================================
-- OVERVIEW PAGE - Total Bookings / Value / Distance by Trip Type (Day vs Night)
-- =====================================================================

SELECT
    CASE WHEN hour BETWEEN 6 AND 17 THEN 'Day Trip' ELSE 'Night Trip' END AS trip_type,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;


-- =====================================================================
-- OVERVIEW PAGE - Total Bookings / Value / Distance by Day (line chart, day of month)
-- =====================================================================

SELECT
    day,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY day
ORDER BY day;


-- =====================================================================
-- OVERVIEW PAGE - Location Analysis: Most Frequent Pickup / Dropoff Point
-- =====================================================================

-- Most frequent pickup point
SELECT location AS pickup_point, COUNT(*) AS total_bookings
FROM "Trip_Details"
GROUP BY location
ORDER BY total_bookings DESC
LIMIT 1;

-- Most frequent dropoff point
SELECT location_dropoff AS dropoff_point, COUNT(*) AS total_bookings
FROM "Trip_Details"
GROUP BY location_dropoff
ORDER BY total_bookings DESC
LIMIT 1;

-- Farthest single trip (Pickup -> Drop-off, miles)
SELECT
    location        AS pickup_point,
    location_dropoff AS dropoff_point,
    trip_distance
FROM "Trip_Details"
ORDER BY trip_distance DESC
LIMIT 1;


-- =====================================================================
-- OVERVIEW PAGE - Vehicle Type Analysis table
-- (Total Bookings, Total Booking Value, Avg Trip Time, Trip Distance by vehicle)
-- =====================================================================

SELECT
    vehicle,
    COUNT(*)                                     AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)           AS total_booking_value,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time_minutes,
    ROUND(SUM(trip_distance)::numeric, 0)        AS trip_distance
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY total_bookings DESC;


-- =====================================================================
-- OVERVIEW PAGE - Total Booking Value / Bookings / Distance by Location (top locations)
-- =====================================================================

SELECT
    location AS pickup_location,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS total_trip_distance
FROM "Trip_Details"
GROUP BY location
ORDER BY total_booking_value DESC
LIMIT 10;


-- =====================================================================
-- TIME ANALYSIS PAGE - by Pickup Time (Hour)
-- =====================================================================

SELECT
    hour,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;


-- =====================================================================
-- TIME ANALYSIS PAGE - by Day Name (Mon-Sun)
-- =====================================================================

SELECT
    weekday,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance
FROM "Trip_Details"
GROUP BY weekday
ORDER BY
    CASE weekday
        WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7 END;


-- =====================================================================
-- TIME ANALYSIS PAGE - Matrix: by Hour & Day (heatmap grid)
-- =====================================================================

SELECT
    hour,
    weekday,
    COUNT(*)                           AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2) AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric,0) AS trip_distance
FROM "Trip_Details"
GROUP BY hour, weekday
ORDER BY hour,
    CASE weekday
        WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7 END;


-- =====================================================================
-- TIME ANALYSIS PAGE - Tooltip donut: Bookings / Value / Distance by Vehicle
-- (same shape as the Overview vehicle donut, used as a hover tooltip visual)
-- =====================================================================

SELECT
    vehicle,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0) AS trip_distance,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_share
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY total_bookings DESC;


-- =====================================================================
-- DETAILS PAGE - Drill-through table
-- (ID, City, Location, Vehicle, Pickup/Drop-off Time, Surge Fee, Distance,
--  Passengers, Payment Type, Quarter, Month, Avg Booking Value)
-- =====================================================================

SELECT
    trip_id                              AS id,
    city,
    location,
    vehicle,
    pickup_time,
    drop_off_time,
    surge_fee,
    trip_distance,
    passenger_count                      AS total_passenger,
    payment_type,
    'Qtr ' || EXTRACT(QUARTER FROM pickup_time)::int AS quarter,
    TO_CHAR(pickup_time, 'Month')        AS month,
    ROUND(total_fare, 1)                 AS avg_booking_value
FROM "Trip_Details"
WHERE pickup_time BETWEEN '2024-06-04' AND '2024-06-11 23:59:59'   -- date-range slicer
  -- AND city = 'Manhattan'                                        -- city slicer
ORDER BY trip_id;


-- =====================================================================
-- =====================================================================
-- EXTRA QUERIES - BUSINESS GROWTH INSIGHTS FOR THE CLIENT
-- (not shown in the current dashboard, but valuable follow-ups to pitch)
-- =====================================================================
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Revenue efficiency: $ earned per mile, per vehicle type
--    Helps decide which vehicle class to promote / incentivize drivers for
-- ---------------------------------------------------------------------
SELECT
    vehicle,
    ROUND(SUM(total_fare)::numeric, 2)   AS total_revenue,
    ROUND(SUM(trip_distance)::numeric,2) AS total_distance,
    ROUND((SUM(total_fare) / NULLIF(SUM(trip_distance), 0))::numeric, 2) AS revenue_per_mile
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY revenue_per_mile DESC;


-- ---------------------------------------------------------------------
-- 2. Peak-hour surge opportunity: hours with highest demand but low
--    surge revenue captured - potential to introduce/raise surge pricing
-- ---------------------------------------------------------------------
SELECT
    hour,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(surge_fee)::numeric, 2)     AS total_surge_collected,
    ROUND(AVG(surge_fee)::numeric, 2)     AS avg_surge_per_trip,
    ROUND(100.0 * SUM(surge_fee) / NULLIF(SUM(total_fare),0), 1) AS surge_pct_of_revenue
FROM "Trip_Details"
GROUP BY hour
ORDER BY total_bookings DESC;


-- ---------------------------------------------------------------------
-- 3. Weekend vs weekday performance - staffing & pricing strategy input
-- ---------------------------------------------------------------------
SELECT
    CASE WHEN weekday IN ('Saturday','Sunday') THEN 'Weekend' ELSE 'Weekday' END AS period_type,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_revenue,
    ROUND(AVG(total_fare)::numeric, 2)    AS avg_fare_per_trip
FROM "Trip_Details"
GROUP BY 1;


-- ---------------------------------------------------------------------
-- 4. Underperforming pickup zones: high trip count but low avg fare
--    -> candidates for pricing review or targeted promos
-- ---------------------------------------------------------------------
SELECT
    location,
    COUNT(*)                           AS total_bookings,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 2) AS total_revenue
FROM "Trip_Details"
GROUP BY location
HAVING COUNT(*) > 100          -- meaningful volume only
ORDER BY avg_fare ASC
LIMIT 15;


-- ---------------------------------------------------------------------
-- 5. High-value corridor pairs: top pickup -> dropoff routes by revenue
--    -> useful for route-based promotions or partnership deals (e.g. airports)
-- ---------------------------------------------------------------------
SELECT
    location        AS pickup,
    location_dropoff AS dropoff,
    COUNT(*)                           AS trip_count,
    ROUND(SUM(total_fare)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
GROUP BY location, location_dropoff
HAVING COUNT(*) >= 20
ORDER BY total_revenue DESC
LIMIT 15;


-- ---------------------------------------------------------------------
-- 6. Cash-to-digital payment shift opportunity: revenue currently in cash
--    -> quantifies the incentive budget worth offering to shift customers
--      toward digital payments (reduces cash-handling cost)
-- ---------------------------------------------------------------------
SELECT
    payment_type,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_revenue,
    ROUND(100.0 * SUM(total_fare) / SUM(SUM(total_fare)) OVER (), 1) AS pct_of_revenue
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- 7. Group-ride demand: trips with 3+ passengers by hour
--    -> signals demand for pooled/XL vehicle expansion at specific times
-- ---------------------------------------------------------------------
SELECT
    hour,
    COUNT(*) FILTER (WHERE passenger_count >= 3) AS group_trips,
    COUNT(*)                                     AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE passenger_count >= 3) / COUNT(*), 1) AS group_trip_pct
FROM "Trip_Details"
GROUP BY hour
ORDER BY group_trip_pct DESC;


-- ---------------------------------------------------------------------
-- 8. Long-distance trip profitability check: are long trips priced
--    proportionally, or is there margin loss beyond a distance threshold?
-- ---------------------------------------------------------------------
SELECT
    CASE
        WHEN trip_distance < 3  THEN '0-3 miles'
        WHEN trip_distance < 7  THEN '3-7 miles'
        WHEN trip_distance < 15 THEN '7-15 miles'
        ELSE '15+ miles'
    END AS distance_bucket,
    COUNT(*)                                                     AS total_trips,
    ROUND(AVG(total_fare)::numeric, 2)                           AS avg_fare,
    ROUND((SUM(total_fare) / NULLIF(SUM(trip_distance),0))::numeric, 2) AS revenue_per_mile
FROM "Trip_Details"
GROUP BY 1
ORDER BY MIN(trip_distance);


-- ---------------------------------------------------------------------
-- 9. City-level performance comparison (if client operates in multiple metros)
-- ---------------------------------------------------------------------
SELECT
    city,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_revenue,
    ROUND(AVG(total_fare)::numeric, 2)    AS avg_fare,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time
FROM "Trip_Details"
GROUP BY city
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------------------
-- 10. Week-over-week trend (once more months of data exist)
--     Currently only June 2024 is available; query is future-proofed for
--     when the client adds more months.
-- ---------------------------------------------------------------------
SELECT
    DATE_TRUNC('week', pickup_time)::date AS week_start,
    COUNT(*)                              AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)    AS total_revenue
FROM "Trip_Details"
GROUP BY 1
ORDER BY 1;


-- =====================================================================
-- NOTE ON CUSTOMER-LEVEL ANALYSIS
-- This dataset has no customer_id / rider_id column, only trip-level
-- records. Repeat-customer, retention, and loyalty queries (e.g. "top 10
-- riders by spend") are NOT possible with the current schema. If the
-- client can provide a customer/rider identifier in future data pulls,
-- that unlocks a whole additional layer of growth analysis (CLV, churn,
-- repeat-ride frequency) - worth flagging to the client as a data
-- collection recommendation.
-- =====================================================================
