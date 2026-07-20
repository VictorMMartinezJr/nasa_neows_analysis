-- 1. CREATE MAIN REPORTING VIEW WITH PRE-CALCULATED METRICS AND LABELS
CREATE OR REPLACE VIEW vw_tableau_asteroid_summary AS
SELECT 
    asteroid_id,
    name,
    close_approach_date,
    estimated_diameter_max_km,
    ROUND((estimated_diameter_max_km * 1000)::numeric, 2) AS estimated_diameter_max_meters,
    relative_velocity_kph,
    miss_distance_km,
    ROUND((miss_distance_km / 384400.0)::numeric, 2) AS lunar_distances,
    absolute_magnitude_h,
    is_potentially_hazardous,
    CASE 
        WHEN is_potentially_hazardous THEN 'Potentially Hazardous'
        ELSE 'Non-Hazardous'
    END AS hazard_status_label
FROM near_earth_objects;


-- 2. CREATE AGGREGATED DAILY METRICS VIEW FOR TIME-SERIES TREND ANALYSIS
CREATE OR REPLACE VIEW vw_tableau_daily_metrics AS
SELECT 
    close_approach_date,
    COUNT(*) AS total_objects,
    COUNT(CASE WHEN is_potentially_hazardous THEN 1 END) AS hazardous_objects,
    ROUND(
        (COUNT(CASE WHEN is_potentially_hazardous THEN 1 END)::numeric / COUNT(*)) * 100, 
        2
    ) AS pct_hazardous,
    ROUND(AVG(relative_velocity_kph)::numeric, 2) AS avg_speed_kph,
    ROUND(AVG(miss_distance_km)::numeric, 2) AS avg_miss_distance_km
FROM near_earth_objects
GROUP BY close_approach_date
ORDER BY close_approach_date ASC;


-- 3. CREATE SIZE DISTRIBUTION VIEW FOR CATEGORICAL BREAKDOWNS
CREATE OR REPLACE VIEW vw_tableau_size_distribution AS
SELECT 
    asteroid_id,
    name,
    CASE 
        WHEN estimated_diameter_max_km < 0.05 THEN '1. Small (<50m)'
        WHEN estimated_diameter_max_km BETWEEN 0.05 AND 0.14 THEN '2. Medium (50m-140m)'
        ELSE '3. Large (>140m)'
    END AS size_category,
    relative_velocity_kph,
    miss_distance_km,
    is_potentially_hazardous
FROM near_earth_objects;