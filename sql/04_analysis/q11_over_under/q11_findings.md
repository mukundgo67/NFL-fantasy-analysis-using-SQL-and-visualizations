# Q11: Boom/bust index for WRs

**Question:** Which WRs had the most volatile week-to-week fantasy scoring?

**Short answer:** The most volatile WRs by this index are mostly low-average receivers whose usual week is a bust, with an occasional big game. They are not players who swing between huge and terrible weeks. The order inside each season's list is mostly noise, but three names appear in more than one season's top 10 (Marquez Valdes-Scantling in all three), and repeat appearances are better evidence of real volatility than any single rank.

**Method:** One row per WR per season from `vw_player_game` (`position_group = 'WR'`), kept only if the WR had at least 50 targets and at least 8 games that season. Fantasy scoring is DraftKings, `off_dkp`. Each season is ranked on its own, highest index first, and the top 10 are shown. Seasons 2019-2021 are not pooled, and playoff games are included.

**Files:** [`q11_wr_boom_bust.sql`](q11_wr_boom_bust.sql) produced [`q11_results.csv`](q11_results.csv).

**Definitions**
- `Avg DK` is the WR's average `off_dkp` per game that season.
- `SD` is the sample standard deviation of his weekly `off_dkp`: how far his weekly scores typically sit from his own average.
- `Index` is `SD ÷ Avg DK`. It measures his swings relative to his normal week, so a high scorer isn't ranked as volatile just for scoring more.
- `Boom` is a game with `off_dkp` of 20 or more, `Bust` is a game under 5, and `In-between` is everything from 5 up to 20.

## Results (top 10 per season)

**2019**

| Rank | Player | Games | Targets | Avg DK | SD | Index | Boom | In-between | Bust |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Marquez Valdes-Scantling | 18 | 57 | 4.94 | 7.24 | 1.47 | 2 | 3 | 13 |
| 2 | Demarcus Robinson | 18 | 61 | 6.13 | 8.86 | 1.44 | 1 | 7 | 10 |
| 3 | DaeSean Hamilton | 16 | 52 | 3.98 | 5.12 | 1.29 | 0 | 4 | 12 |
| 4 | Steven Sims | 16 | 56 | 6.47 | 7.82 | 1.21 | 1 | 5 | 10 |
| 5 | Will Fuller | 12 | 79 | 12.83 | 15.11 | 1.18 | 2 | 7 | 3 |
| 6 | Phillip Dorsett | 15 | 58 | 6.83 | 7.59 | 1.11 | 1 | 6 | 8 |
| 7 | Breshad Perriman | 14 | 69 | 10.51 | 11.57 | 1.10 | 3 | 4 | 7 |
| 8 | Zach Pascal | 16 | 72 | 8.83 | 9.58 | 1.09 | 3 | 4 | 9 |
| 9 | Anthony Miller | 16 | 85 | 8.41 | 9.07 | 1.08 | 2 | 6 | 8 |
| 10 | Sammy Watkins | 16 | 102 | 11.31 | 12.13 | 1.07 | 2 | 9 | 5 |

**2020**

| Rank | Player | Games | Targets | Avg DK | SD | Index | Boom | In-between | Bust |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Scott Miller | 20 | 59 | 6.20 | 7.15 | 1.15 | 1 | 7 | 12 |
| 2 | Travis Fulgham | 13 | 67 | 9.15 | 10.27 | 1.12 | 1 | 5 | 7 |
| 3 | Damiere Byrd | 16 | 77 | 7.37 | 7.23 | 0.98 | 1 | 9 | 6 |
| 4 | Marquez Valdes-Scantling | 18 | 77 | 9.62 | 9.41 | 0.98 | 3 | 8 | 7 |
| 5 | A.J. Green | 16 | 104 | 6.96 | 6.68 | 0.96 | 0 | 9 | 7 |
| 6 | Willie Snead | 15 | 55 | 7.17 | 6.87 | 0.96 | 1 | 6 | 8 |
| 7 | KJ Hamler | 13 | 56 | 6.93 | 6.58 | 0.95 | 1 | 7 | 5 |
| 8 | Braxton Berrios | 15 | 55 | 6.49 | 6.13 | 0.95 | 0 | 8 | 7 |
| 9 | Breshad Perriman | 12 | 60 | 8.51 | 7.97 | 0.94 | 1 | 5 | 6 |
| 10 | N'Keal Harry | 14 | 57 | 5.35 | 4.85 | 0.91 | 0 | 7 | 7 |

**2021**

