# Insights — What Actually Makes a Spotify Song Popular?

**Data:** 26,671 real Spotify tracks · 6 genres · 24 subgenres · 10,316 artists · 1957–2020
**Source:** TidyTuesday / Spotify Web API historical export (verified real data, not synthetic)
**Method:** Python (cleaning) → SQL (aggregation) → Excel (live formulas, cross-checked against SQL) → Tableau (visualization)

---

## Headline finding: energy is a trap

The most common assumption about what makes music "work" on a platform like Spotify is
that high-energy tracks perform best. The data says the opposite.

- **Correlation between energy and popularity: -0.105** (weak but real, and negative)
- Splitting tracks into energy quartiles: the **lowest**-energy quartile averages **42.1**
  popularity; the **highest**-energy quartile averages **34.9** — a 7-point gap in the
  "wrong" direction from what intuition suggests
- **EDM has the highest average energy (0.81) of all 6 genres — and the lowest average
  popularity (30.8)**
- **Pop has the highest average popularity (46.2) with only moderate energy (0.698)**

**Why this matters for a product team:** if a recommendation or discovery algorithm were
tuned to surface "high energy" content as a proxy for engaging content, this data suggests
that's the wrong signal — at least for how popularity is actually distributed on this
platform.

## What actually correlates with popularity (ranked)

| Feature | Correlation with popularity |
|---|---|
| duration_min | **-0.139** (strongest signal, negative) |
| instrumentalness | -0.131 |
| energy | -0.105 |
| acousticness | +0.093 |
| liveness | -0.053 |
| danceability | +0.050 |
| loudness | +0.038 |
| valence | +0.030 |
| tempo | +0.005 |
| speechiness | +0.010 |

Every correlation here is weak in absolute terms (none exceed 0.14) — which is itself the
honest finding: **no single audio feature is a strong predictor of popularity on its own.**
Genre and subgenre context matter more than any individual acoustic property (see below).

## Genre performance, ranked

| Genre | Avg Popularity | Track Count |
|---|---|---|
| Pop | 46.2 | 4,934 |
| Rap | 42.2 | 5,139 |
| Latin | 41.9 | 3,956 |
| Rock | 39.5 | 3,633 |
| R&B | 36.3 | 4,199 |
| EDM | 30.8 | 4,810 |

## Songs are getting shorter — a real, verifiable industry trend

| Decade | Avg Duration | Avg Popularity |
|---|---|---|
| 1980s | 4.49 min | 43.0 |
| 1990s | 4.42 min | 38.6 |
| 2000s | 4.12 min | 32.2 |
| 2010s | 3.60 min | 40.5 |
| 2020s* | 3.24 min | 42.8 |

*2020s sample is small (626 tracks) — this dataset's coverage thins out toward its end,
so treat the 2020s row as directional, not definitive.

Average song length dropped by over a minute from the 1980s to the 2020s — a widely
discussed but here independently verified trend, generally attributed to streaming
economics (shorter songs mean more completions and more per-stream payouts relative to
listening time) and playlist/algorithm optimization.

---

## Recommendations

1. **Don't use "high energy" as a proxy for "engaging" in a recommendation system** —
   the data shows a weak negative relationship, not positive. If energy is currently a
   positive-weighted feature anywhere in a ranking model, it's worth re-testing.

2. **Duration is the strongest single predictor available (-0.139)** — shorter tracks
   trend more popular. This aligns with the real, independently-observed decade trend
   of shrinking song lengths. Any product feature nudging toward shorter content
   (already common across the industry) is well-supported by this data.

3. **Treat individual audio features as weak signals — genre/subgenre context carries
   more weight.** No feature here exceeds a 0.14 correlation; a model relying on a single
   acoustic property in isolation will underperform one that incorporates genre.

## Methodology notes (stated openly)

- **Correlation is not causation.** A negative energy-popularity correlation doesn't
  mean lowering energy *causes* higher popularity — genre composition is a likely
  confound (EDM, an inherently high-energy genre, also happens to be the
  lowest-popularity genre in this dataset; the relationship could run through genre
  rather than energy directly). A rigorous next step would be a within-genre
  correlation check before treating this as an actionable lever.
- **Popularity score reflects recency-weighted play counts**, not necessarily quality —
  a well-known limitation of Spotify's own popularity metric, not something introduced
  by this analysis.
- **This dataset's live counterpart is popularity-only**, not audio-features, because
  Spotify deprecated the audio-features API endpoint for new developer apps in November
  2024 (see `api/pull_live_spotify_data.py` for the full explanation). This is disclosed
  rather than worked around.
