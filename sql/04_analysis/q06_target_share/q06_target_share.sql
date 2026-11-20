-- Q6: Target share per player per game
-- Tier 2 (window functions)
-- Reads from: dbo.vw_player_game
--
-- Notes:
--  * Target share = a player's targets divided by his team's total targets
--    in that game, shown as a percentage.
--  * The team total comes from SUM(targets) OVER (PARTITION BY game_id, team).
--    There is no ORDER BY inside the OVER, so the sum covers the whole
--    team-game. Adding an ORDER BY would turn it into a running total.
--  * No position filter inside the CTE: the denominator must include every
--    player's targets (RB, WR, TE, and any FB, QB or Other rows). The position
--    filter is applied in the outer SELECT, after the window has run, so it
--    does not shrink the denominator.
--  * Only RB, WR and TE rows with at least 1 target are shown. FB, QB and
--    Other rows still count toward the team total.
--  * team_total_targets repeats on every player's row for that team-game, so
--    it should not be summed across rows.
--  * Division uses 100.0 to avoid integer division (targets is a SMALLINT),
--    and NULLIF guards against a team-game with zero targets.
--  * The percentage is CAST to DECIMAL(5,2) so it shows exactly 2 decimals.
--    ROUND alone would keep the column's original scale and show trailing
--    zeros.
--  * Sanity check: team targets should be close to the same team's pass
--    attempts (SUM(targets) vs SUM(pass_att) per game_id and team). Targets
--    usually run a few below attempts because of spikes and throwaways.
--    A shares-sum-to-100 check cannot catch errors, because shares divided by
--    their own partition total always sum to 100.
--  * Shares are per game. They are not averaged or rolled up to a season
--    level in this file.
--  * Playoff games are included.
--  * Players traded mid-season are handled by the team partition: each game
--    uses the team the player was on in that game.
--  * Output is sorted by game, then team, then target share (highest first),
--    so each team-game reads together.

USE NFL_offensive_fantasy_analysis
GO

WITH player_team_targets AS(
SELECT 
game_id,
player_id,
player,
position_group,
team,
opponent_abbrev,
rec,
targets,
SUM(targets) OVER (PARTITION BY game_id,team) AS team_total_targets
FROM dbo.vw_player_game
GROUP BY game_id,player_id,player,team,opponent_abbrev,rec,targets,position_group
)

SELECT game_id,
player_id,
player,
position_group,
team,
opponent_abbrev,
rec,
targets,
team_total_targets,
CAST(100.0 * targets/NULLIF(team_total_targets,0) AS decimal(5,2)) player_target_share
FROM player_team_targets
WHERE position_group IN ('QB','RB','WR','TE')
ORDER BY game_id, team, player_target_share DESC
