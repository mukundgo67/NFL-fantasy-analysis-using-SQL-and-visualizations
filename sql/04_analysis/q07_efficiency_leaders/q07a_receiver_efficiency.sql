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