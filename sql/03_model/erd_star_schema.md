# NFL Star Schema (ERD)

```mermaid
erDiagram
    dim_team ||--o{ dim_game : "home_team"
    dim_team ||--o{ dim_game : "vis_team"
    dim_team ||--o{ fact_player_game : "team"
    dim_team ||--o{ fact_player_game : "opponent_abbrev"
    dim_player ||--o{ fact_player_game : "player_id"
    dim_game ||--o{ fact_player_game : "game_id"

    dim_team {
        varchar team PK
        varchar team_name
        char conference
        varchar division
    }
    dim_player {
        varchar player_id PK
        varchar player
    }
    dim_game {
        varchar game_id PK
        date game_date
        smallint season
        varchar vis_team FK
        varchar home_team FK
        smallint vis_score
        smallint home_score
        bit ot
        varchar roof
        varchar surface
        bit is_indoor
        smallint temperature
        smallint humidity
        smallint wind_speed
        decimal vegas_line
        varchar vegas_favorite
        decimal over_under
    }
    fact_player_game {
        varchar game_id PK,FK
        varchar player_id PK,FK
        varchar team FK
        varchar opponent_abbrev FK
        varchar position
        varchar position_group
        smallint stat_columns "passing, rushing, receiving, fantasy and advanced stats"
    }
```

## Views
- `vw_player_game` joins `fact_player_game` to `dim_player` and `dim_game`, and derives `is_home` and `team_spread`.
- `vw_game` reads `dim_game` and derives total points, margin, winner, and over/under and spread results.
