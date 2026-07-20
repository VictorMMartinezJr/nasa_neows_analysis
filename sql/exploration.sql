-- 1. PREVIEW ENTIRE DATASET
SELECT * FROM near_earth_objects;


-- 2. CHECK TOTAL ROW COUNT
SELECT COUNT(*) FROM near_earth_objects;


-- 3. CHECK UNIQUE ASTEROID COUNT
SELECT COUNT(DISTINCT asteroid_id) FROM near_earth_objects;

-- 4. AUDIT DATA INTEGRITY AND CHECK FOR MISSING VALUES (NULLS)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(asteroid_id) AS total_ids,
    COUNT(name) AS total_names,
    COUNT(close_approach_date) AS total_dates,
    COUNT(*) - COUNT(relative_velocity_kph) AS missing_velocities,
    COUNT(*) - COUNT(miss_distance_km) AS missing_distances
FROM near_earth_objects;


-- 5. GET HAZARDOUS VS NON-HAZARDOUS OBJECT COUNTS
SELECT
    COUNT(CASE WHEN is_potentially_hazardous = true THEN 1 END) AS num_of_hazardous_objects,
    COUNT(CASE WHEN is_potentially_hazardous = false THEN 1 END) AS num_of_non_hazardous_objects
FROM near_earth_objects;


-- 6. IDENTIFY THE LARGEST ASTEROID IN KM AND METERS
SELECT 
    name AS largest_object,
    estimated_diameter_max_km,
    (estimated_diameter_max_km * 1000) AS estimated_diameter_max_meters
FROM near_earth_objects
ORDER BY estimated_diameter_max_km DESC
LIMIT 1;


-- 7. FIND MINIMUM AND MAXIMUM RANGES FOR SIZE, VELOCITY, AND DISTANCE
SELECT
    MIN(estimated_diameter_max_km) AS min_diameter,
    MAX(estimated_diameter_max_km) AS max_diameter,
    MIN(relative_velocity_kph) AS min_speed_kph,
    MAX(relative_velocity_kph) AS max_speed_kph,
    MIN(miss_distance_km) AS min_miss_distance_km,
    MAX(miss_distance_km) AS max_miss_distance_km
FROM near_earth_objects;


-- 8. FIND TOP 5 CLOSEST APPROACHES TO EARTH IN LUNAR DISTANCES
SELECT 
    name,
    close_approach_date,
    ROUND(miss_distance_km::numeric, 2) AS miss_distance_km,
    ROUND((miss_distance_km / 384400.0)::numeric, 2) AS lunar_distance_multiple,
    is_potentially_hazardous
FROM near_earth_objects
ORDER BY miss_distance_km ASC
LIMIT 5;


-- 9. ANALYZE HAZARD RATIO AND PERCENTAGES ACROSS SIZE BUCKETS
SELECT 
    CASE 
        WHEN estimated_diameter_max_km < 0.1 THEN '1. Small (<100m)'
        WHEN estimated_diameter_max_km BETWEEN 0.1 AND 0.5 THEN '2. Medium (100m-500m)'
        ELSE '3. Large (>500m)'
    END AS size_bin,
    COUNT(*) AS total_count,
    COUNT(CASE WHEN is_potentially_hazardous THEN 1 END) AS hazardous_count,
    ROUND((COUNT(CASE WHEN is_potentially_hazardous THEN 1 END)::numeric / COUNT(*)) * 100, 2) AS pct_hazardous
FROM near_earth_objects
GROUP BY 1
ORDER BY 1;


-- 10. CALCULATE DAILY AVERAGE SPEED AND MISS DISTANCE TRENDS
SELECT
    close_approach_date,
    ROUND(AVG(relative_velocity_kph)::numeric, 2) AS avg_daily_speed_kph,
    ROUND(AVG(miss_distance_km)::numeric, 2) AS avg_daily_miss_distance_km
FROM near_earth_objects
GROUP BY close_approach_date
ORDER BY close_approach_date ASC;