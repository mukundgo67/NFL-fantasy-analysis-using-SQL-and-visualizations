--2) Creation of dim_game table
CREATE TABLE dbo.dim_game (
    -- key
    game_id          VARCHAR(20)   NOT NULL,

    -- when
    game_date        DATE          NOT NULL,
    season           SMALLINT      NOT NULL,

    -- who played
    vis_team         VARCHAR(5)    NOT NULL,
    home_team        VARCHAR(5)    NOT NULL,

    -- result
    vis_score        SMALLINT      NOT NULL,
    home_score       SMALLINT      NOT NULL,
    ot               BIT           NOT NULL,

    -- venue
    roof             VARCHAR(20)   NOT NULL,
    surface          VARCHAR(20)   NOT NULL,
    is_indoor        BIT           NOT NULL,

    -- weather (NULL when the roof is closed, per the Phase 2 decision)
    temperature      SMALLINT      NULL,
    humidity         SMALLINT      NULL,
    wind_speed       SMALLINT      NULL,

    -- betting market (NULL where the source has no favorite, e.g. pick'em)
    vegas_line       DECIMAL(6,2)  NULL,
    vegas_favorite   VARCHAR(5)    NULL,
    over_under       DECIMAL(4,1)  NULL,

    -- constraints
    CONSTRAINT pk_dim_game PRIMARY KEY (game_id),
    CONSTRAINT fk_dim_game_vis_team  FOREIGN KEY (vis_team)  REFERENCES dbo.dim_team (team),
    CONSTRAINT fk_dim_game_home_team FOREIGN KEY (home_team) REFERENCES dbo.dim_team (team),
    CONSTRAINT ck_dim_game_teams     CHECK (vis_team <> home_team),
    CONSTRAINT ck_dim_game_line      CHECK (vegas_line IS NULL OR vegas_line <= 0),
    CONSTRAINT ck_dim_game_weather   CHECK (is_indoor = 0 OR (temperature IS NULL AND humidity IS NULL AND wind_speed IS NULL))
);

--Increasing the number of characters so it can allow it 
ALTER TABLE dbo.dim_game ALTER COLUMN roof VARCHAR(30) NOT NULL;

--Populating the dim_game table with data from view
INSERT INTO dbo.dim_game (
    game_id, game_date, season,
    vis_team, home_team, vis_score, home_score, ot,
    roof, surface, is_indoor,
    temperature, humidity, wind_speed,
    vegas_line, vegas_favorite, over_under
)
SELECT DISTINCT
    game_id, game_date, season,
    vis_team, home_team, vis_score, home_score,
    CAST(ot AS BIT),
    roof, surface, is_indoor,
    temperature, humidity, wind_speed,
    vegas_line, vegas_favorite, over_under
FROM dbo.vw_player_game;