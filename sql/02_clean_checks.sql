/* 02_clean_checks.sql
   Simple checks for dbo.vw_player_game (Phase 2).
   Re-run the view script first, then highlight ONE query at a time and run it.
   Each query has its expected result in a comment.
   Expected numbers come from the CSV. */


-- 1) GRAIN

-- total rows
SELECT COUNT(*) AS n_rows
FROM dbo.vw_player_game;
-- expect 19973

-- total games
SELECT COUNT(DISTINCT game_id) AS n_games
FROM dbo.vw_player_game;
-- expect 820

-- duplicate player/game rows
SELECT game_id, player_id, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY game_id, player_id
HAVING COUNT(*) > 1;
-- expect no rows


-- 2) TRIMS AND TYPE CONVERSIONS

-- player names with leftover spaces (DATALENGTH because = ignores trailing spaces)
SELECT COUNT(*) AS padded_players
FROM dbo.vw_player_game
WHERE DATALENGTH(player) <> DATALENGTH(TRIM(player));
-- expect 0

-- surface values and counts
SELECT surface, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY surface
ORDER BY n DESC;
-- expect 6 rows: grass 12132, fieldturf 4404, astroturf 1360,
--                matrixturf 1082, sportturf 753, a_turf 242

-- roof values and counts
SELECT roof, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY roof
ORDER BY n DESC;
-- expect 4 rows: outdoors 13831, dome 3109, retractable roof (closed) 2644, retractable roof (open) 389

-- rows where a TRY_CAST / TRY_CONVERT silently failed and returned NULL
SELECT COUNT(*) AS lost_rows
FROM dbo.vw_player_game
WHERE game_date IS NULL
   OR total_dkp IS NULL
   OR off_dkp IS NULL
   OR vegas_line IS NULL
   OR over_under IS NULL
   OR pass_rating IS NULL;
-- expect 0


-- 3) POSITION_GROUP

SELECT position_group, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY position_group
ORDER BY n DESC;
-- expect WR 7944, RB 4486, TE 4711, QB 1994, FB 679, Other 159
-- and no NULL row (adds up to 19973)

-- which raw positions went where
SELECT position, position_group, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY position, position_group
ORDER BY position_group, n DESC;


-- 4) SEASON
SELECT season, COUNT(DISTINCT game_id) AS n_games
FROM dbo.vw_player_game
GROUP BY season
ORDER BY season;
-- expect 2019 = 266, 2020 = 269, 2021 = 285 (no NULL season)


-- 5) IS_HOME

SELECT is_home, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY is_home
ORDER BY is_home;
-- expect 0 = 9953, 1 = 10020

-- flag disagrees with team / home_team
SELECT COUNT(*) AS wrong_flags
FROM dbo.vw_player_game
WHERE (is_home = 1 AND team <> home_team)
   OR (is_home = 0 AND team = home_team);
-- expect 0


-- 6) TEAM_SPREAD

-- the 5 games with no clean favorite
SELECT DISTINCT game_id, team, vegas_line, vegas_favorite, team_spread
FROM dbo.vw_player_game
WHERE game_id IN ('202012020pit','202012070pit','202012080rav','202111290was','202112260rai')
ORDER BY game_id, team;
-- expect: 202012020pit, 202012070pit, 202012080rav -> team_spread NULL
--         202111290was, 202112260rai               -> team_spread 0.00

-- count of NULL and 0 spreads
SELECT team_spread, COUNT(*) AS n
FROM dbo.vw_player_game
WHERE team_spread IS NULL OR team_spread = 0
GROUP BY team_spread;
-- expect NULL = 70, 0 = 46

-- favorite should be negative, underdog positive
SELECT COUNT(*) AS wrong_signs
FROM dbo.vw_player_game
WHERE (vegas_favorite = team  AND team_spread > 0)
   OR (vegas_favorite <> team AND team_spread < 0);
-- expect 0

-- the two teams in a game should have opposite spreads (x and -x)
SELECT game_id, MIN(team_spread) AS low, MAX(team_spread) AS high
FROM dbo.vw_player_game
GROUP BY game_id
HAVING MIN(team_spread) <> -MAX(team_spread);
-- expect no rows

-- eyeball a few normal games
SELECT DISTINCT game_id, team, vegas_favorite, vegas_line, team_spread
FROM dbo.vw_player_game
WHERE game_id LIKE '20190908%'
ORDER BY game_id, team;
-- favorite shows a negative number, the other team the same number positive


-- 7) WEATHER

SELECT is_indoor, COUNT(*) AS n
FROM dbo.vw_player_game
GROUP BY is_indoor;
-- expect 0 = 13831, 1 = 6142

SELECT roof,
       COUNT(*)           AS n,
       COUNT(temperature) AS temp_rows,
       MIN(temperature)   AS min_temp,
       MAX(temperature)   AS max_temp,
       MIN(wind_speed)    AS min_wind,
       MAX(wind_speed)    AS max_wind
FROM dbo.vw_player_game
GROUP BY roof;
-- expect outdoors: temp_rows = n, temps about 7 to 93, wind 0 to 35
--        every other roof: temp_rows = 0 and NULL min / max



