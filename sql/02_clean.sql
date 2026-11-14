CREATE OR ALTER VIEW dbo.vw_player_game AS
SELECT
    -- keys and identifiers
    game_id,
    player_id,
    TRIM(player)                      AS player,
    position,
    CASE
    WHEN position = 'QB'                    THEN 'QB'
    WHEN position IN ('RB', 'HB')           THEN 'RB'
    WHEN position IN ('WR', 'WR/R', 'RB/W') THEN 'WR'  -- RB/W: 33 targets vs 9 rushes, so WR
    WHEN position = 'TE'                    THEN 'TE'
    WHEN position = 'FB'                    THEN 'FB'  -- kept separate: low-usage blockers would drag down RB averages
    ELSE 'Other'                                       -- P, K, T (one-off tackle-eligible plays), defense, line, etc
    END AS position_group,
    team,                             -- Team_abbrev is identical, so it's left out
    CASE
    WHEN team=home_team                     then 1
         else 0
         END AS is_home,
    Opponent_abbrev                   AS opponent_abbrev,

    -- passing
    pass_cmp, pass_att, pass_yds, pass_td, pass_int,
    pass_sacked, pass_sacked_yds, pass_long,
    CAST(pass_rating AS decimal(4,1)) AS pass_rating,

    -- rushing
    rush_att, rush_yds, rush_td, rush_long,

    -- receiving
    targets, rec, rec_yds, rec_td, rec_long,

    -- misc
    fumbles_lost, rush_scrambles, designed_rush_att,
    comb_pass_rush_play, comb_pass_play, comb_rush_play,
    two_point_conv, total_ret_td, offensive_fumble_recovery_td,
    pass_yds_bonus, rush_yds_bonus, rec_yds_bonus,

    -- fantasy points
    CAST(ROUND(TRY_CAST(Total_DKP AS float), 2) AS decimal(6,2)) AS total_dkp,
    CAST(ROUND(TRY_CAST(Off_DKP   AS float), 2) AS decimal(6,2)) AS off_dkp,
    CAST(Total_FDP AS decimal(6,2))   AS total_fdp,
    CAST(Off_FDP   AS decimal(6,2))   AS off_fdp,
    CAST(Total_SDP AS decimal(6,2))   AS total_sdp,
    CAST(Off_SDP   AS decimal(6,2))   AS off_sdp,

    -- advanced stats
    pass_target_yds, pass_poor_throws, pass_blitzed, pass_hurried,
    rush_yds_before_contact, rush_yac, rush_broken_tackles,
    CAST(rec_air_yds AS decimal(6,1)) AS rec_air_yds,
    rec_yac, rec_drops, offense, off_pct,

    -- game context
    d.gd AS game_date,
    CASE WHEN MONTH(d.gd)<=2
        THEN YEAR(d.gd)-1
        ELSE YEAR(d.gd)
    END                              AS season,

    vis_team, home_team, vis_score, home_score,
    OT                                AS ot,
    TRIM(Roof)                        AS roof,
    TRIM(Surface)                     AS surface,
    /*Temperature                       AS temperature,*/
    CASE
    WHEN TRIM(Roof) ='outdoors'       THEN Temperature
    ELSE NULL 
    END AS temperature,
    /*Humidity                          AS humidity,*/
    CASE 
    WHEN TRIM(Roof) ='outdoors'        THEN Humidity
    ELSE NULL
    END AS humidity,
    /*Wind_Speed                        AS wind_speed,*/
    CASE
    WHEN TRIM(Roof) ='outdoors'        THEN wind_Speed
    ELSE NULL
    END AS wind_speed,
    CASE
    WHEN TRIM(Roof) ='outdoors'        THEN 0
    ELSE 1
    END AS is_indoor,
    d.vegas_line AS vegas_line, --vegas_line gets converted in the apply clause
    d.vegas_favorite AS vegas_favorite, --vegas_favorite also gets converted in the apply clause
    CASE
    WHEN d.vegas_line = 0        then 0 --pick em game
    WHEN d.vegas_favorite = team then d.vegas_line --the team is favored here
    WHEN d.vegas_favorite <> team then -d.vegas_line -- the team is the underdog
    ELSE NULL
    END AS team_spread,
    CAST(Over_Under AS decimal(4,1))  AS over_under
FROM dbo.nfl_offensive_stats_master as m
CROSS APPLY (
SELECT TRY_CONVERT(date, m.game_date,101) as gd,
TRY_CAST(Vegas_Line AS decimal(6,2)) AS vegas_line,
NULLIF(NULLIF(TRIM(Vegas_Favorite), ''), 'ERROR - abbrev_team') AS vegas_favorite
) AS d;

--script to check if the team_spread CASE worked
/*select DISTINCT(game_id), team, vegas_favorite,vegas_line, team_spread
from dbo.vw_player_game*/

--script to check when teams dont have a spread
/*SELECT DISTINCT (game_id), team, vegas_line, vegas_favorite, team_spread
FROM dbo.vw_player_game
WHERE game_id IN ('202012020pit','202012070pit','202012080rav','202111290was','202112260rai')
ORDER BY game_id, team*/


/*select DISTINCT(game_id),team,roof, temperature, humidity, wind_speed
from dbo.vw_player_game
where roof='outdoors'*/

/* to check how many game were played indoors
select is_indoor, count(*) as n
from dbo.vw_player_game
group by is_indoor?


SELECT roof, COUNT(*) AS n, COUNT(temperature) AS temp_rows,
       MIN(temperature) AS min_temp, MAX(temperature) AS max_temp
FROM dbo.vw_player_game
GROUP BY roof;*/