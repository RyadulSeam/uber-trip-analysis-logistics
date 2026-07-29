/* ============================================================
   UBER TRIP ANALYSIS — POWER BI DASHBOARD SUPPORTING QUERIES
   Tables: "Trip_Details", "Location_Table"
   (Mixed-case table names -> must stay double-quoted in Postgres)
   ============================================================ */


/* ------------------------------------------------------------
   SECTION 1: OVERVIEW PAGE
   ------------------------------------------------------------ */

-- 1.1 KPI Cards: Total Bookings | Total Booking Value | Avg Booking Value
--     | Total Trip Distance | Avg Trip Distance | Avg Trip Time
SELECT
    COUNT(*)                                   AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)         AS total_booking_value,
    ROUND(AVG(total_fare)::numeric, 2)         AS avg_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)      AS total_trip_distance_miles,
    ROUND(AVG(trip_distance)::numeric, 2)      AS avg_trip_distance_miles,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time_minutes
FROM "Trip_Details";


-- 1.2 Total Bookings by Payment Type (donut chart)
SELECT
    payment_type,
    COUNT(*) AS total_bookings,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY total_bookings DESC;

-- 1.2b Same donut, but by Total Booking Value / Trip Distance
--      (toggle metric to match the "Total Bookings / Total Booking Value / Trip Distance" tab switch)
SELECT
    payment_type,
    ROUND(SUM(total_fare)::numeric, 2)     AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)  AS total_trip_distance
FROM "Trip_Details"
GROUP BY payment_type
ORDER BY total_booking_value DESC;


-- 1.3 Total Bookings/Value/Distance by Trip Type (Day Trip vs Night Trip)
--     Day = 06:00–17:59, Night = 18:00–05:59  (adjust boundary if your business defines it differently)
SELECT
    CASE WHEN hour BETWEEN 6 AND 17 THEN 'Day Trip' ELSE 'Night Trip' END AS trip_type,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
GROUP BY 1;


-- 1.4 Total Bookings/Value/Distance by Day of Month (the wavy line chart, X axis 1–30)
SELECT
    day,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
GROUP BY day
ORDER BY day;


-- 1.5 Vehicle Type Analysis table (UberX / Uber Comfort / Uber Black / UberXL / Uber Green)
SELECT
    vehicle,
    COUNT(*)                                    AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)          AS total_booking_value,
    ROUND(AVG(trip_duration_minutes)::numeric,0) AS avg_trip_time_min,
    ROUND(SUM(trip_distance)::numeric, 0)       AS trip_distance
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY total_bookings DESC;


-- 1.6 Most Frequent Pickup Point
SELECT location, COUNT(*) AS trip_count
FROM "Trip_Details"
GROUP BY location
ORDER BY trip_count DESC
LIMIT 1;

-- 1.6b Most Frequent Dropoff Point
SELECT location_dropoff, COUNT(*) AS trip_count
FROM "Trip_Details"
GROUP BY location_dropoff
ORDER BY trip_count DESC
LIMIT 1;


-- 1.7 Farthest Trip (Pickup -> Dropoff, distance)
SELECT
    location          AS pickup_location,
    location_dropoff  AS dropoff_location,
    trip_distance
FROM "Trip_Details"
ORDER BY trip_distance DESC
LIMIT 1;


-- 1.8 Total Booking Value / Bookings / Trip Distance by Location (Top 10 pickup locations bar chart)
SELECT
    location,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
GROUP BY location
ORDER BY total_booking_value DESC
LIMIT 10;


/* ------------------------------------------------------------
   SECTION 2: TIME ANALYSIS PAGE
   ------------------------------------------------------------ */

-- 2.1 Total Bookings/Value/Distance by Pickup Hour (the 24-hour wave chart)
SELECT
    hour,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;


-- 2.2 Total Bookings/Value/Distance by Day Name (Mon–Sun line chart)
SELECT
    weekday,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
GROUP BY weekday
ORDER BY
    CASE weekday
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END;


-- 2.3 Hour x Day heatmap matrix (the grey-shaded grid with Hour rows, Mon–Sun columns)
SELECT
    hour,
    COUNT(*) FILTER (WHERE weekday = 'Monday')    AS mon,
    COUNT(*) FILTER (WHERE weekday = 'Tuesday')   AS tue,
    COUNT(*) FILTER (WHERE weekday = 'Wednesday') AS wed,
    COUNT(*) FILTER (WHERE weekday = 'Thursday')  AS thu,
    COUNT(*) FILTER (WHERE weekday = 'Friday')    AS fri,
    COUNT(*) FILTER (WHERE weekday = 'Saturday')  AS sat,
    COUNT(*) FILTER (WHERE weekday = 'Sunday')    AS sun
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;


-- 2.4 Total Bookings/Value/Distance by Vehicle within the tooltip donut (per-hour drill context)
--     Pass a specific hour when the user hovers/clicks a bar in the Hour & Day matrix
SELECT
    vehicle,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_booking_value,
    ROUND(SUM(trip_distance)::numeric, 0)   AS total_trip_distance
FROM "Trip_Details"
WHERE hour = 14              -- example: 2 PM tooltip
GROUP BY vehicle
ORDER BY total_bookings DESC;


/* ------------------------------------------------------------
   SECTION 3: DETAILS / DRILL-THROUGH PAGE
   ------------------------------------------------------------ */

-- 3.1 Raw trip-level table shown on the drill-through Details page
SELECT
    trip_id                                  AS id,
    city,
    location,
    vehicle,
    pickup_time,
    drop_off_time,
    surge_fee,
    trip_distance,
    passenger_count                          AS total_passenger,
    payment_type,
    'Qtr ' || CEIL(month::numeric / 3)        AS quarter,
    TO_CHAR(pickup_time, 'Month')             AS month,
    ROUND(total_fare::numeric, 1)             AS avg_booking_value
