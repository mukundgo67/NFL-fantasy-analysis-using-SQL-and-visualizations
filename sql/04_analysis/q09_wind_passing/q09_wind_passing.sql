-- Q9: Wind and passing efficiency
-- Tier 3 (context story)
-- Reads from: dbo.vw_player_game
--
-- Question: does yards per pass attempt fall once the wind reaches about
-- 15 mph?
--
-- Wind buckets (mph, whole-number readings):
--   0-4 | 5-9 | 10-14 | 15+
--   The 15+ bucket includes 15 itself (wind_speed < 15 is the top of the
--   10-14 bucket).
--
-- Notes:
--  * Outdoor games only (roof = 'outdoors'). vw_player_game sets weather to
--    NULL for every other roof type, including open-roof retractable games,
--    so those games drop out of this question. The result describes outdoor
--    stadiums only.
--  * Games with a NULL wind_speed are excluded in the first CTE, so missing
--    data can't fall into the 15+ bucket (a NULL fails every WHEN and would
--    land in the ELSE). [Add the number of outdoor games with no wind reading.]
--  * One row per GAME, not per team-game. Wind is a game-level condition that
--    both offenses face, so both teams' passing is summed into one row. This
--    also avoids counting two correlated rows from the same game as separate
--    samples (the issue noted in Q8).
--  * No position filter: pass_att and pass_yds are summed over all rows, so a
--    trick pass by a receiver isn't dropped.
--  * Yards per attempt is gross: SUM(pass_yds) / SUM(pass_att). Sacks are not
--    included as attempts and sack yards are not subtracted.
--  * Two versions of yards per attempt are shown:
--      pooled_ypa   = total yards / total attempts in the bucket
--                     (games with more passes weigh more)
--      avg_game_ypa = average of each game's own rate
--                     (every game weighs the same)
--    se_of_avg = STDEV / SQRT(n) for the game-level average. To compare two
--    buckets, the noise on the gap is SQRT(se1^2 + se2^2), and a gap smaller
--    than about twice that is hard to tell apart from chance.
--  * Game rates stay unrounded until the final SELECT. Rounding each game's
--    rate before averaging would add a small error.
--  * Division uses 1.0 or 100.0 to avoid integer division (the sums are
--    integers), and NULLIF guards against a zero denominator.
--  * Efficiency is not the only thing wind could change, so each bucket also
--    shows completion % and pass attempts per game .
--    If yards per attempt barely moves but attempts drop, the effect is in
--    play-calling and not in the passing game itself.
--  * avg_temp is shown because wind and cold tend to come together, and late
--    season games are colder. If the windiest bucket is also much colder, wind
--    alone can't be credited with any drop.
--  * Wind isn't isolated from venue: some outdoor stadiums are windier than
--    others, so a few teams may drive the windy bucket. Surface and team
--    quality are not controlled for. This is an association, not a cause.
--  * Seasons are pooled. Playoff games are included.
--  * [wind_bucket 0-4 mph= 140 games, 5-9 mph= 216 games, 10-14 = games, 15+ mph = 77]

USE NFL_offensive_fantasy_analysis
GO

WITH agg_stats AS(
SELECT 
DISTINCT(game_id),
game_date,
SUM(pass_att) AS total_pass_att, -- computes total_pass_att on a per game basis
SUM(pass_cmp) AS total_completions, -- computes total_completions on a per game basis
SUM(pass_yds) AS total_pass_yds, -- computes total_pass_yds on a per game basis
roof,
wind_speed,
temperature
FROM dbo.vw_player_game
WHERE roof= 'outdoors' and wind_speed IS NOT NULL
GROUP BY game_id,game_date,roof,wind_speed,temperature
),

placehold AS(
SELECT *,
CASE 
WHEN wind_speed < 5 THEN '0-4 mph'
WHEN wind_speed < 10 THEN '5-9 mph'
WHEN wind_speed < 15 THEN '10-14 mph'
ELSE '15+ mph'
END AS wind_bucket,
CAST(1.0 * total_pass_yds / NULLIF(total_pass_att,0) AS DECIMAL(5,2)) AS ypa
FROM agg_stats
)

SELECT 
wind_bucket,
COUNT(*) AS number_of_games,
CAST((1.0 * SUM(total_pass_yds) / NULLIF(SUM(total_pass_att),0)) AS DECIMAL(5,2)) AS pooled_ypa,
CAST(AVG(ypa) AS DECIMAL(5,2)) AS avg_ypa,
CAST(STDEV(ypa) / SQRT(COUNT(*)) AS decimal(5,2)) AS se_of_avg,
CAST(100.0 * SUM(total_completions) / NULLIF(SUM(total_pass_att), 0) AS decimal(5,2)) AS completion_pct,
CAST(AVG(1.0 * total_pass_att) AS decimal(5,1)) AS avg_pass_att_per_game,
CAST(AVG(1.0 * temperature) AS decimal(5,1)) AS avg_temp
FROM placehold
GROUP BY wind_bucket
ORDER BY MIN(wind_speed)


