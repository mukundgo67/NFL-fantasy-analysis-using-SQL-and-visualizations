# Q2: Does home-field advantage show up in fantasy production?

**Method:** Average DraftKings offensive points (off_dkp) per player-game,
home vs away, by season and position (QB/RB/WR/TE). Playoff games included.
Source: sql/04_analysis/q02_home_vs_away_fantasy/q02_results.csv


1) **WRs** were the one position group where the home edge reversed in 2020\. Home scoring rose modestly (+0.21 points per row, from 7.50 to 7.71), but away scoring rose more (+0.52, from 7.39 to 7.91), so WRs scored 0.20 points *more* on the road than at home, the only season of the three where that happened. In 2019 and 2021 the home advantage was positive (+0.11 and \+0.19). One explanation could be the lack of crowds in 2020, making it easier to communicate reads to receivers, but this analysis can’t test that, and the gaps are small enough that chance could account for them.   
     
     
2) **QBs** advantage at home vs away slightly decreased in 2020(0.57 to 0.08), but it's not for a lack of points as both home and away scoring jumped with the latter going from an average of 15.66 to 16.33, a \+0.67 point average per game. The issue was home scoring didn't make that same jump as away scoring as home scoring only increased by an average of 0.19 points a game from 2019 to 2020. Overall though pretty consistent showing from QBs even if the home advantage didn’t increase since 2019, it still was a net positive throughout the 3 years.

3) **TEs** on the other hand show no meaningful difference between performance and home advantage. However, those TEs who averaged 50% of snap counts on their respective team’s offense did have a slight bump up from the COVID season with their average jumping up 0.14 points but again fell down to 0.00 in 2021\.

4) **RBs** numbers fluctuated both home and away throughout the 3 years, with a scoring drop in both home and away scoring in 2020(-0.59 home, \-0.54 away). What did stay consistent was the the home advantage which increased by \+0.05 in 2020 before subsequently dropping that same 0.05 in 2021\.

## Caveats
- Averages include low-snap players, so TE and WR numbers run low.
- Gaps are small relative to week-to-week variation.
