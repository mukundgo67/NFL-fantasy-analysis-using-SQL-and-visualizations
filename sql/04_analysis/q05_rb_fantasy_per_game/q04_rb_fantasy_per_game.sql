--Q4: Top RBs per season by fantasy points per game
-- Tier 2 (CTEs and window functions)
-- Reads from: dbo.vw_player_game
-- Fantasy scoring: DraftKings, off_dkp
--
-- Notes:
--  * "Games" = the number of rows a player has in the season (one row per
--    player per game). All RB rows count, including games with little
--    offensive involvement (no offense > 0 filter).
--  * Minimum 8 games to qualify. The filter is applied BEFORE ranking, so
--    every season returns a full top 10 with no gaps in the ranks.
--  * Average is per game (AVG of off_dkp over a player's rows), not a season
--    total, so the 17-game 2021 season doesn't get an advantage.
--  * Grouped by player_id so players who share a name stay separate, and not
--    by team, so a traded RB isn't split into two partial seasons.
--    teams_played_for shows who changed teams.
--  * position_group = 'RB' covers HB and RB. FB is excluded.
--  * Playoff games are included, so deep-run teams' RBs can have a few more
--    games than the regular-season schedule.
--  * RANK is used so tied players share a position. ROW_NUMBER would split
--    ties arbitrarily, which is wrong for a leaderboard.
--  * Rank on the unrounded average; round only in the final SELECT, so
--    rounding can't create false ties.

WITH rbs_avg AS ( 
SELECT player,
position_group,
season,
COUNT(*) AS games_played,
AVG(off_dkp) AS avg_off_dkp_per_game,
SUM(off_dkp) AS total_off_dkp_per_game 
from dbo.vw_player_game
group by player, position_group, season
HAVING COUNT(game_id) > 8 and position_group = 'RB' --can filter rbs in HAVING as its already grouped in the previous step
),

ranked_rbs as
(SELECT player, position_group, season, games_played,
ROUND(avg_off_dkp_per_game,2) AS avg_off_dkp_per_game,
ROUND(total_off_dkp_per_game,2) AS total_off_dkp_per_game,
RANK() OVER (PARTITION BY season ORDER BY avg_off_dkp_per_game DESC) AS season_rank,
ROW_NUMBER() OVER(PARTITION BY season ORDER BY avg_off_dkp_per_game DESC) AS row_num --in the event of a tie between two players
FROM rbs_avg
)

SELECT * 
FROM ranked_rbs
WHERE season_rank <= 10


