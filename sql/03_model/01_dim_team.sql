use NFL_offensive_fantasy_analysis;

--1) Creation of dim_team table
CREATE TABLE dbo.dim_team (
    team         VARCHAR(5)   NOT NULL,   -- should match the type used in dim_game
    team_name    VARCHAR(50)  NULL,
    conference   CHAR(3)      NULL,
    division     VARCHAR(10)  NULL,

    CONSTRAINT pk_dim_team PRIMARY KEY (team),
    CONSTRAINT ck_dim_team_conference CHECK (conference IN ('AFC', 'NFC'))
);

-- populate the key from the data
INSERT INTO dbo.dim_team (team)
SELECT DISTINCT team
FROM dbo.nfl_offensive_stats_master;

-- then fill in the extra columns with UPDATE statements or a one-off VALUES list
UPDATE t
SET t.team_name  = v.team_name,
    t.conference = v.conference,
    t.division   = v.division
FROM dbo.dim_team AS t
JOIN (VALUES
    -- AFC East
    ('BUF','Buffalo Bills','AFC','AFC East'),
    ('MIA','Miami Dolphins','AFC','AFC East'),
    ('NWE','New England Patriots','AFC','AFC East'),
    ('NYJ','New York Jets','AFC','AFC East'),
    -- AFC North
    ('BAL','Baltimore Ravens','AFC','AFC North'),
    ('CIN','Cincinnati Bengals','AFC','AFC North'),
    ('CLE','Cleveland Browns','AFC','AFC North'),
    ('PIT','Pittsburgh Steelers','AFC','AFC North'),
    -- AFC South
    ('HOU','Houston Texans','AFC','AFC South'),
    ('IND','Indianapolis Colts','AFC','AFC South'),
    ('JAX','Jacksonville Jaguars','AFC','AFC South'),
    ('TEN','Tennessee Titans','AFC','AFC South'),
    -- AFC West
    ('DEN','Denver Broncos','AFC','AFC West'),
    ('KAN','Kansas City Chiefs','AFC','AFC West'),
    ('LAC','Los Angeles Chargers','AFC','AFC West'),
    ('LVR','Las Vegas Raiders','AFC','AFC West'),
    -- NFC East
    ('DAL','Dallas Cowboys','NFC','NFC East'),
    ('NYG','New York Giants','NFC','NFC East'),
    ('PHI','Philadelphia Eagles','NFC','NFC East'),
    ('WAS','Washington Commanders','NFC','NFC East'),
    -- NFC North
    ('CHI','Chicago Bears','NFC','NFC North'),
    ('DET','Detroit Lions','NFC','NFC North'),
    ('GNB','Green Bay Packers','NFC','NFC North'),
    ('MIN','Minnesota Vikings','NFC','NFC North'),
    -- NFC South
    ('ATL','Atlanta Falcons','NFC','NFC South'),
    ('CAR','Carolina Panthers','NFC','NFC South'),
    ('NOR','New Orleans Saints','NFC','NFC South'),
    ('TAM','Tampa Bay Buccaneers','NFC','NFC South'),
    -- NFC West
    ('ARI','Arizona Cardinals','NFC','NFC West'),
    ('LAR','Los Angeles Rams','NFC','NFC West'),
    ('SEA','Seattle Seahawks','NFC','NFC West'),
    ('SFO','San Francisco 49ers','NFC','NFC West')
) AS v(team, team_name, conference, division)
    ON v.team = t.team;
