-- Q10: Does the over/under hold up?
-- Tier 3 (context story)
-- Reads from: dbo.vw_game (one row per game)
--
-- Question: how close is the Vegas over/under to actual total points, how
-- often does the over hit, and does that change by season, roof or surface?
--
-- Definitions:
--   line_error = total_points - over_under (positive = the game went over)
--   avg_error = average line_error. Measures BIAS: over- and under-misses
--                 cancel out.
--   mean_abs_error = average of ABS(line_error). Measures how far off a typical
--                 line is, whichever direction.
--   over_rate_pct = overs / (overs + unders), as a percentage. Pushes are
--                 excluded from the rate and reported in their own column.
--
-- Notes:
--  * Games with a NULL over_under are excluded in the first CTE. All 820
--    games had a line, so none were dropped.
--  * line_error is computed per game BEFORE averaging. Subtracting season
--    totals (SUM of points minus SUM of lines) gives the season's total error,
--    not a per-game margin, and SUM skips NULLs in each column separately.
--  * se_of_avg_error = STDEV(line_error) / SQRT(n). An average error smaller
--    than about twice this is hard to tell apart from zero.
--  * hit_rate_noise_pts = 100 * SQRT(0.25 / n): the rough noise, in
--    percentage points, around a 50% over rate. An over rate within about
--    twice this of 50% can't be separated from a coin flip. It grows quickly
--    as the group gets smaller.
--  * Mean error and over rate can disagree: an average is pulled by the size
--    of the misses, while a hit rate only counts direction. Both are shown.
--  * The three splits (season, roof, surface) come from one CROSS APPLY
--    (VALUES ...). Each game is counted once PER SPLIT, so the same game
--    appears in a season row, a roof row and a surface row. Do not add games
--    across splits; the games column should add up to 820 WITHIN each split.
--    season is cast to text so all three group columns share one data type.
--  * The roof and surface splits pool all three seasons. Roof labels are kept
--    as they appear in the source (retractable open and closed stay separate).
--    The open-roof retractable group has only 16 games, so its rates are very
--    noisy.
--  * Surface and roof overlap (domes tend to have turf), so a roof difference
--    and a surface difference are not independent effects.
--    [Add the surface values found and any rule used to collapse them into
--    grass and turf.]
--  * Playoff games are included. 2020 had mostly empty stadiums and a higher
--    scoring environment (49.49 average total points, against 45.68 in 2019
--    and 46.07 in 2021).
--  * The data doesn't say whether Over_Under is an opening or closing line,
--    and it has no odds. At standard -110 pricing the break-even over rate is
--    about 52.4%, but that is background only; nothing here measures betting
--    returns.
--  * Sanity checks: overs + unders + pushes = games in every row, and games
--    adds up to 820 within each split. The season rows should match the
--    earlier season-only query (2019: 266 games, 2020: 269, 2021: 285).
USE NFL_offensive_fantasy_analysis
GO

WITH stats_comp AS(
SELECT 
CAST(season AS VARCHAR(10)) AS season,
roof,
surface,
over_under,
total_points,
ou_result,
(total_points - over_under) AS line_error
FROM dbo.vw_game
)

SELECT
d.split_by, 
d.group_name,
COUNT(*) AS games,
CAST(AVG(1.0 * total_points) AS decimal(5,2)) AS avg_total_points,
CAST(AVG(over_under) AS decimal(5,2)) AS avg_line,
CAST(AVG(line_error) AS decimal(5,2)) AS avg_error,
CAST(STDEV(line_error) / SQRT(COUNT(*)) AS decimal(5,2)) AS se_of_avg_error,
CAST(AVG(ABS(line_error)) AS decimal(5,2)) AS mean_abs_error,
SUM(CASE WHEN ou_result = 'Over'  THEN 1 ELSE 0 END) AS overs,
SUM(CASE WHEN ou_result = 'Under' THEN 1 ELSE 0 END) AS unders,
SUM(CASE WHEN ou_result = 'Push'  THEN 1 ELSE 0 END) AS pushes,
CAST(100.0 * SUM(CASE WHEN ou_result = 'Over' THEN 1 ELSE 0 END)/ NULLIF(SUM(CASE WHEN ou_result IN ('Over','Under') THEN 1 ELSE 0 END), 0) AS decimal(5,2)) AS over_rate_pct,
CAST(100 * SQRT(0.25 / COUNT(*)) AS decimal(5,2)) AS hit_rate_noise_pts
FROM stats_comp g
CROSS APPLY (VALUES
('season',  g.season),
('roof',    g.roof),
('surface', g.surface)) 
AS d(split_by, group_name)
GROUP BY d.split_by, d.group_name
ORDER BY d.split_by, d.group_name;
