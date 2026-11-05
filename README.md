# NFL-fantasy-analysis-using-SQL-and-visualizations
This project here completes full a SQL end to end analysis of a dataset related NFL offensive statistics from the year of 2019 to 2022, here to answer key business questions from a case study.
The case study i am following is listed below along with the main business questions i intend to answer:

**Case study**: What really drives NFL offensive production?

Scenario: You’re a junior analyst at a fantasy-football media site. The editor wants five data-backed stories before next season. They don’t want “who scored the most.” They want why players over- or under-perform: how much do Vegas lines, weather, and venue matter? Your deliverable is a clean SQL model plus findings the editor can publish. 

The data. It has one row per player per game, about 20K rows covering 820 games, 1,020 players and 32 teams. The games run from Sept 2019 to Feb 2022, which is three seasons. The 69 columns fall into four groups:

Box score: passing, rushing and receiving.
Advanced stats: air yards, YAC, broken tackles, drops.
Fantasy points: DK, FD and SD.
Game context: score, roof, surface, temperature, wind, Vegas line and over/under.

**Tier 1: aggregation and joins**

1) Top 10 QBs per season by yards and TDs.
2) Home vs. away scoring. You’ll have to derive is_home by comparing team to home_team.
3) Dome vs. outdoor vs. retractable scoring (after cleaning).

**Tier 2: CTEs and window functions** 

4. Rank RBs per season by DK points per game, with a minimum-games filter.
5. A 4-game rolling average of fantasy points per player.
6. Target share: each player’s share of their team’s targets per game.
7. Efficiency leaders: catch rate, yards per attempt, drop rate, YAC.


**Tier 3: the context stories (your publishable findings)**

8. Game script: when a team is a 7+ point favorite vs. an underdog, how does the pass/run mix change?
9. Wind: does yards per pass attempt fall once wind passes about 15 mph?
10. Does the over/under hold up? At the game level, compare actual total points to Over_Under. How often does the over hit, and does that change by roof or surface?
11. Boom/bust index: the standard deviation of weekly fantasy points for WRs with 50+ targets. Who’s the most volatile?
12. Overperformers: who beats what their team’s spread implies? Define “overperform” yourself and defend it.




   
