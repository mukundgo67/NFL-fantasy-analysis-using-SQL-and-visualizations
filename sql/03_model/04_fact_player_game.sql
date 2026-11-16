--4) Creating of fact_player_game table
CREATE TABLE dbo.fact_player_game (
    -- keys
    game_id         VARCHAR(20)   NOT NULL,
    player_id       VARCHAR(10)   NOT NULL,
    team            VARCHAR(5)    NOT NULL,
    opponent_abbrev VARCHAR(5)    NOT NULL,

    -- position (can change from game to game, so it lives here)
    position        VARCHAR(10)   NOT NULL,
    position_group  VARCHAR(10)   NOT NULL,

    -- passing
    pass_cmp        SMALLINT NOT NULL,  pass_att       SMALLINT NOT NULL,
    pass_yds        SMALLINT NOT NULL,  pass_td        SMALLINT NOT NULL,
    pass_int        SMALLINT NOT NULL,  pass_sacked    SMALLINT NOT NULL,
    pass_sacked_yds SMALLINT NOT NULL,  pass_long      SMALLINT NOT NULL,
    pass_rating     DECIMAL(4,1)  NOT NULL,

    -- rushing
    rush_att        SMALLINT NOT NULL,  rush_yds       SMALLINT NOT NULL,
    rush_td         SMALLINT NOT NULL,  rush_long      SMALLINT NOT NULL,

    -- receiving
    targets         SMALLINT NOT NULL,  rec            SMALLINT NOT NULL,
    rec_yds         SMALLINT NOT NULL,  rec_td         SMALLINT NOT NULL,
    rec_long        SMALLINT NOT NULL,

    -- misc
    fumbles_lost    SMALLINT NOT NULL,  rush_scrambles SMALLINT NOT NULL,
    designed_rush_att SMALLINT NOT NULL,
    comb_pass_rush_play SMALLINT NOT NULL,
    comb_pass_play  SMALLINT NOT NULL,  comb_rush_play SMALLINT NOT NULL,
    two_point_conv  SMALLINT NOT NULL,  total_ret_td   SMALLINT NOT NULL,
    offensive_fumble_recovery_td SMALLINT NOT NULL,
    pass_yds_bonus  SMALLINT NOT NULL,  rush_yds_bonus SMALLINT NOT NULL,
    rec_yds_bonus   SMALLINT NOT NULL,

    -- fantasy points
    total_dkp       DECIMAL(6,2)  NOT NULL,  off_dkp  DECIMAL(6,2) NOT NULL,
    total_fdp       DECIMAL(6,2)  NOT NULL,  off_fdp  DECIMAL(6,2) NOT NULL,
    total_sdp       DECIMAL(6,2)  NOT NULL,  off_sdp  DECIMAL(6,2) NOT NULL,

    -- advanced stats
    pass_target_yds SMALLINT NOT NULL,  pass_poor_throws SMALLINT NOT NULL,
    pass_blitzed    SMALLINT NOT NULL,  pass_hurried     SMALLINT NOT NULL,
    rush_yds_before_contact SMALLINT NOT NULL,
    rush_yac        SMALLINT NOT NULL,  rush_broken_tackles SMALLINT NOT NULL,
    rec_air_yds     DECIMAL(6,1)  NOT NULL,
    rec_yac         SMALLINT NOT NULL,  rec_drops      SMALLINT NOT NULL,
    offense         SMALLINT NOT NULL,  off_pct        SMALLINT NOT NULL,

    -- keys and constraints
    CONSTRAINT pk_fact_player_game PRIMARY KEY (game_id, player_id),
    CONSTRAINT fk_fact_game     FOREIGN KEY (game_id)         REFERENCES dbo.dim_game (game_id),
    CONSTRAINT fk_fact_player   FOREIGN KEY (player_id)       REFERENCES dbo.dim_player (player_id),
    CONSTRAINT fk_fact_team     FOREIGN KEY (team)            REFERENCES dbo.dim_team (team),
    CONSTRAINT fk_fact_opponent FOREIGN KEY (opponent_abbrev) REFERENCES dbo.dim_team (team),
    CONSTRAINT ck_fact_team_opp CHECK (team <> opponent_abbrev),
    CONSTRAINT ck_fact_pass     CHECK (pass_cmp <= pass_att),
    CONSTRAINT ck_fact_rec      CHECK (rec <= targets),
    CONSTRAINT ck_fact_posgroup CHECK (position_group IN ('QB','RB','WR','TE','FB','Other'))
);

--Populating the fact_player_game table with data from the view
INSERT INTO dbo.fact_player_game (
    game_id, player_id, team, opponent_abbrev, position, position_group,
    pass_cmp, pass_att, pass_yds, pass_td, pass_int, pass_sacked, pass_sacked_yds, pass_long, pass_rating,
    rush_att, rush_yds, rush_td, rush_long,
    targets, rec, rec_yds, rec_td, rec_long,
    fumbles_lost, rush_scrambles, designed_rush_att,
    comb_pass_rush_play, comb_pass_play, comb_rush_play,
    two_point_conv, total_ret_td, offensive_fumble_recovery_td,
    pass_yds_bonus, rush_yds_bonus, rec_yds_bonus,
    total_dkp, off_dkp, total_fdp, off_fdp, total_sdp, off_sdp,
    pass_target_yds, pass_poor_throws, pass_blitzed, pass_hurried,
    rush_yds_before_contact, rush_yac, rush_broken_tackles,
    rec_air_yds, rec_yac, rec_drops, offense, off_pct
)
SELECT
    game_id, player_id, team, opponent_abbrev, position, position_group,
    pass_cmp, pass_att, pass_yds, pass_td, pass_int, pass_sacked, pass_sacked_yds, pass_long, pass_rating,
    rush_att, rush_yds, rush_td, rush_long,
    targets, rec, rec_yds, rec_td, rec_long,
    fumbles_lost, rush_scrambles, designed_rush_att,
    comb_pass_rush_play, comb_pass_play, comb_rush_play,
    two_point_conv, total_ret_td, offensive_fumble_recovery_td,
    pass_yds_bonus, rush_yds_bonus, rec_yds_bonus,
    total_dkp, off_dkp, total_fdp, off_fdp, total_sdp, off_sdp,
    pass_target_yds, pass_poor_throws, pass_blitzed, pass_hurried,
    rush_yds_before_contact, rush_yac, rush_broken_tackles,
    rec_air_yds, rec_yac, rec_drops, offense, off_pct
FROM dbo.vw_player_game;