| Rank | Player | Games | Targets | Avg DK | SD | Index | Boom | In-between | Bust |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Gabriel Davis | 18 | 76 | 10.89 | 12.91 | 1.19 | 2 | 9 | 7 |
| 2 | Demarcus Robinson | 20 | 50 | 4.05 | 4.69 | 1.16 | 0 | 5 | 15 |
| 3 | Kadarius Toney | 10 | 57 | 8.54 | 9.50 | 1.11 | 1 | 5 | 4 |
| 4 | Jalen Reagor | 18 | 60 | 4.35 | 4.60 | 1.06 | 0 | 6 | 12 |
| 5 | Marquez Valdes-Scantling | 11 | 55 | 8.18 | 8.54 | 1.04 | 2 | 4 | 5 |
| 6 | Donovan Peoples-Jones | 14 | 58 | 8.12 | 8.00 | 0.98 | 1 | 7 | 6 |
| 7 | Ray-Ray McCloud | 17 | 68 | 4.19 | 4.12 | 0.98 | 0 | 6 | 11 |
| 8 | Olamide Zaccheaus | 17 | 53 | 5.28 | 5.06 | 0.96 | 1 | 6 | 10 |
| 9 | Nick Westbrook-Ikhine | 17 | 58 | 6.56 | 6.25 | 0.95 | 1 | 9 | 7 |
| 10 | Courtland Sutton | 17 | 98 | 9.19 | 8.70 | 0.95 | 3 | 6 | 8 |

In every row, boom + in-between + bust equals games played.

## Finding 1: A volatile WR mostly has a bad floor, not a boom and bust split

Across the 30 listed WR-seasons (468 games), 52% of games were busts (242), 40% were in-between (189), and only 8% were booms (37). No one in the lists had more than three games of 20 or more, and seven of the 30 never had one (Hamilton in 2019; Green, Berrios and Harry in 2020; Robinson, Reagor and McCloud in 2021). The index picks up WRs whose scores are spread widely compared with a low average, which for most of these players means a run of weak weeks and a few good ones. DaeSean Hamilton in 2019 is the clearest example: 3.98 average points, 12 busts in 16 games, and no boom.

## Finding 2: Very few combine volatility with a useful average

Only four of the 30 averaged more than 10 points: Will Fuller in 2019 (12.83), Sammy Watkins in 2019 (11.31), Gabriel Davis in 2021 (10.89) and Breshad Perriman in 2019 (10.51). Fuller is the standout, with an SD of 15.11 on a 12.83 average over 12 games: 2 booms, 3 busts and 7 in-between games. For fantasy purposes, he and Davis (2 booms and 7 busts in 18 games) are the "volatile but worth considering" cases. Most of the rest are volatile because they rarely scored much.

## Finding 3: Three names show up more than once

- **Marquez Valdes-Scantling** was in the top 10 in all three seasons: 1st in 2019 (index 1.47), 4th in 2020 (0.98) and 5th in 2021 (1.04).
- **Demarcus Robinson** was 2nd in both 2019 (1.44) and 2021 (1.16).
- **Breshad Perriman** was 7th in 2019 (1.10) and 9th in 2020 (0.94).

The 30 spots are filled by 26 different players. Each appearance comes from a separate season, so a player who keeps returning is stronger evidence of real volatility than where he sits in one year's list.

## Finding 4: 2019's list is more extreme than 2020's or 2021's

All ten WRs in the 2019 list have an SD bigger than their average (index of 1.07 or more). In 2020 only two do (1.15 and 1.12), and in 2021 five do (1.04 to 1.19). This file can't say whether that reflects a real difference between seasons, since it depends on how many WRs qualified each year and which ones.

## Finding 5: The order within each list is mostly noise

Each SD comes from only 10 to 20 games, so it carries noise of its own. As a rough guide, an SD can be off by about 18% at 16 games and about 24% at 10 games (probably more for skewed numbers like fantasy points). Two indexes would need to differ by about 50% before the gap is beyond that noise. By that standard:
- **2019, 1st vs 2nd:** 1.47 vs 1.44, a 2% difference, so the order is meaningless.
- **2019, 1st vs 10th:** 1.47 vs 1.07, a 37% difference, which is still inside the noise.
- **2020 and 2021:** the gap between 1st and 10th is about 25%, inside the noise too.

So the reliable statement is that a WR belongs to a volatile group, not that he is the single most volatile. Picking the top 10 from a noisy measure also tends to select players whose few games happened to be extreme, which means individual indexes are probably overstated.

## What this means for the editor

- Don't rank WRs on this index alone. It flags low-average receivers as volatile, so read it together with average points and the boom, in-between and bust counts.
- If the story is "who has upside", the short list is Fuller (2019), Watkins (2019), Davis (2021) and Perriman (2019), since they combine a 10+ average with big swings.
- Valdes-Scantling is the one name the data supports as persistently volatile, with Robinson and Perriman repeating in two seasons each.
- Reversing the ranking would give a most-consistent list, which is what a fantasy reader looking for a reliable floor wants.

## Caveats

- **Thresholds are definitions.** Boom (20 or more) and bust (under 5) are fixed DraftKings cutoffs chosen for this analysis, and different cutoffs change the counts.
- **Low averages inflate the index.** A small denominator makes `SD ÷ average` large. The lowest average in any top 10 is 3.98 (Hamilton, 2019).
- **Only the top 10 per season is shown.** The file says nothing about the WRs below that or about how many qualified.
- **Games include early exits.** All rows count as games, with no snap-share filter, so a game a WR left early can show up as a bust.
- **Playoff games are included**, so some players show more than 17 games. Demarcus Robinson's 2021 row shows 20 games, which is unusually high and should be confirmed against the source data before publishing.
- **Seasons are not pooled.** Roles change from year to year, but each WR's SD then rests on a single season of games.
