-- Pitch Counts for the Season
SELECT player_name, COUNT(*) AS pitches
FROM dodger_pitches
GROUP BY player_name
ORDER BY pitches DESC;

-- Pitch Types for Gavin Stone
SELECT player_name, pitch_name, COUNT(*) AS pitches
FROM dodger_pitches
WHERE player_name = 'Stone, Gavin'
GROUP BY player_name, pitch_name
ORDER BY pitches DESC;

-- Number of strikeouts for each pitch name from Tyler Glasnow
SELECT player_name, pitch_name, COUNT(*) AS pitches
FROM dodger_pitches
WHERE player_name = 'Glasnow, Tyler' AND events = 'strikeout'
GROUP BY player_name, pitch_name
ORDER BY pitches DESC;

-- Whiff Rate for each pitch name for Gavin Stone
SELECT 
    pitch_type, 
    COUNT(CASE WHEN description IN ('swinging_strike', 'swinging_strike_blocked') THEN 1 END) * 1.0 / 
    COUNT(CASE WHEN description IN ('foul', 'hit_into_play', 'swinging_strike', 'swinging_strike_blocked') THEN 1 END) 
    AS whiff_rate
FROM dodger_pitches
WHERE player_name = 'Stone, Gavin'
GROUP BY pitch_type
ORDER BY whiff_rate DESC;

-- Find the pitch with the highest whiff rate for each pitcher
WITH WhiffRates AS (
    SELECT 
        player_name,
        pitch_name, 
        COUNT(CASE WHEN description IN ('swinging_strike', 'swinging_strike_blocked') THEN 1 END) * 1.0 / 
        COUNT(CASE WHEN description IN ('foul', 'foul_tip', 'hit_into_play', 'swinging_strike', 'swinging_strike_blocked') THEN 1 END)
        AS whiff_rate
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
)
SELECT w1.player_name, w1.pitch_name, w1.whiff_rate
FROM WhiffRates w1
WHERE w1.whiff_rate = (
    SELECT MAX(w2.whiff_rate) 
    FROM WhiffRates w2 
    WHERE w2.player_name = w1.player_name
)
ORDER BY w1.whiff_rate DESC;

-- Find the 10 pitches with the highest whiff rate
WITH WhiffRates AS (
    SELECT 
        player_name,
        pitch_name, 
        COUNT(CASE WHEN description IN ('swinging_strike', 'swinging_strike_blocked') THEN 1 END) * 1.0 / 
        COUNT(CASE WHEN description IN ('foul', 'foul_tip', 'hit_into_play', 'swinging_strike', 'swinging_strike_blocked') THEN 1 END)
        AS whiff_rate
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
)
SELECT player_name, pitch_name, whiff_rate
FROM WhiffRates
ORDER BY whiff_rate DESC
LIMIT 10;

-- Find the 10 pitches with the lowest whiff rate (pitch has been thrown at least 50 times)
WITH WhiffRates AS (
    SELECT 
        player_name,
        pitch_name, 
        COUNT(CASE WHEN description IN ('swinging_strike', 'swinging_strike_blocked') THEN 1 END) * 1.0 / 
        COUNT(CASE WHEN description IN ('foul', 'foul_tip', 'hit_into_play', 'swinging_strike', 'swinging_strike_blocked') THEN 1 END)
        AS whiff_rate,
        COUNT(*) AS total_pitches
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
    HAVING COUNT(CASE WHEN description IN ('foul', 'foul_tip', 'hit_into_play', 'swinging_strike', 'swinging_strike_blocked') THEN 1 END) >= 50
)
SELECT player_name, pitch_name, whiff_rate
FROM WhiffRates
ORDER BY whiff_rate ASC
LIMIT 10;

-- 10 pitches with the lowest batting average
WITH BattingAverages AS (
    SELECT 
        player_name,
        pitch_name, 
        COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run') THEN 1 END) * 1.0 /
        COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'grounded_into_double_play', 'sac_fly', 'sac_bunt') THEN 1 END)
        AS opponent_ba
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
    HAVING COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'grounded_into_double_play', 'sac_fly', 'sac_bunt') THEN 1 END) >= 30
)
SELECT player_name, pitch_name, opponent_ba
FROM BattingAverages
ORDER BY opponent_ba ASC
LIMIT 10;

