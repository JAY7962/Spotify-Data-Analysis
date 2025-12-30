-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

/* =========================================================
   BASIC DATA EXPLORATION
   Purpose: Understand dataset structure and quality
   ========================================================= */

-- View full dataset
SELECT *
FROM spotify;

-- Check maximum and minimum track duration
SELECT
MAX(duration_min) AS max_duration,
MIN(duration_min) AS min_duration
FROM spotify;

-- Identify tracks with zero duration (data quality issue)
SELECT *
FROM spotify
WHERE duration_min = 0;

-- Remove invalid tracks with zero duration
DELETE
FROM spotify
WHERE duration_min = 0;

-- Count distinct entities in the dataset
SELECT
COUNT(DISTINCT artist) AS artists,
COUNT(DISTINCT track) AS tracks,
COUNT(DISTINCT album) AS albums,
COUNT(DISTINCT album_type) AS album_types,
COUNT(DISTINCT channel) AS channels,
COUNT(DISTINCT most_played_on) AS platforms
FROM spotify;


/* =========================================================
DISTRIBUTION ANALYSIS
Purpose: Understand categorical breakdowns
========================================================= */

-- Distribution of album types
SELECT
album_type,
COUNT(*) AS track_count
FROM spotify
GROUP BY album_type;

-- Licensed vs non-licensed tracks
SELECT
licensed,
COUNT(*) AS track_count
FROM spotify
GROUP BY licensed;

-- Platform usage distribution
SELECT
most_played_on,
COUNT(*) AS track_count
FROM spotify
GROUP BY most_played_on;

-- Channel-wise distribution (e.g., official vs user channels)
SELECT
channel,
COUNT(*) AS track_count
FROM spotify
GROUP BY channel
ORDER BY track_count DESC;


/* =========================================================
ARTIST & ALBUM ANALYSIS
Purpose: Identify prolific artists and albums
========================================================= */

-- Number of tracks per artist
SELECT
artist,
COUNT(*) AS total_tracks
FROM spotify
GROUP BY artist;

-- Number of tracks per album by artist
SELECT
artist,
album,
COUNT(*) AS tracks_in_album
FROM spotify
GROUP BY artist, album
ORDER BY artist ASC, tracks_in_album DESC;

-- Albums with multiple contributing artists
SELECT
album,
COUNT(DISTINCT artist) AS artist_count
FROM spotify
GROUP BY album
ORDER BY artist_count DESC;


/* =========================================================
ENGAGEMENT & POPULARITY ANALYSIS
Purpose: Identify high-performing tracks and artists
========================================================= */

-- Tracks with at least 1 billion views
SELECT *
FROM spotify
WHERE views >= 1e9
ORDER BY views DESC;

-- Engagement metrics for licensed tracks
SELECT
track,
views,
comments,
likes
FROM spotify
WHERE licensed = 'true';

-- Count of tracks by album type (single / album / compilation)
SELECT
(SELECT COUNT(*) FROM spotify WHERE album_type = 'single') AS singles,
(SELECT COUNT(*) FROM spotify WHERE album_type = 'album') AS albums,
(SELECT COUNT(*) FROM spotify WHERE album_type = 'compilation') AS compilations;


/* =========================================================
AUDIO FEATURE ANALYSIS
Purpose: Analyze musical characteristics
========================================================= */

-- Average song duration per artist
SELECT
artist,
ROUND(AVG(duration_min)::numeric, 2) AS avg_duration_min
FROM spotify
GROUP BY artist
ORDER BY avg_duration_min DESC;

-- Average danceability per album
SELECT
album,
COUNT(*) AS total_tracks,
ROUND(AVG(danceability)::numeric, 2) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

-- Top 10 tracks by energy level
SELECT
track,
energy
FROM spotify
ORDER BY energy DESC
LIMIT 10;


/* =========================================================
POPULARITY RANKINGS
Purpose: Identify top artists and tracks
========================================================= */

-- Top 10 most popular artists by total views
SELECT
artist,
SUM(views) AS total_views
FROM spotify
GROUP BY artist
ORDER BY total_views DESC
LIMIT 10;

-- Tracks streamed more on Spotify than YouTube
SELECT
t.track,
t.stream_on_spotify,
t.stream_on_youtube
FROM (
SELECT
track,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS stream_on_spotify,
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS stream_on_youtube
FROM spotify
GROUP BY track
) t
WHERE t.stream_on_spotify > t.stream_on_youtube
ORDER BY t.stream_on_spotify DESC;

-- Top 3 tracks per artist based on views
SELECT
artist,
track AS most_popular_track,
views,
rnk
FROM (
SELECT
artist,
track,
SUM(views) AS views,
DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rnk
FROM spotify
GROUP BY artist, track
) t
WHERE rnk <= 3;


/* =========================================================
ADVANCED AUDIO INSIGHTS
Purpose: Identify variability and standout tracks
========================================================= */

-- Tracks with liveness higher than dataset average
SELECT
track,
artist,
album,
liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Energy range (max-min) per artist
WITH base AS (
SELECT
artist,
MAX(energy) AS max_energy,
MIN(energy) AS min_energy
FROM spotify
GROUP BY artist
)
SELECT
*,
ROUND((max_energy - min_energy)::numeric, 2) AS energy_diff
FROM base;


/* =========================================================
FUNNEL ANALYSIS 
Purpose: Model engagement from discovery to retention
========================================================= */

-- Artist-level engagement funnel (Views → Likes → Streams)
SELECT
artist,
SUM(views)  AS total_views,
SUM(likes)  AS total_likes,
SUM(stream) AS total_streams,
ROUND(100.0 * SUM(likes)  / NULLIF(SUM(views), 0)::numeric, 2) AS view_to_like_pct,
ROUND(100.0 * SUM(stream) / NULLIF(SUM(views), 0)::numeric, 2) AS view_to_stream_pct
FROM spotify
GROUP BY artist
ORDER BY total_streams DESC
LIMIT 10;

-- Platform-level funnel comparison
SELECT
most_played_on AS platform,
SUM(views)  AS total_views,
SUM(likes)  AS total_likes,
SUM(stream) AS total_streams,
ROUND(100.0 * SUM(stream) / NULLIF(SUM(views), 0)::numeric, 2) AS view_to_stream_pct
FROM spotify
GROUP BY most_played_on
ORDER BY view_to_stream_pct DESC;

-- Album type conversion analysis
SELECT
album_type,
COUNT(DISTINCT track) AS tracks,
SUM(views)  AS total_views,
SUM(likes)  AS total_likes,
SUM(stream) AS total_streams,
ROUND(100.0 * SUM(stream) / NULLIF(SUM(views), 0)::numeric, 2) AS view_to_stream_pct
FROM spotify
GROUP BY album_type
ORDER BY view_to_stream_pct DESC;
