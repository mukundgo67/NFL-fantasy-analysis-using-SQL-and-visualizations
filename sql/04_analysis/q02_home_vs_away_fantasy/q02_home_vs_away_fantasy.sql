-- Q2: Home vs away fantasy production
-- Tier 1 (aggregation)
-- Reads from: dbo.vw_player_game
-- Fantasy scoring: DraftKings, off_dkp
-- Notes: playoff games included; 2020 had limited or no fans;
-- FB and Other position groups excluded.
--Includes two derived columns: One with home advantage for all TEs overall and home advantage for those who's off_pct is above 50% as TEs production can vary a lot
use NFL_offensive_fantasy_analysis
go

WITH off_home_away AS(
SELECT season, 
position_group,
AVG(CASE WHEN is_home=1 THEN off_dkp END) AS home_scoring,
AVG(CASE WHEN is_home=0 THEN off_dkp END) AS away_scoring,
AVG(CASE WHEN is_home = 1 AND off_pct >= 50 THEN off_dkp END) AS home_reg,
AVG(CASE WHEN is_home = 0 AND off_pct >= 50 THEN off_dkp END) AS away_reg
FROM dbo.vw_player_game
WHERE position_group IN ('QB','RB','WR','TE')
GROUP BY season, position_group
)

SELECT 
season,
position_group,
ROUND(home_reg,2) AS home_reg,--players who had 50% off_pct playing at home
ROUND(away_reg,2) AS away_reg,--players who had 50% off_pct playing away
ROUND(home_scoring,2) AS home_scoring_ovr,
ROUND(away_scoring,2) AS away_scoring_ovr,
ROUND((home_scoring - away_scoring),2) as home_advantage_ovr --positive = higher at home, negative = lower at home 
FROM off_home_away 
ORDER BY season, position_group