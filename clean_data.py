"""
clean_data.py -- cleans the raw TidyTuesday/Spotify dataset and engineers
the columns the rest of this project (SQL, Excel, Tableau) depends on.

Source: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv
32,833 real Spotify tracks across 6 playlist genres and dozens of subgenres,
with Spotify's own audio-feature scores (danceability, energy, valence, etc.)
"""
import pandas as pd
import numpy as np

df = pd.read_csv("data/spotify_songs_raw.csv")
before = len(df)
print(f"Loaded {before} rows, {len(df.columns)} columns.")

# --- cleaning (documented) ------------------------------------------------
null_counts = df.isna().sum()
print("\nNull counts per column (before cleaning):")
print(null_counts[null_counts > 0])

# a handful of rows are missing album release date or track name -- drop those,
# they're unusable for the questions this project answers
before_drop = len(df)
df = df.dropna(subset=["track_name", "track_artist", "track_album_release_date"])
print(f"\nDropped {before_drop - len(df)} rows with missing name/artist/release date")

before_dupe = len(df)
df = df.drop_duplicates(subset="track_id")
print(f"Removed {before_dupe - len(df)} duplicate track_ids")

# --- feature engineering ---------------------------------------------------
# release_date comes in mixed granularity (full date, year-month, or just year)
df["release_year"] = pd.to_datetime(df["track_album_release_date"], errors="coerce").dt.year
# rows where only a year was given parse fine; a few oddities become NaT -> drop
before_year = len(df)
df = df.dropna(subset=["release_year"])
df["release_year"] = df["release_year"].astype(int)
print(f"Dropped {before_year - len(df)} rows with unparseable release dates")

# sanity bound: a few rows have corrupted far-future/past years
df = df[(df["release_year"] >= 1957) & (df["release_year"] <= 2020)]

df["decade"] = (df["release_year"] // 10) * 10
df["duration_min"] = (df["duration_ms"] / 60000).round(2)

df["popularity_tier"] = pd.cut(
    df["track_popularity"], bins=[-1, 24, 49, 74, 100],
    labels=["Low (0-24)", "Medium (25-49)", "High (50-74)", "Very High (75-100)"]
)

# de-dupe playlist-level rows down to track level (same track can appear in
# multiple playlists) -- keep the row with the highest popularity value as
# the canonical one per track, since that's the most complete signal
before_track_dedupe = len(df)
df = df.sort_values("track_popularity", ascending=False).drop_duplicates(subset="track_id", keep="first")
print(f"Collapsed playlist-level duplicates: {before_track_dedupe} -> {len(df)} unique tracks")

keep_cols = ["track_id", "track_name", "track_artist", "track_popularity",
             "popularity_tier", "track_album_name", "release_year", "decade",
             "playlist_genre", "playlist_subgenre", "danceability", "energy",
             "key", "loudness", "mode", "speechiness", "acousticness",
             "instrumentalness", "liveness", "valence", "tempo",
             "duration_ms", "duration_min"]
df = df[keep_cols]

df.to_csv("data/spotify_clean.csv", index=False)
print(f"\nWrote data/spotify_clean.csv: {len(df)} rows, {len(df.columns)} columns")
print(f"Genres: {df['playlist_genre'].nunique()}, Subgenres: {df['playlist_subgenre'].nunique()}, "
      f"Artists: {df['track_artist'].nunique()}, Year range: {df['release_year'].min()}-{df['release_year'].max()}")
