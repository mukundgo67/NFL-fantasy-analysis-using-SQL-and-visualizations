# **Q9: Wind and passing efficiency**

**Question:** Does yards per pass attempt fall once the wind reaches about 15 mph?

**Short answer:** Yes, passing efficiency is lower in windy games, but the drop starts around 10 mph, not 15\. Between 10 and 15 mph there is little further decline.

**Method:** Player rows from `vw_player_game` were summed to one row per game (both teams' passing combined), for outdoor games with a wind reading, then bucketed by wind speed in mph (0-4, 5-9, 10-14, and 15+, where 15 itself is in the top bucket). Yards per attempt is gross: pass yards divided by pass attempts, with sacks not counted. Seasons 2019-2021 are pooled, and playoff games are included.

**Files:** `q09_wind_passing.sql` produced `q09_results.csv`.

## **Results**

| Wind | Games | Avg yards per attempt | SE | Completion % | Pass att / game | Avg temp (F) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| 0-4 mph | 140 | 7.14 | 0.09 | 64.22 | 70.4 | 61.9 |
| 5-9 mph | 216 | 7.25 | 0.09 | 64.74 | 68.9 | 58.2 |
| 10-14 mph | 134 | 6.79 | 0.10 | 62.62 | 69.4 | 56.7 |
| 15+ mph | 77 | 6.72 | 0.13 | 62.78 | 66.4 | 57.9 |

The four buckets add up to 567 games, which is every outdoor game, so no outdoor game was dropped for a missing wind reading. The pooled yards per attempt (total yards over total attempts) is within 0.01 of the game average in every bucket, so the weighting doesn't change anything.

## **Finding 1: The drop starts at 10 mph, not 15**

Yards per attempt was flat between calm and light wind (7.14 at 0-4 mph and 7.25 at 5-9 mph, a gap of 0.11 that is inside the noise). It then fell to 6.79 at 10-14 mph and 6.72 at 15+ mph. The windiest bucket has the lowest average, but it is only 0.07 below the 10-14 bucket.

A gap is clearly beyond chance when it is bigger than about twice its noise (the square root of the two standard errors squared and added):

| Comparison | Gap | 2 x noise | Beyond chance? |
| ----- | ----- | ----- | ----- |
| 0-4 vs 5-9 mph | 0.11 (5-9 is higher) | 0.25 | No |
| 5-9 vs 10-14 mph | 0.46 | 0.27 | Yes |
| 10-14 vs 15+ mph | 0.07 | 0.33 | No |
| 0-4 vs 15+ mph | 0.42 | 0.32 | Yes |

So the step down comes between 5-9 and 10-14 mph, a loss of about 0.46 yards per attempt (roughly 6% of the 5-9 mph average). The data do not show an extra penalty above 15 mph. The 15+ bucket also has the widest standard error (0.13), because it has the fewest games (77).

## **Finding 2: Completions fall and the ones that happen go shorter**

Completion percentage was about 64% in the two lightest buckets and about 62.7% in the two windiest. Dividing yards per attempt by completion rate gives an implied yards per completion of 11.1, 11.2, 10.8 and 10.7 across the four buckets, so catches were also slightly shorter in the wind. Both effects contribute to the lower yards per attempt. This is derived from the table above, with no separate noise check on the completion percentages, and the data can't say why.

## **Finding 3: Passing volume dips only at the top end, and not steadily**

Teams combined for 70.4 pass attempts per game in calm conditions and 66.4 at 15+ mph, which is exactly 4.0 fewer (about 6%). But the pattern isn't a steady decline: 10-14 mph games (69.4) had more attempts than 5-9 mph games (68.9). This output has no standard error for attempts, so it can't say whether the 4-attempt gap is beyond chance. Efficiency moves earlier and more clearly than volume does.

## **Finding 4: Temperature doesn't explain the drop**

The windy buckets were not much colder than the 5-9 mph bucket (56.7 and 57.9 degrees against 58.2), so the step down at 10 mph does not come with a large temperature change. Calm games were warmer (61.9) but did not have better passing than 5-9 mph games(in term of completion percentage) . These are bucket averages, so they can't rule out a mix of cold and wind inside individual games.

## **What this means for the editor**

* The common rule of thumb of "15 mph and up" may set the line too high. In this data, passing efficiency is already lower at 10-14 mph.  
* The effect is real but modest: about 0.4 to 0.5 yards per attempt. For a team throwing 35 passes, that is roughly 16 passing yards before any change in touchdowns or interceptions.  
* This file measures passing efficiency, not fantasy points. A player-level version (average `off_dkp` for QBs and receivers by wind bucket) would show how much of it reaches fantasy scores.

## **Caveats**

* **Outdoor games only.** Indoor and open-roof retractable games have no wind reading in the cleaned data, so the result applies to outdoor stadiums.  
* **Association, not cause.** Some outdoor stadiums are windier than others, so a few venues and teams may drive the windy buckets. Team quality and surface are not controlled for, and precipitation is not in the data.  
* **No rush attempts in this output**, so it can't say whether teams ran more when passing volume fell.  
* **Gross yards per attempt.** Sacks are not counted as attempts and sack yards are not subtracted.  
* **Wind readings are whole miles per hour.** The data doesn't say when in the game the reading was taken.  
* Playoff games are included.

