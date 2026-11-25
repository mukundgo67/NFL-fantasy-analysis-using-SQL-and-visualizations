# **Q10: Does the over/under hold up?**

**Question:** How close is the Vegas over/under to the actual total points, how often does the over hit, and does that change by season, roof or surface?

**Short answer:** Overall the lines look roughly fair. The over hit 48.6% of the time and games finished only about half a point above their lines on average, and neither is distinguishable from a fair line. But a typical line misses by about 10.7 points, and roofed games are the one place where totals ran above the lines, which is suggestive rather than conclusive.

**Method:** One row per game from `vw_game` (all 820 games had a line). For each game, `line_error` is total points minus the over/under, so a positive number means the game went over. Results are grouped by season, roof and surface. Each game appears once in each of the three splits, so the games should only be added up within a split. Over rate is overs divided by overs plus unders, so pushes are excluded (10 games in total).

**Reading the error columns:**

* `Avg error` is the average of `line_error` (total points minus the over/under). Overs and unders cancel out, so it measures bias: whether games tend to land above or below the line.  
* `Mean abs error` is the average size of the miss, ignoring direction. A game that finishes 10 points over the line and one that finishes 10 points under both count as 10\. It tells you how far off a typical line is, not which way it leans. For example, the overall average error is only about \+0.47 points while the mean abs error is about 10.7, so the lines are close to unbiased but miss by roughly 10 points either way in a typical game.

**Reading the noise columns:**

* `se_of_avg_error` is the wobble in the average error. An average error smaller than about twice its SE can't be separated from zero.  
* `noise` is the rough wobble, in percentage points, around a 50% over rate. An over rate within about twice that of 50% can't be separated from a coin flip.

**Files:** `q10_over_under.sql` produced `q10_results.csv`.

## **Results**

**By season**

| Season | Games COUNT(\*) | Avg total AVG(total points) | Avg line AVG(over/under) | Avg error AVG(total \- line) | SE STDEV(error) ÷ √games | Mean abs error AVG(ABS(total \- line)) | Over rate overs ÷ (overs \+ unders) × 100 | Noise 100 × √(0.25 ÷ games) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| 2019 | 266 | 45.68 | 45.19 | \+0.49 | 0.82 | 10.82 | 49.81% | 3.07 |
| 2020 | 269 | 49.49 | 48.19 | \+1.30 | 0.79 | 10.31 | 50.19% | 3.05 |
| 2021 | 285 | 46.07 | 46.40 | \-0.33 | 0.79 | 10.86 | 46.07% | 2.96 |

**By roof (seasons pooled)**

| Roof | Games COUNT(\*) | Avg total AVG(total points) | Avg line AVG(over/under) | Avg error AVG(total \- line) | SE STDEV(error) ÷ √games | Mean abs error AVG(ABS(total \- line)) | Over rate overs ÷ (overs \+ unders) × 100 | Noise 100 × √(0.25 ÷ games) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| Outdoors | 567 | 45.60 | 45.95 | \-0.34 | 0.56 | 10.56 | 46.69% | 2.10 |
| Dome | 127 | 49.85 | 47.95 | \+1.90 | 1.25 | 11.29 | 54.40% | 4.44 |
| Retractable (closed) | 110 | 51.32 | 48.20 | \+3.12 | 1.20 | 10.65 | 52.73% | 4.77 |
| Retractable (open) | 16 | 47.63 | 47.88 | \-0.25 | 2.77 | 9.50 | 43.75% | 12.50 |

**By surface (seasons pooled)**

| Surface | Games COUNT(\*) | Avg total AVG(total points) | Avg line AVG(over/under) | Avg error AVG(total \- line) | SE STDEV(error) ÷ √games | Mean abs error AVG(ABS(total \- line)) | Over rate overs ÷ (overs \+ unders) × 100 | Noise 100 × √(0.25 ÷ games) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| Grass | 497 | 46.21 | 46.24 | \-0.03 | 0.59 | 10.51 | 47.86% | 2.24 |
| Fieldturf | 181 | 48.71 | 46.93 | \+1.78 | 0.93 | 10.35 | 50.56% | 3.72 |
| Astroturf | 56 | 48.39 | 47.25 | \+1.14 | 2.15 | 12.88 | 51.79% | 6.68 |
| Matrixturf | 45 | 48.47 | 48.88 | \-0.41 | 2.05 | 10.81 | 40.00% | 7.45 |
| Sportturf | 31 | 47.39 | 46.19 | \+1.19 | 2.43 | 11.19 | 58.06% | 8.98 |
| A-turf | 10 | 45.00 | 45.50 | \-0.50 | 4.06 | 9.90 | 44.44% | 15.81 |

