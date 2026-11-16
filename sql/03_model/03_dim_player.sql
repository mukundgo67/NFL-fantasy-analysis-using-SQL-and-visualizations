--3)Creating of dim_player
CREATE TABLE dim_player(
player_id VARCHAR(10) NOT NULL,
player    VARCHAR(50) NOT NULL

CONSTRAINT  pk_dim_player PRIMARY KEY (player_id)
);
GO
--Populating the dim_player table with data from the view
WITH ranked AS (
    SELECT
        player_id,
        player,
        ROW_NUMBER() OVER (
            PARTITION BY player_id
            ORDER BY game_date DESC, game_id DESC
        ) AS rn
    FROM dbo.vw_player_game
)

INSERT INTO dbo.dim_player (player_id, player)
SELECT player_id, player
FROM ranked
WHERE rn = 1;

/*A standard INSERT INTO operation would fail here because player_id needs unique IDs and player_id in view vw_player_game
has multiple entries of the same ID therefore we use a CTE with row_number and partition and then pick the latest entry (rn=1) by game_date*/
