--Q3: Fantasy production by roof type
-- Tier 1 (aggregation)
-- Reads from: dbo.vw_player_game
-- Fantasy scoring: DraftKings, off_dkp
--
-- Notes:
--  * Seasons 2019-2021 are pooled. Splitting by season as well would leave
--    some roof/position cells too thin (and 2020 has no open-roof games).
--  * Roof labels are kept as they appear in the source. Retractable
--    open and closed are NOT merged, since they are different conditions.
--  * All rows included (no snap-share filter), same as Q2. FB and Other
--    position groups are excluded.
--  * Playoff games are included.
--  * Retractable roofs: 126 games, of which only 16 (about 13%) were
--    played open, so the open-roof rows are thin. Treat them with caution.
--  * 3 SFO "home" games in 2020 were played at a relocated venue with a
--    closed retractable roof, so they appear under retractable (closed).
--  * se_of_mean = STDEV / SQRT(n). To compare two groups, the noise on the
--    gap is SQRT(se1^2 + se2^2). A gap smaller than about twice that is
--    hard to tell apart from chance.
--  * Roof is a stadium trait tied to the home team, so team quality is
--    mixed in with roof type, and it overlaps with surface too.


use NFL_offensive_fantasy_analysis
go

SELECT 
roof, 
position_group,
COUNT(DISTINCT game_id) AS games,
COUNT(*) AS player_rows,
ROUND(AVG(off_dkp), 2) AS avg_off_dkp,
ROUND(STDEV(off_dkp) / SQRT(COUNT(*)), 2)  AS se_of_mean
FROM dbo.vw_player_game
WHERE position_group in ('QB','RB','TE','WR')
GROUP BY roof, position_group
ORDER BY avg_off_dkp DESC;

 