-- 10 pitches with the highest batting average
WITH BattingAverages AS (
    SELECT 
        player_name,
        pitch_name, 
        COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run') THEN 1 END) * 1.0 /
        COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'double_play', 'grounded_into_double_play', 'field_error', 'fielders_choiece', 'fielders_choice_out', 'strikeout', 'strikeout_double_play') THEN 1 END)
        AS opponent_ba
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
    HAVING COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'double_play', 'grounded_into_double_play', 'field_error', 'fielders_choiece', 'fielders_choice_out', 'strikeout', 'strikeout_double_play') THEN 1 END) >= 50
)
SELECT player_name, pitch_name, opponent_ba
FROM BattingAverages
ORDER BY opponent_ba DESC
LIMIT 10;

-- 10 pitches with the lowest slugging percentage
WITH Slugging AS (
    SELECT 
        player_name,
        pitch_name, 
        (SUM(CASE WHEN events = 'single' THEN 1 
                  WHEN events = 'double' THEN 2
                  WHEN events = 'triple' THEN 3
                  WHEN events = 'home_run' THEN 4 
                  ELSE 0 END) * 1.0) / 
        COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'double_play', 'grounded_into_double_play', 'field_error', 'fielders_choiece', 'fielders_choice_out', 'strikeout', 'strikeout_double_play') THEN 1 END) 
        AS slugging_percentage,
        COUNT(*) AS total_pitches
    FROM dodger_pitches
    GROUP BY player_name, pitch_name
    HAVING COUNT(CASE WHEN events IN ('single', 'double', 'triple', 'home_run', 'field_out', 'force_out', 'double_play', 'grounded_into_double_play', 'field_error', 'fielders_choiece', 'fielders_choice_out', 'strikeout', 'strikeout_double_play') THEN 1 END) >= 50
)
SELECT player_name, pitch_name, slugging_percentage
FROM Slugging
ORDER BY slugging_percentage DESC
LIMIT 10;

SELECT 
    player_name,
    STDDEV(release_pos_x) AS stddev_release_x,
    STDDEV(release_pos_z) AS stddev_release_z,
    STDDEV(release_extension) AS stddev_release_extension
FROM dodger_pitches
GROUP BY player_name
ORDER BY stddev_release_x + stddev_release_z + stddev_release_extension ASC;


SELECT 
    pitch_name,
    AVG(release_pos_x) AS avg_release_x,
    AVG(release_pos_z) AS avg_release_z,
    AVG(release_extension) AS avg_release_extension
FROM dodger_pitches
WHERE player_name = 'Yamamoto, Yoshinobu'
GROUP BY pitch_name
HAVING pitch_name = '4-Seam Fastball'
UNION
SELECT 
    pitch_name,
    AVG(release_pos_x) AS avg_release_x,
    AVG(release_pos_z) AS avg_release_z,
    AVG(release_extension) AS avg_release_extension
FROM dodger_pitches
WHERE player_name = 'Yamamoto, Yoshinobu'
GROUP BY pitch_name
HAVING pitch_name = 'Curveball';

SELECT 
    pitch_name,
    AVG(release_pos_x) AS avg_release_x,
    AVG(release_pos_z) AS avg_release_z,
    AVG(release_extension) AS avg_release_extension
FROM dodger_pitches
WHERE player_name = 'Miller, Bobby'
GROUP BY pitch_name
HAVING pitch_name = '4-Seam Fastball'
UNION
SELECT 
    pitch_name,
    AVG(release_pos_x) AS avg_release_x,
    AVG(release_pos_z) AS avg_release_z,
    AVG(release_extension) AS avg_release_extension
FROM dodger_pitches
WHERE player_name = 'Miller, Bobby'
GROUP BY pitch_name
HAVING pitch_name = 'Curveball';




