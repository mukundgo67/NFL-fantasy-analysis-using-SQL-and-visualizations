--2) Create vw_game
--vw_game is one row per game, with some derived columns on top

CREATE OR ALTER VIEW dbo.vw_game AS
SELECT
    g.game_id, g.game_date, g.season,
    g.vis_team, g.home_team, g.vis_score, g.home_score, g.ot,
    g.roof, g.surface, g.is_indoor,
    g.temperature, g.humidity, g.wind_speed,
    g.vegas_line, g.vegas_favorite, g.over_under,

    -- results
    c.total_points,
    c.home_margin,
    CASE
        WHEN g.home_score > g.vis_score THEN g.home_team
        WHEN g.vis_score > g.home_score THEN g.vis_team
        ELSE 'TIE'
    END AS winner,

    -- betting outcomes (NULL when the source has no line)
    c.home_spread,
    CASE
        WHEN g.over_under IS NULL          THEN NULL
        WHEN c.total_points > g.over_under THEN 'Over'
        WHEN c.total_points < g.over_under THEN 'Under'
        ELSE 'Push'
    END AS ou_result,
    CASE
        WHEN c.home_spread IS NULL                THEN NULL
        WHEN c.home_margin + c.home_spread > 0    THEN 'Cover'
        WHEN c.home_margin + c.home_spread = 0    THEN 'Push'
        ELSE 'No cover'
    END AS home_ats_result
FROM dbo.dim_game AS g
CROSS APPLY (
    SELECT  
        g.vis_score + g.home_score AS total_points,
        g.home_score - g.vis_score AS home_margin,
        CASE
            WHEN g.vegas_line = 0              THEN 0
            WHEN g.vegas_favorite = g.home_team THEN g.vegas_line
            WHEN g.vegas_favorite = g.vis_team  THEN -g.vegas_line
            ELSE NULL
        END AS home_spread
) AS c;