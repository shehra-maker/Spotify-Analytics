-- analysis_queries.sql
-- Run against sql/spotify.db (built by sql/build_db.py)

-- =========================================================
-- Q1. Which audio features actually correlate with popularity, by genre?
-- =========================================================
SELECT
    playlist_genre,
    COUNT(*)                              AS track_count,
    ROUND(AVG(track_popularity), 1)       AS avg_popularity,
    ROUND(AVG(danceability), 3)           AS avg_danceability,
    ROUND(AVG(energy), 3)                 AS avg_energy,
    ROUND(AVG(valence), 3)                AS avg_valence,
    ROUND(AVG(acousticness), 3)           AS avg_acousticness,
    ROUND(AVG(tempo), 1)                  AS avg_tempo
FROM tracks
GROUP BY playlist_genre
ORDER BY avg_popularity DESC;


-- =========================================================
-- Q2. Popularity by feature quartile (does higher energy actually mean
-- more popular, or is that assumption wrong?)
-- =========================================================
WITH quartiles AS (
    SELECT *, NTILE(4) OVER (ORDER BY energy) AS energy_quartile
    FROM tracks
)
SELECT
    energy_quartile,
    ROUND(MIN(energy), 3) AS energy_floor,
    ROUND(MAX(energy), 3) AS energy_ceiling,
    COUNT(*)                          AS track_count,
    ROUND(AVG(track_popularity), 1)   AS avg_popularity
FROM quartiles
GROUP BY energy_quartile
ORDER BY energy_quartile;


-- =========================================================
-- Q3. How has average song length changed over time?
-- =========================================================
SELECT
    decade,
    COUNT(*)                            AS track_count,
    ROUND(AVG(duration_min), 2)         AS avg_duration_min,
    ROUND(AVG(tempo), 1)                AS avg_tempo,
    ROUND(AVG(track_popularity), 1)     AS avg_popularity
FROM tracks
WHERE decade >= 1980   -- earlier decades have too few tracks to be meaningful here
GROUP BY decade
ORDER BY decade;


-- =========================================================
-- Q4. Which subgenres overperform their parent genre?
-- =========================================================
WITH genre_avg AS (
    SELECT playlist_genre, AVG(track_popularity) AS genre_avg_pop
    FROM tracks GROUP BY playlist_genre
)
SELECT
    t.playlist_genre,
    t.playlist_subgenre,
    COUNT(*)                                          AS track_count,
    ROUND(AVG(t.track_popularity), 1)                 AS subgenre_avg_pop,
    ROUND(AVG(t.track_popularity) - g.genre_avg_pop,1) AS pop_vs_genre_avg
FROM tracks t
JOIN genre_avg g ON t.playlist_genre = g.playlist_genre
GROUP BY t.playlist_genre, t.playlist_subgenre
HAVING COUNT(*) >= 30
ORDER BY pop_vs_genre_avg DESC
LIMIT 15;


-- =========================================================
-- Q5. Top artists by track count and average popularity (min 5 tracks,
-- to avoid one-hit-wonders skewing an "average")
-- =========================================================
SELECT
    track_artist,
    COUNT(*)                            AS track_count,
    ROUND(AVG(track_popularity), 1)     AS avg_popularity,
    MAX(track_popularity)               AS best_track_popularity
FROM tracks
GROUP BY track_artist
HAVING COUNT(*) >= 5
ORDER BY avg_popularity DESC
LIMIT 20;


-- =========================================================
-- Q6. What does the "sweet spot" of a hit actually look like?
-- (Very High popularity tier vs Low popularity tier, feature by feature)
-- =========================================================
SELECT
    popularity_tier,
    COUNT(*)                    AS track_count,
    ROUND(AVG(danceability),3)  AS avg_danceability,
    ROUND(AVG(energy),3)        AS avg_energy,
    ROUND(AVG(valence),3)       AS avg_valence,
    ROUND(AVG(loudness),2)      AS avg_loudness,
    ROUND(AVG(speechiness),3)   AS avg_speechiness,
    ROUND(AVG(acousticness),3)  AS avg_acousticness,
    ROUND(AVG(tempo),1)         AS avg_tempo,
    ROUND(AVG(duration_min),2)  AS avg_duration_min
FROM tracks
GROUP BY popularity_tier
ORDER BY
    CASE popularity_tier
        WHEN 'Very High (75-100)' THEN 1
        WHEN 'High (50-74)' THEN 2
        WHEN 'Medium (25-49)' THEN 3
        ELSE 4
    END;
