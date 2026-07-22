# NASA Near Earth Objects Analysis: Python + SQL + Tableau 

## Project Overview
<img width="1920" height="1080" alt="Image" src="https://github.com/user-attachments/assets/8cc8739b-c3d1-43ba-85b1-de2439912c91" />

This project is an end-to-end data engineering and analytics solution designed to extract critical insights from NASA’s Near Earth Objects (NEO) dataset. Utilizing Python for data extraction, cleaning, and database loading, PostgreSQL for advanced analytical querying and view creation, and an interactive Tableau dashboard to visualize proximity rankings, hazard ratios, and approach timelines.
---
## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, SQL (PostgreSQL)
   - **Goal**: Create a structured workspace and organize project folders (data/, sql/, notebooks/, tableau/) for streamlined development.

### 2. Set Up NASA API
   - **API Setup**: Obtain API credentials or access the raw NASA NEO dataset.
   - **Configure API**: Set up local environment variables (.env) to securely fetch dataset files directly into your workspace.

### 3. Fetch Near Earth Objects Data
   - **Data Source**: Extract asteroid trajectory, velocity, diameter, and hazard classifications.
   - **Storage**: Save raw datasets in the data/ folder for local staging and data integrity checks.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas numpy sqlalchemy psycopg2 python-dotenv
     ```
   - **Loading Data**: Load raw data into a Pandas DataFrame for initial analysis and automated transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial Exploratory Data Analysis (EDA) to understand distribution, schema types, missing fields, and potential anomalies.
   - **Analysis**: Utilize .info(), .describe(), and .head() alongside SQL auditing queries to evaluate row counts, distinct IDs, and NULL distributions.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and deduplicate entries based on unique asteroid_id values.
   - **Handle Missing Values**: Audit missing velocity or miss-distance values to ensure complete trajectory reporting.
   - **Fix Data Types**: Ensure strict type alignment (e.g. diameters as FLOAT, is_potentially_hazardous as BOOLEAN).
   - **Unit Conversion**: Standardize measurements across kilometers, meters, and lunar distance multiples.
   - **Validation**: Verify cleaned data before database deployment.

### 7. Feature Engineering
   - **Create Calculated Fields**: Compute estimated_diameter_max_meters and calculate lunar_distances (miss_distance_km/384,400).
   - **Categorical Binning**: Bin objects into size tiers (Small (<50m), Medium (50m-140m), Large (>140m)).
   - **Enhance Dataset**: Add descriptive hazard status labels to simplify SQL aggregation and downstream visualization.

### 8. Load Data into PostgreSQL
   - **Set Up Connections**: Establish a connection to PostgreSQL using sqlalchemy and psycopg2.
   - **Automated Pipeline**: Dump processed DataFrames directly into the near_earth_objects database table using .to_sql().
   - **Verification**: Run validation queries in SQL to verify record counts and primary key integrity.

### 9. SQL Analysis: Complex Queries, Database Views & Problem Solving
   - **Analytical Queries**: Execute SQL scripts to solve critical astronomical questions::
     - Hazard risk distributions and metric summaries.
     - Daily speed and proximity trends.
     - Identifying the single fastest object per approach window.
     - Sizing vs. velocity correlations.
   - **Database Views**: Build reporting views (vw_tableau_asteroid_summary, vw_tableau_daily_metrics, vw_tableau_size_distribution) to directly feed Tableau dashboards.
     
---

## Requirements

- **Python 3.8+**
- **SQL Databases**: PostgreSQL
- **Visualization Tool**: Tableau Desktop / Tableau Public
- **Python Libraries**:
  - `pandas`, `python-dotenv`, `sqlalchemy`, `psycopg2`
- **Kaggle API Key** (for data downloading)
<img width="640" height="306" alt="Image" src="https://github.com/user-attachments/assets/11ae73d8-5f38-4e6d-82d9-b540acf32a53" />

## Getting Started

1. Clone the repository:
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up PostgreSQL Database & Pipeline:
   - Execute Jupyter Notebooks in notebooks/ to clean and load data into PostgreSQL.
   - Run SQL files in sql/ to execute analysis and build database views.
4. View Dashboard:
   - Open .twbx files or view the live interactive dashboard on Tableau Public.

---

## Project Structure

```plaintext
|-- data/                     # data csv file
|-- sql/                      # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- tableau/                  # Tableau assets
|-- README.md                 # Project documentation
```
---
Business & Astronomical Analysis (SQL)
1. Audit Data Integrity and Check for Missing Values
```SQL
SELECT 
    COUNT(*) AS total_rows,
    COUNT(asteroid_id) AS total_ids,
    COUNT(name) AS total_names,
    COUNT(close_approach_date) AS total_dates,
    COUNT(*) - COUNT(relative_velocity_kph) AS missing_velocities,
    COUNT(*) - COUNT(miss_distance_km) AS missing_distances
