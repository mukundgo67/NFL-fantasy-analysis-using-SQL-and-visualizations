-- Q11: Boom/bust index for WRs
-- Tier 3 (context story)
-- Reads from: dbo.vw_player_game
-- Fantasy scoring: DraftKings, off_dkp
--
-- Question: which WRs had the most volatile week-to-week fantasy scoring?
--
-- Definitions:
--   points_deviation   = STDEV(off_dkp) over the WR's games in the season
--                        (sample standard deviation: how far his weekly
--                        scores typically sit from his own average)
--   boom_or_bust_index = points_deviation / avg_off_dkp
--                        (coefficient of variation: swings relative to his
--                        normal week)
--   boom_game          = a game with off_dkp >= 20
--   bust_game          = a game with off_dkp < 5
--   [Add the check behind the 20 and 5 thresholds, e.g. how many WR rows
--    fall at or above 20 and below 5.]
--	 games_btw_boom_bust = games_played - (boom_game + bust_game)
--                        (games with off_dkp from 5 up to, but not including,
--                        20; the boom and bust ranges don't overlap, so no
--                        game is counted twice. A score of exactly 5.00 counts
--                        as in-between and exactly 20.00 counts as a boom.)
--
-- Notes:
--  * Qualifying WR-seasons: position_group = 'WR', at least 50 targets in
--    the season and at least 8 games. Both filters are in the HAVING because
--    they are season totals. [Add how many WR-seasons qualify.]
--  * Grouped by season and player_id, so each row is one WR in one season.
--    Seasons are not pooled (a role can change from year to year), and a WR
--    traded mid-season is one row, not two partial ones.
--  * The index divides by the average because raw SD favors high scorers: a
--    WR averaging 16 points will have a bigger SD than one averaging 5 even
--    if he is steadier relative to his average. A very low average can still
--    inflate the ratio. [Add the lowest avg_off_dkp among the top 10, and say
--    if a minimum average was needed.]
--  * Ranking is within each season (PARTITION BY season), highest index =
--    rank 1. RANK shares a position between tied WRs, and ties on the index
--    are broken by points_deviation. The rank uses the unrounded index; the
--    rounding (DECIMAL(5,2)) happens only in the final SELECT, so rounding
--    can't create false ties.
--  * Top 10 per season only. Reversing the ORDER BY would give the most
--    consistent WRs instead.
--  * Each SD comes from only 8 to 17 games, so it has noise of its own. As a
--    rough guide an SD can be off by about 18% at 16 games and about 24% at
--    10 games. A gap of a few percent between two WRs' indexes is not
--    meaningful; only large gaps are worth reporting.
--  * Games = rows (appearances). All rows count, including games a WR left
--    early, so some busts may reflect injuries and not bad performances. No
--    snap-share filter is applied. [Confirm or edit.]
--  * Playoff games are included.
--  * Sanity checks: one WR-season's weekly off_dkp checked against STDEV.S in
--    a spreadsheet. [Add the result here.]
USE NFL_offensive_fantasy_analysis
GO

WITH stats_metrics AS (
SELECT 
season,
player_id,
player,
COUNT(game_id) as games_played,
SUM(targets) AS total_targets,
AVG(off_dkp) AS avg_off_dkp,
STDEV(off_dkp) AS points_deviation,
SUM(CASE WHEN off_dkp >= 20 THEN 1 ELSE 0 END) AS boom_game,
SUM(CASE WHEN off_dkp <  5  THEN 1 ELSE 0 END) AS bust_game
FROM dbo.vw_player_game
WHERE position_group = 'WR'
GROUP BY season,player_id,player
HAVING COUNT(game_id) >= 8 and SUM(targets) >= 50
),

further_agg AS (
SELECT 
season,
player_id, 
player,
games_played,
total_targets,
points_deviation,
boom_game,bust_game,
CAST(avg_off_dkp AS DECIMAL(5,2)) AS avg_off_dkp,
points_deviation / NULLIF(avg_off_dkp,0) AS boom_or_bust_index,
RANK() OVER (PARTITION BY season ORDER BY points_deviation /NULLIF(avg_off_dkp,0) DESC, points_deviation DESC) AS volatility_rank
FROM stats_metrics
)

SELECT 
season,
volatility_rank,
CAST(boom_or_bust_index AS DECIMAL(5,2)) AS boom_or_bust_index,
player,
games_played,
total_targets,
avg_off_dkp,
CAST(points_deviation AS DECIMAL(5,2)) AS points_deviation,
boom_game,
bust_game,
(games_played-(boom_game+bust_game)) AS games_btw_boom_bust
FROM further_agg
WHERE volatility_rank <= 10
ORDER BY season, volatility_rank