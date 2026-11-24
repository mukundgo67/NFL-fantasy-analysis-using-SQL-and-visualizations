-- Q8: Game script, pass/run mix for 7+ point favorites vs 7+ point underdogs
-- Tier 3 (context story)
-- Reads from: dbo.vw_player_game
--
-- Question: how does a team's pass/run mix change with its pregame spread?
--
-- Buckets (by team_spread, which is signed per team: negative = favored):
--   favorite 7+ : team_spread <= -7
--   underdog 7+ : team_spread >=  7
--   middle      : everything between, including pick'ems (spread 0)
--   no line     : team_spread is NULL (no usable Vegas line)
--   The 7-point cutoffs are inclusive.
--
-- Notes:
--  * Play counts: pass plays = pass_att, run plays = rush_att, summed from
--    player rows to one row per team per game. Pass rate = pass plays divided
--    by (pass plays + run plays). Sacks are not counted as pass plays, and
--    QB scrambles are counted as rushes. An alternative definition (sacks and
--    scrambles as pass plays, designed runs only) is:
--        SUM(pass_att + pass_sacked + rush_scrambles) and SUM(designed_rush_att)
--    [Add result: whether the story is the same under both definitions.]
--  * No position filter: rushes come from QBs, WRs and others, not only RBs,
--    so filtering positions would drop real plays.
--  * The aggregation runs in two steps. Step 1 collapses player rows to one
--    row per team per game, so a team isn't counted once per player. team_spread
--    is the same on every row of a team-game, so including it in the GROUP BY
--    doesn't split anything. Step 2 collapses team-games to one row per bucket.
--  * Two versions of the pass rate are shown:
--      pooled_pass_rate_pct   = total passes / total plays in the bucket
--                               (busier games weigh more)
--      avg_game_pass_rate_pct = average of each team-game's own rate
--                               (every team-game weighs the same)
--    se_of_avg = STDEV / SQRT(n) for the game-level average. To compare two
--    buckets, the noise on the gap is SQRT(se1^2 + se2^2), and a gap smaller
--    than about twice that is hard to tell apart from chance.
--  * Spread is a PREGAME expectation, not the in-game score. A 7-point
--    favorite who trails at halftime will pass more, so the finding is about
--    expected game script on average. Bucketing by final margin instead would
--    be circular, since a team that runs more when leading helps create that
--    margin.
--  * Kneel-downs probably count as rush attempts in this data, which would
--    inflate favorites' run plays late in games. They can't be separated out.
--  * NULL spreads get their own 'no line' row, so they can't fall into
--    'middle'. [Add the number of team-games with no line.]
--  * Sanity checks: team_games for 'favorite 7+' and 'underdog 7+' must be
--    identical (each such game has one of each). All four rows should add up
--    to roughly two team-games per game. Average total plays per team-game
--    should be around 60 to 65.
--    [Add check results here.]
--  * Playoff games are included. The three SFO "home" games in 2020 were
--    played at a relocated venue; team_spread follows the Vegas favorite, so
--    they are bucketed normally.
--  * Seasons are pooled.

USE NFL_offensive_fantasy_analysis;
GO

WITH team_game AS (
-- Player rows -> one row per team per game
SELECT
game_id,
team,
team_spread,
SUM(pass_att) AS pass_att,
SUM(rush_att) AS rush_att
FROM dbo.vw_player_game -- no position filter: rushes come from QBs, WRs and others too
GROUP BY game_id, team, team_spread
),

bucketed AS (
SELECT *,
CASE
WHEN team_spread IS NULL THEN 'no line'
WHEN team_spread <= -7   THEN 'favorite 7+'
WHEN team_spread >=  7   THEN 'underdog 7+'
ELSE 'middle'
END AS bucket,
100.0 * pass_att / NULLIF(pass_att + rush_att, 0) AS game_pass_rate,
100.0 * rush_att / NULLIF(pass_att + rush_att,0) AS game_rush_rate
FROM team_game
)

SELECT
bucket,
COUNT(*) AS team_games,
SUM(pass_att) AS pass_att, --Adding the pass attempts according to their buckets
SUM(rush_att) AS rush_att, --Adding the rush attempts according to their buckets
    -- pooled: total passes over total plays in the bucket
CAST(100.0 * SUM(pass_att)/ NULLIF(SUM(pass_att) + SUM(rush_att), 0) AS decimal(5,2)) AS pooled_pass_rate_pct, -- game-level: each team-game's rate averaged, with its noise
CAST(AVG(game_pass_rate) AS decimal(5,2)) AS avg_game_pass_rate_pct,
CAST(AVG(game_rush_rate) AS decimal(5,2)) AS avg_game_rush_rate_pct,
CAST(STDEV(game_pass_rate) / SQRT(COUNT(*)) AS decimal(5,2)) AS se_of_avg,
CAST(AVG(1.0 * pass_att) AS decimal(5,1)) AS avg_pass_att_per_game,
CAST(AVG(1.0 * rush_att) AS decimal(5,1)) AS avg_rush_att_per_game
FROM bucketed
GROUP BY bucket
ORDER BY 
CASE bucket
WHEN 'favorite 7+' THEN 1
WHEN 'middle' THEN 2
WHEN 'underdog 7+' THEN 3
ELSE 4 END;