FROM near_earth_objects;
```
2. Hazardous vs. Non-Hazardous Object Distribution
```SQL
SELECT
    COUNT(CASE WHEN is_potentially_hazardous = true THEN 1 END) AS num_of_hazardous_objects,
    COUNT(CASE WHEN is_potentially_hazardous = false THEN 1 END) AS num_of_non_hazardous_objects
FROM near_earth_objects;
```
3. Top 5 Closest Approaches to Earth (in Lunar Distance Multiples)
```SQL
SELECT 
    name,
    close_approach_date,
    ROUND(miss_distance_km::numeric, 2) AS miss_distance_km,
    ROUND((miss_distance_km / 384400.0)::numeric, 2) AS lunar_distance_multiple,
    is_potentially_hazardous
FROM near_earth_objects
ORDER BY miss_distance_km ASC
LIMIT 5;
```
4. Hazard Ratio and Percentages Across Size Buckets
```SQL
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
```
5. Aggregate Summary Metrics by Hazard Risk Level
```SQL
SELECT 
    is_potentially_hazardous,
    COUNT(*) AS total_asteroids,
    ROUND(AVG(estimated_diameter_max_km)::numeric, 4) AS avg_diameter_km,
    ROUND(AVG(relative_velocity_kph)::numeric, 2) AS avg_speed_kph,
    ROUND(MIN(miss_distance_km)::numeric, 2) AS closest_approach_km
FROM near_earth_objects
GROUP BY is_potentially_hazardous;
```
7. Categorize Asteroids by Size Tiers and Analyze Velocity
```SQL
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
```
8. Rank and Identify the Single Fastest Asteroid per Day
```SQL
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
```
9. Filter Close Approaches Within 20 Lunar Distances
```SQL
SELECT 
    name,
    close_approach_date,
    ROUND(miss_distance_km::numeric, 2) AS miss_distance_km,
    ROUND((miss_distance_km / 384400.0)::numeric, 2) AS lunar_distances,
    is_potentially_hazardous
FROM near_earth_objects
WHERE miss_distance_km < (384400.0 * 20)
ORDER BY miss_distance_km ASC;
```
Reporting Database Views
Main Reporting View (Tableau Source)
```SQL
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
```
🔗 **[View Interactive Dashboard on Tableau Public](https://public.tableau.com/views/NASANeo/NEODashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**
<img width="1410" height="735" alt="Image" src="https://github.com/user-attachments/assets/f4a4374c-1636-4181-8462-94e186cf8eeb" />
<img width="1434" height="1050" alt="Image" src="https://github.com/user-attachments/assets/65086bf5-bfb5-4243-99c9-b3e6a386cae5" />

Key features of the interactive dashboard include:
- **KPI Summary Cards**: Total tracked asteroids, average relative velocity, and minimum miss distance.
- **Diameter vs. Velocity Scatter Plot**: Highlights trajectory speeds relative to asteroid mass and hazard flags.
- **Proximity Ranking Bar Chart**: Highlights trajectories measured in exact Lunar Distance (LD) multiples.
- **Approach Timeline Histogram**: Tracks daily object traffic across time.
- **Collapsible Filter Menu**: Seamlessly toggles hazardous object subsets without cluttering visual space.
### Future Enhancements
- **Real-Time API Pipeline**: Automate daily extraction using Airflow or GitHub Actions directly from NASA's NeoWS REST API.
- **Predictive Trajectory Modeling**: Implement machine learning models (Scikit-Learn) to classify hazardous objects based on orbital mechanics.
- **Automated Alerts**: Integrate Slack/Email notifications for near-miss objects approaching within 5 LD.
### Acknowledgments
- **Data Source**: NASA’s Near Earth Object Web Service (NeoWS)
- **Inspiration**: Jet Propulsion Laboratory (JPL) Center for Near-Earth Object Studies (CNEOS)
