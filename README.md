# Spotify-Data-Analysis
This project explores and analyzes a Spotify dataset with over 20,000 tracks using SQL. The goal was to perform data cleaning, exploratory data analysis (EDA), and derive insights into artist performance, song characteristics, and platform trends.

## 🧹 Data Cleaning
- Removed invalid entries (e.g., tracks with `duration_min = 0`).  
- Checked and summarized unique counts for artists, albums, and channels.  
- Standardized data types and handled missing values.

---

## 📊 Data Analysis Performed
- Identified **top artists, albums, and tracks** based on views, likes, and streams.  
- Compared streaming performance between **Spotify** and **YouTube**.  
- Calculated **average energy, danceability, and duration** across artists and albums.  
- Found **tracks with above-average liveness** and computed **energy variations** per artist.  
- Used **aggregate functions, subqueries, CTEs, and window functions** for detailed insights.

---

## 🏆 Key Insights
- Highlighted artists and songs with **1B+ views**.  
- Determined **top 10 most energetic tracks** and **most popular artists**.  
- Discovered patterns in engagement metrics for **licensed vs non-licensed** content.  
- Compared how often tracks were **most played on Spotify vs YouTube**.

---

## 🛠️ Tech Stack
- **SQL** (PostgreSQL / MySQL)  
- **Data Analysis**  
- **Data Cleaning & Aggregation**

---

## 📁 Files
- `spotify.sql` → Contains all SQL queries (table creation, EDA, and analysis)  
- `spotify_dataset.csv` → Raw dataset (20K+ rows) *(optional if included)*  
- `README.md` → Project documentation  

---

## 📈 Results
This project demonstrates how SQL can be used for **data-driven insights** in the music industry, showcasing trends in artist popularity, streaming engagement, and audio characteristics.
