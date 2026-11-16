--Rewriting the view 'dbo.view_player_game_clean'as 'dbo.vw_player_game' and reading the data from the fact_player_game, dim_game, and dim_player
--1)Creating view dbo.vw.player_game
CREATE OR ALTER VIEW dbo.vw_player_game AS
SELECT
    -- keys and identifiers
    f.game_id,
    f.player_id,
    p.player,
    f.position,
    f.position_group,
    f.team,
    CASE WHEN f.team = g.home_team 
    THEN 1 ELSE 0 
    END AS is_home,
    f.opponent_abbrev,

    -- passing
    f.pass_cmp, f.pass_att, f.pass_yds, f.pass_td, f.pass_int,
    f.pass_sacked, f.pass_sacked_yds, f.pass_long, f.pass_rating,

    -- rushing
    f.rush_att, f.rush_yds, f.rush_td, f.rush_long,

    -- receiving
    f.targets, f.rec, f.rec_yds, f.rec_td, f.rec_long,

    -- misc
    f.fumbles_lost, f.rush_scrambles, f.designed_rush_att,
    f.comb_pass_rush_play, f.comb_pass_play, f.comb_rush_play,
    f.two_point_conv, f.total_ret_td, f.offensive_fumble_recovery_td,
    f.pass_yds_bonus, f.rush_yds_bonus, f.rec_yds_bonus,

    -- fantasy points
    f.total_dkp, f.off_dkp, f.total_fdp, f.off_fdp, f.total_sdp, f.off_sdp,

    -- advanced stats
    f.pass_target_yds, f.pass_poor_throws, f.pass_blitzed, f.pass_hurried,
    f.rush_yds_before_contact, f.rush_yac, f.rush_broken_tackles,
    f.rec_air_yds, f.rec_yac, f.rec_drops, f.offense, f.off_pct,

    -- game context
    g.game_date, g.season,
    g.vis_team, g.home_team, g.vis_score, g.home_score,
    g.ot, g.roof, g.surface,
    g.temperature, g.humidity, g.wind_speed, g.is_indoor,
    g.vegas_line, g.vegas_favorite,
    CASE
        WHEN g.vegas_line = 0              THEN 0            -- pick'em
        WHEN g.vegas_favorite = f.team     THEN g.vegas_line -- team is favored
        WHEN g.vegas_favorite <> f.team    THEN -g.vegas_line-- team is the underdog
        ELSE NULL
    END AS team_spread,
    g.over_under
FROM dbo.fact_player_game AS f
JOIN dbo.dim_player AS p ON p.player_id = f.player_id
JOIN dbo.dim_game   AS g ON g.game_id   = f.game_id;