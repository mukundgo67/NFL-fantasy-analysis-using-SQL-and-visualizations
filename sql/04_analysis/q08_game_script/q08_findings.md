# **Q8: Game script. How does the pass/run mix change with the spread?**

**Question:** Do teams that are 7+ point favorites run the ball more, and do 7+ point underdogs pass more?

**Method:** Player rows from `vw_player_game` were summed to one row per team per game, then bucketed by that team's pregame `team_spread` (favorite 7+ is a spread of \-7 or lower, underdog 7+ is \+7 or higher, and everything between is "middle"; the cutoffs are inclusive). Pass rate is pass attempts divided by pass plus rush attempts. Seasons 2019-2021 are pooled, and playoff games are included.

**Files:** `q08_game_script.sql` produced `q08_results.csv`.

## **Results**

| Bucket | Team-games | Pass att / game | Rush att / game | Pass rate (game average) | SE |
| ----- | ----- | ----- | ----- | ----- | ----- |
| Favorite 7+ | 270 | 34.6 | 28.7 | 54.54% | 0.67 |
| Middle | 1,094 | 35.0 | 26.7 | 56.68% | 0.33 |
| Underdog 7+ | 270 | 34.5 | 24.0 | 58.97% | 0.63 |
| No line | 6 | 38.8 | 24.7 | 58.89% | 7.81 |

The pooled pass rate (total passes over total plays) agrees with the game-average column to within about 0.15 points in the three main buckets (54.68%, 56.72%, 59.01%), so the choice of weighting doesn't change the story.

## **Finding 1: The pass rate rises steadily as the spread moves toward underdog**

Favorites passed on 54.5% of their plays, middle games on 56.7% and underdogs on 59.0%. The favorite-to-underdog gap is 4.4 percentage points, against a noise level of about 0.92 (the square root of the two standard errors squared and added), so it is well beyond the rough threshold of twice the noise (1.84). Each step is also clear of the noise on its own: favorite to middle is 2.1 points (threshold 1.5), and middle to underdog is 2.3 points (threshold 1.4).

## **Finding 2: Passing volume is flat. Rushing is what moves**

Favorites and underdogs threw almost the same number of passes per game (34.6 against 34.5). The difference is in rushing: favorites averaged 28.7 rush attempts per game and underdogs 24.0, which is 4.7 fewer. Underdogs also ran fewer total plays (58.5 pass and rush attempts per game against 63.3 for favorites). So the higher pass rate for underdogs comes from running less, not from throwing more.

Standard errors were calculated for the pass rate only. This file does not test whether the per-game attempt counts differ by more than chance.

## **What this means for the editor**

* Team rushing volume depends on the spread. A running back on a 7+ point favorite plays for a team that averages about 4.7 more rush attempts per game than one on a 7+ point underdog.  
* The data does not support "underdogs throw more" as a volume claim. Pass attempts per game barely change across the buckets, so the case for extra targets on underdogs would have to come from something other than team pass attempts.  
* This file measures team behavior, not player fantasy output. Whether the shift shows up in running back or receiver fantasy points would need the player-level extension (average `off_dkp` by position and bucket).

## **Caveats**

* **Spread is a pregame expectation.** A favorite that trails at halftime will pass more. The finding describes expected game script on average, not what happened in each game. Bucketing by final margin instead would be circular, because a team that runs more while leading helps create that margin.  
* **Favorites are better teams on average.** The data can't separate "favorites run more because they lead" from "better teams run more regardless".  
* **Kneel-downs probably count as rush attempts**, which would add to favorites' rush totals late in games. They can't be separated out here.  
* **Play definitions:** pass attempts do not include sacks, and QB scrambles are counted as rushes. This output does not include a version that treats sacks and scrambles as pass plays.  
* **The same 270 games supply both the favorite and underdog rows**, so the two buckets are not independent samples. The noise estimate treats them as independent, which makes it a rough guide and not a precise one.  
* **"No line" is six team-games (three games).** The average is far too noisy to interpret (SE 7.81), so it is shown for completeness only.  
* Three of the 49ers' 2020 "home" games were played at a relocated venue. Their spread follows the Vegas favorite, so they are bucketed normally.

