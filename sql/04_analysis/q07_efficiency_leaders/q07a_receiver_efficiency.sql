-- Q7a: Receiver efficiency leaders (catch rate, drop rate, YAC per reception)
-- Tier 2 (CTEs and window functions)
-- Reads from: dbo.vw_player_game
--
-- Metrics (all computed from SEASON TOTALS, not averaged per-game ratios,
-- so a 12-target game counts for more than a 2-target game):
--   catch_rate  = receptions / targets, as a percentage
--   drop_rate   = drops / targets, as a percentage (LOWER is better)
--   yac_per_rec = yards after catch / receptions
--
-- Notes:
--  * Only WR, TE and RB are included. FB, QB and Other are excluded.
--  * Minimum 41 targets in the season to qualify (WHERE total_targets > 40).
--    The filter is applied BEFORE ranking, so small samples (3 targets,
--    3 catches = 100%) can't take a leaderboard spot.
--  * Rankings are within season AND position group. RBs catch shorter passes
--    and would dominate a combined list, so each position is ranked against
--    its own group.
--  * Ranks use the unrounded rates. Rounding (DECIMAL(5,2)) happens only in
--    the final SELECT, so rounding can't create false ties.
--  * Ties: catch rate and drop rate ties are broken by total targets (more
--    targets ranks higher, since the same rate on a bigger sample is more
--    convincing). YAC ties are not broken. RANK is used, so tied players
--    share a position and a season can return more than 10 rows.
--  * Drop rate is ranked ascending: the lowest rate is rank 1. Many players
--    have zero or near-zero drops, so the targets tiebreak matters most here.
--  * A player appears if he is a top-10 leader in at least one metric. His
--    other two ranks are still shown, even when they are poor.
--  * YAC divides by receptions, not targets. The 41-target minimum does not
--    guarantee many catches, so YAC for low-reception players is noisy.
--  * Grouped by player_id, so players who share a name stay separate. Grouped
--    by position_group too, so a player whose position label changes during a
--    season could be split into two partial rows. [Add the result of the
--    position-label check here.]
--  * rec_drops and rec_yac come from the advanced stats columns, which the
--    fact table stores as NOT NULL, so missing source data would show as 0.
--    [Add the result of the completeness check here.]
--  * Division uses 100.0 or 1.0 to avoid integer division (these columns are
--    SMALLINT), and NULLIF guards against a zero denominator.
--  * Playoff games are included.

use NFL_offensive_fantasy_analysis;
go

WITH total_stats AS (
SELECT 
season,
player_id, 
player,
position_group,
SUM(rec) AS total_receptions,
SUM(targets) AS total_targets,
SUM(rec_drops) AS total_drops,
SUM(rec_yac) AS total_rec_yac
FROM dbo.vw_player_game
WHERE position_group IN ('WR','RB','TE') --to eliminate position groups with minimum recepetions to slip in and skew the analysis
GROUP BY season,player,player_id,position_group
),

catch_rate_calc AS ( 
SELECT
*,
CAST(100.0 * total_receptions/NULLIF(total_targets,0) AS decimal(5,2)) AS catch_rate,
100.0 * total_drops/NULLIF(total_targets, 0) AS drop_rate,
1.0   * total_rec_yac/ NULLIF(total_receptions, 0) AS yac_per_rec
FROM total_stats
WHERE total_targets > 40 --minimum targets to qualify
),

rnk_catchers AS(
SELECT 
season,
RANK() OVER (PARTITION BY season, position_group ORDER BY catch_rate DESC, total_targets DESC) AS ranked_catchers,--total_targets rank is used as a tie break
RANK() OVER (PARTITION BY season, position_group ORDER BY drop_rate ASC,  total_targets DESC) AS drop_rank,   -- lower is better
RANK() OVER (PARTITION BY season, position_group ORDER BY yac_per_rec DESC) AS yac_rank,
player,
position_group,
catch_rate,
total_targets,
total_receptions,
total_drops
FROM catch_rate_calc
)

SELECT
season, 
position_group,
player,
total_targets,
total_receptions,
CAST(catch_rate AS decimal(5,2)) AS catch_rate, ranked_catchers,
CAST(drop_rank AS decimal(5,2)) AS drop_rate,drop_rank,
CAST(yac_rank AS decimal(5,2)) AS yac_per_rec,yac_rank
FROM rnk_catchers
WHERE ranked_catchers <= 10 OR drop_rank <= 10 OR yac_rank <= 10   -- leader in any metric
ORDER BY season, position_group, ranked_catchers;