## **Finding 1: Overall, the over/under is close to fair**

Adding up the three seasons (a calculation from the season rows, not a separate query), there were 394 overs and 416 unders, an over rate of about 48.6%, with noise of about 1.8 points around 50%. The average error is about \+0.47 points per game, against a standard error of about 0.5. Neither one is distinguishable from a fair line. No single season is either: the over rates (49.8%, 50.2% and 46.1%) are all well inside twice their noise (about 6 points), and none of the three average errors is bigger than twice its SE.

## **Finding 2: Being unbiased doesn't make the line precise**

The average miss, ignoring direction, was 10.3 to 10.9 points per game in each season (about 10.7 overall), on lines of about 46 points. Over- and under-misses cancel out in the average error, which is why the two measures tell different stories. The size of a typical miss is similar everywhere: it ranges from 9.5 to 11.3 across the four roof types and is 12.9 for astroturf, though that rests on only 56 games.

## **Finding 3: In 2020 scoring jumped and the line mostly followed**

Games averaged 49.49 points in 2020, against 45.68 in 2019 and 46.07 in 2021\. The average line rose from 45.19 to 48.19 (+3.0), so the market adjusted for most of the jump. What was left was \+1.30 points per game, which is about 1.65 times its standard error and falls short of the rule of thumb. The 2020 over rate was 50.2%, so overs and unders were still split almost evenly.

## **Finding 4: Roofed games went over their lines, outdoor games slightly under**

Dome games averaged 1.90 points above their lines and closed-roof retractable games 3.12 above, while outdoor games finished 0.34 below. Of the individual groups, only the closed-roof retractable average error (+3.12, with an SE of 1.20) clears twice its SE.

Putting the two roofed types together (a calculation from the table above, with an approximate noise estimate), the roofed average was about \+2.5 and the outdoor average about \-0.3, a gap of about 2.8 points against a threshold of about 2.1. In actual scoring, roofed games averaged about 50.5 points and outdoor games 45.6, a difference of about 4.9. The lines differed by only about 2.1 (about 48.1 against 45.9), so the market priced in roughly 40% of the gap.

The over rates tell a slightly weaker story. Roofed games went over about 53.6% of the time and outdoor games about 46.7%. That 6.9-point gap is just under the threshold of about 7.7, so on this measure it can't be separated from chance. Direction and size give different answers here, which is why both are shown.

This is consistent with the roof results in Q3, where fantasy production was higher indoors. It should be treated as suggestive.

## **Finding 5: Surface shows no clear pattern**

No surface has an average error or over rate beyond twice its noise. Fieldturf comes closest (+1.78 against a threshold of about 1.86). The extreme over rates are on the smallest groups: matrixturf at 40.0% (45 games) and sportturf at 58.1% (31 games), both well inside their large noise. Grass, the biggest group, sits almost exactly on the line (-0.03 average error).

## **What this means for the editor**

* There is no case here for a blanket "take the over" or "take the under". The over hit 48.6% of the time overall, and the average error is small.  
* Totals for roofed games (domes and closed retractable roofs) have run higher than the lines imply, by roughly two to three points. That is suggestive, not firm, but it matches the higher indoor fantasy scoring seen in Q3.  
* A single game's total is hard to predict: a typical line misses by about 10 to 11 points.  
* This file measures the totals only. Whether the market prices in the wind effect from Q9 (windy outdoor games going under more often) was not tested here.

## **Caveats**

* **Many comparisons.** With 13 groups across three splits, about one in twenty would clear a threshold by luck alone, so one group passing is weak evidence.  
* **Overlapping splits.** Roof and surface overlap (domes tend to have turf), and the same game appears in all three splits. Surface and roof differences are not independent effects.  
* **Thin groups.** The open-roof retractable group has 16 games (noise of 12.5 points) and A-turf has 10\. Their over rates say very little.  
* **Roof is tied to the home team**, so a few teams' offenses can drive a roof category.  
* **No odds, and the line's timing is unknown.** The data doesn't say whether the over/under is an opening or closing line, and it has no prices. Nothing here measures betting returns.  
* **Derived figures.** The pooled over rate, the pooled average error and the combined roofed figures are calculated from the rows in the results file, with approximate noise estimates. A direct query for roofed vs outdoor games would give exact values.  
* Playoff games are included. 2020 was played in mostly empty stadiums.