FROM "Trip_Details"
WHERE pickup_time BETWEEN '2024-06-04' AND '2024-06-11'   -- matches the date-range filter shown
ORDER BY trip_id;

-- 3.2 Distinct city list (for the "City" slicer/dropdown)
SELECT DISTINCT city
FROM "Trip_Details"
ORDER BY city;


/* ============================================================
   SECTION 4: EXTRA QUERIES — BUSINESS GROWTH INSIGHTS
   These aren't in the current dashboard but are strong additions
   for a client conversation about growing revenue/efficiency.
   ============================================================ */

-- 4.1 Revenue concentration (Pareto check): do a small % of pickup
--     locations drive most of the revenue? Useful for deciding where
--     to concentrate driver supply or local marketing.
WITH loc_rev AS (
    SELECT location, SUM(total_fare) AS revenue
    FROM "Trip_Details"
    GROUP BY location
),
ranked AS (
    SELECT location, revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS running_total,
           SUM(revenue) OVER ()                       AS grand_total
    FROM loc_rev
)
SELECT
    location,
    ROUND(revenue::numeric, 2)                                   AS revenue,
    ROUND(100.0 * running_total / grand_total, 1)                AS cumulative_pct_of_revenue
FROM ranked
ORDER BY revenue DESC;


-- 4.2 Low-demand hours (candidates for promos / discounted off-peak pricing
--     to keep drivers utilized and attract price-sensitive riders)
SELECT
    hour,
    COUNT(*) AS total_bookings,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
GROUP BY hour
ORDER BY total_bookings ASC
LIMIT 5;


-- 4.3 Cash vs Digital payment trend by day — track progress if the client
--     runs a campaign to shift riders from Cash to digital wallets
SELECT
    day,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type = 'Cash') / COUNT(*), 1) AS cash_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_type != 'Cash') / COUNT(*), 1) AS digital_pct
FROM "Trip_Details"
GROUP BY day
ORDER BY day;


-- 4.4 Most frequent pickup -> dropoff corridors (top 15 routes)
--     Useful for proposing fixed-route shuttles, subscription passes,
--     or pre-positioning drivers along high-traffic corridors
SELECT
    location          AS pickup,
    location_dropoff  AS dropoff,
    COUNT(*)           AS trip_count,
    ROUND(AVG(total_fare)::numeric, 2) AS avg_fare
FROM "Trip_Details"
GROUP BY location, location_dropoff
ORDER BY trip_count DESC
LIMIT 15;


-- 4.5 Surge revenue contribution by hour — shows exactly which hours
--     surge pricing is (or isn't) being captured; flags missed
--     dynamic-pricing opportunity during high-demand hours
SELECT
    hour,
    ROUND(SUM(surge_fee)::numeric, 2)   AS surge_revenue,
    ROUND(SUM(fare_amount)::numeric, 2) AS base_revenue,
    ROUND(100.0 * SUM(surge_fee) / NULLIF(SUM(fare_amount) + SUM(surge_fee), 0), 1) AS surge_pct_of_total
FROM "Trip_Details"
GROUP BY hour
ORDER BY hour;


-- 4.6 Vehicle profitability per mile (revenue efficiency, not just volume)
--     A vehicle with fewer bookings but higher $/mile may be worth promoting more
SELECT
    vehicle,
    ROUND(SUM(total_fare)::numeric, 2)                          AS total_revenue,
    ROUND(SUM(trip_distance)::numeric, 0)                       AS total_distance,
    ROUND(SUM(total_fare) / NULLIF(SUM(trip_distance), 0), 2)   AS revenue_per_mile
FROM "Trip_Details"
GROUP BY vehicle
ORDER BY revenue_per_mile DESC;


-- 4.7 Group ride share (passenger_count > 1) — signals demand for
--     shared-ride or larger-vehicle products (UberXL) by city
SELECT
    city,
    COUNT(*) FILTER (WHERE passenger_count > 1) AS group_trips,
    COUNT(*)                                     AS total_trips,
    ROUND(100.0 * COUNT(*) FILTER (WHERE passenger_count > 1) / COUNT(*), 1) AS group_trip_pct
FROM "Trip_Details"
GROUP BY city
ORDER BY group_trip_pct DESC;


-- 4.8 Weekend vs Weekday performance comparison
SELECT
    CASE WHEN weekday IN ('Saturday','Sunday') THEN 'Weekend' ELSE 'Weekday' END AS period,
    COUNT(*)                                AS total_bookings,
    ROUND(AVG(total_fare)::numeric, 2)      AS avg_fare,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_revenue
FROM "Trip_Details"
GROUP BY 1;


-- 4.9 Long-distance trip opportunities (beyond 10 miles) — candidates
--     for a premium/flat-rate "long trip" pricing tier or airport package
SELECT
    location, location_dropoff, trip_distance, total_fare, vehicle
FROM "Trip_Details"
WHERE trip_distance > 10
ORDER BY trip_distance DESC
LIMIT 20;


-- 4.10 City-level performance summary — compare markets to decide
--      where to invest in driver supply or marketing spend
SELECT
    city,
    COUNT(*)                                AS total_bookings,
    ROUND(SUM(total_fare)::numeric, 2)      AS total_revenue,
    ROUND(AVG(total_fare)::numeric, 2)      AS avg_fare,
    ROUND(AVG(trip_distance)::numeric, 2)   AS avg_distance
FROM "Trip_Details"
GROUP BY city
ORDER BY total_revenue DESC;
