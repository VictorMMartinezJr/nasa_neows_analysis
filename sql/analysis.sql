-- 1. AGGREGATE SUMMARY METRICS BY HAZARD RISK LEVEL
SELECT 
    is_potentially_hazardous,
    COUNT(*) AS total_asteroids,
    ROUND(AVG(estimated_diameter_max_km)::numeric, 4) AS avg_diameter_km,
    ROUND(AVG(relative_velocity_kph)::numeric, 2) AS avg_speed_kph,
    ROUND(MIN(miss_distance_km)::numeric, 2) AS closest_approach_km
FROM near_earth_objects
GROUP BY is_potentially_hazardous;


-- 2. CATEGORIZE ASTEROIDS BY SIZE TIERS AND ANALYZE AVERAGE VELOCITY
SELECT 
    CASE 
        WHEN estimated_diameter_max_km < 0.05 THEN 'Small (<50m)'
        WHEN estimated_diameter_max_km BETWEEN 0.05 AND 0.14 THEN 'Medium (50m-140m)'
        ELSE 'Large (>140m)'
    END AS size_category,
    COUNT(*) AS asteroid_count,
    ROUND(AVG(relative_velocity_kph)::numeric, 2) AS avg_velocity_kph
FROM near_earth_objects
GROUP BY 1
ORDER BY avg_velocity_kph DESC;


-- 3. RANK AND IDENTIFY THE SINGLE FASTEST ASTEROID PER DAY
WITH ranked_asteroids AS (
    SELECT 
        close_approach_date,
        name,
        relative_velocity_kph,
        miss_distance_km,
        is_potentially_hazardous,
        DENSE_RANK() OVER (
            PARTITION BY close_approach_date 
            ORDER BY relative_velocity_kph DESC
        ) AS speed_rank
    FROM near_earth_objects
)
SELECT 
    close_approach_date AS date,
    name,
    ROUND(relative_velocity_kph::numeric, 2) AS relative_velocity_kph,
    ROUND(miss_distance_km::numeric, 2) AS miss_distance_km,
    is_potentially_hazardous
FROM ranked_asteroids
WHERE speed_rank = 1
ORDER BY close_approach_date;


-- 4. FILTER CLOSE APPROACHES WITHIN 20 LUNAR DISTANCES AND RANK BY PROXIMITY
SELECT 
    name,
    close_approach_date,
    ROUND(miss_distance_km::numeric, 2) AS miss_distance_km,
    ROUND((miss_distance_km / 384400.0)::numeric, 2) AS lunar_distances,
    is_potentially_hazardous
FROM near_earth_objects
WHERE miss_distance_km < (384400.0 * 20) -- WITHIN 20 LUNAR DISTANCES
ORDER BY miss_distance_km ASC;