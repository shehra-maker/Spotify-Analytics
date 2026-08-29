# Spotify Popularity Analysis

**Live dashboard:** https://shehra-maker.github.io/Spotify-Analytics/
**Full findings:** [INSIGHTS.md](INSIGHTS.md)
**Written narrative:** published separately on Medium (link added once live)

A product analytics project on 26,671 real Spotify tracks (1957-2020), testing whether
high-energy songs actually perform better on Spotify. They don't. Built with Python, SQL,
Excel, Tableau, and a live pull from the Spotify Web API.

## The headline finding

Energy correlates negatively with popularity (-0.105), not positively. EDM has the
highest average energy of any genre in this dataset and the lowest average popularity.
Duration turns out to be the strongest single predictor (-0.139), ahead of energy.
Full breakdown in [INSIGHTS.md](INSIGHTS.md).

## Tableau

![Tableau dashboard screenshot](tableau_dashboard_screenshot.png)

Built in Tableau Desktop: genre performance, the energy/popularity relationship, feature
correlations, and song length trends over time.

## About the data

Source: the real, well-known [TidyTuesday Spotify dataset](https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-01-21)
(originally Spotify's own audio-feature data, 32,833 tracks across 6 playlist genres and
24 subgenres). This is genuine historical data, not synthetic.

A live component pulls current popularity data from Spotify's real API
(`api/pull_live_spotify_data.py`). Spotify permanently deprecated the audio-features
endpoint for new developer apps in November 2024, so the live pull gets popularity and
track metadata but not live audio features. That limitation is documented in the script
itself rather than worked around.

## What's in each folder

```
docs/     the live dashboard (index.html + data.json)
data/     clean_data.py, spotify_clean.csv, tableau_export.csv
sql/      schema.sql, build_db.py, analysis_queries.sql, query_results.json
excel/    build_excel.py, spotify_analysis.xlsx
api/      pull_live_spotify_data.py
INSIGHTS.md    full findings and recommendations
```

## SQL (sql/analysis_queries.sql)

Six queries: genre-level feature averages, an energy-quartile popularity breakdown (the
query behind the headline finding), song length by decade, subgenre overperformance
against parent genre (window function and CTE), top artists (minimum 5 tracks, so one
hit can't skew an average), and a comparison of audio profiles across popularity tiers.

## Excel (excel/spotify_analysis.xlsx)

Four tabs, every summary number computed with live formulas (AVERAGEIF, COUNTIF, CORREL,
QUARTILE) referencing the raw data directly, not pasted-in values. Cross-checked against
the SQL layer independently; both produced identical numbers.

## Tools

Python (pandas) · SQL (SQLite) · Excel (openpyxl, live formulas) · Tableau ·
Spotify Web API (Client Credentials flow) · Chart.js
