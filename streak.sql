describe user_streaks_sql;

use streaks;
select count(streak_id) as count, user_id
from user_streaks_sql
group by user_id
order by count desc;


SET @streak_count = 0;
SET @prev_user_id = NULL;
SET @prev_streak_active = NULL;

CREATE TEMPORARY TABLE streaks_new AS
SELECT 
    user_id,
    streak_created,
    IF(@prev_user_id = user_id AND @prev_streak_active = 1 AND streak_active = 1, 
       @streak_count := @streak_count + 1, 
       @streak_count := 1) AS current_streak_length,
    @prev_user_id := user_id,
    @prev_streak_active := streak_active
FROM 
    user_streaks_sql
ORDER BY 
    user_id, streak_created;
    
    SELECT 
    user_id,
    MAX(current_streak_length) AS longest_streak_length
FROM 
    streaks_new
GROUP BY 
    user_id
ORDER BY 
    longest_streak_length DESC;