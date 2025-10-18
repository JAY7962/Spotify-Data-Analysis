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

-----------------------------------------
-- EDA and Data Cleaning
-----------------------------------------
select *
from spotify;

select max(duration_min), min(duration_min) 
from spotify;

select *
from spotify 
where duration_min=0;

delete from spotify 
where duration_min=0;

select count(distinct artist) ,count(distinct track), count(distinct album) , count(distinct album_type) ,count(distinct channel), count(distinct most_played_on)
from spotify;

select album_type,count(*)
from spotify
group by album_type;

select licensed, count(*)
from spotify
group by licensed;

select most_played_on , count(*)
from spotify 
group by  most_played_on;

select channel, count(*)
from spotify 
group by  channel
order by count(*) desc;

select artist,count(*) 
from spotify 
group by artist;

select artist,album,count(*) 
from spotify 
group by artist,album
order by count(*) desc;

select album,count(distinct artist) 
from spotify 
group by album
order by count(*) desc;

----------------------------------------
-- Data Analysis 
----------------------------------------

select * from spotify

-- Tracks with >= 1B views 
select *
from spotify s
where views >= 1e9
order by views desc;

-- Engagement for Tracks which are licensed.
select track, views, comments, likes
from spotify
where licensed = 'true';

--No of Tracks where almbum_type is single,album,compilation
select (select count(*) from spotify where album_type = 'single') as single, 
(select count(*) from spotify where album_type = 'album') as album,
(select count(*) from spotify where album_type = 'compilation') as compilation;

-- No of Albums by each by each artist
select artist,album,count(*) 
from spotify 
group by artist,album
order by artist asc,count(*) desc;

-- Average song duration for each artist
select artist, round(avg(duration_min)::numeric,2) 
from spotify
group by artist
order by  round(avg(duration_min)::numeric,2) desc;


-- Average danceability of track in each album
select album, count(*) as total_tracks, round(avg(danceability)::numeric,2)
from spotify
group by album
order by round(avg(danceability)::numeric,2) desc;

-- Top 10 tracks based on energy values
select track, energy
from spotify 
order by energy desc
limit 10;

-- Top 10 Popular Artist (views)
select artist, sum(views)
from spotify 
group by artist
order by  sum(views) desc
limit 10;

-- track names which is streamed more on spotify than youtube (case sensitive)
select t.track,t.stream_on_spotify,t.stream_on_youtube from(
select track,
coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as stream_on_spotify,
coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as stream_on_youtube
from spotify
group by track) as t
where t.stream_on_spotify > t.stream_on_youtube
order by t.stream_on_youtube desc;

-- Top 3 Tracks for each artist based on views
select t.artist, t.track as most_popular_track, t.views, t.rnk
from (select artist, track, sum(views) as views, dense_rank() over (partition by artist order by sum(views) desc) as rnk
from spotify
group by artist,track) as t
where t.rnk <=3;

-- Tracks where liveness score > avg
select track,artist,album, liveness
from spotify 
where liveness > (select avg(liveness) from spotify);

-- Energy difference between max and min values of track by an artist
with base as(
select artist, max(energy) as max_energy, min(energy) as min_energy
from spotify
group by artist
)

select *, round((max_energy-min_energy)::numeric,2) as energy_diff
from base;
