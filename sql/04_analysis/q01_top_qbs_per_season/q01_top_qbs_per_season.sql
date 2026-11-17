use NFL_offensive_fantasy_analysis
go

with qb_season AS (
SELECT
season,
player_id,
player,
position_group,
team,
sum(pass_yds) AS total_pass_yards,
sum(pass_td) AS total_pass_tds, 
sum(pass_int) as total_ints
FROM dbo.vw_player_game
WHERE position_group ='QB'
GROUP BY player_id, player, position_group, team,season
),

ranked AS(
SELECT *,
RANK() OVER 
(PARTITION BY season
ORDER BY total_pass_yards DESC, total_pass_tds DESC) AS rnk
FROM qb_season
)

SELECT season, rnk, player, total_pass_yards, total_pass_tds, total_ints
FROM ranked
WHERE rnk <= 10
ORDER BY season, rnk;
