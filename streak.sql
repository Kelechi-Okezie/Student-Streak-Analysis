Part 1: Calculating Longest Streak
Step 1: Understand the Data Structure

This first step is to familiarize yourself with the structure of the data. Run the following command in your SQL environment to view how the table user_streaks_sql is organized:

DESCRIBE user_streaks_sql;
Now, you have information about each table column such as name, data type, default values, and whether it can be NULL or not.

After you've viewed the structure, select a few rows to understand the data in them:

SELECT * FROM user_streaks_sql LIMIT 10;
Review your selected region and make sure to look closely at what each row represents.

Step 2: Initialize the Variables

Before calculating the user streaks, you need to initialize some user-defined variables with the SET command as follows:

SET @streak_count := 0;
SET @prev_user_id := NULL;
SET @prev_streak_active := NULL;
The variables  @streak_count  ,  @prev_user_id  , and  @prev_streak_active   are initialized to 0, NULL, and NULL respectively.

Step 3: Calculate the Streak Lengths

Next, construct a temporary table named  streaks_new   to calculate each user’s streak length using the CREATE TEMPORARY TABLE command. Here is the relevant code:

CREATE TEMPORARY TABLE streaks_new AS (
  SELECT 
    user_id,
    streak_created,
    streak_active,
    streak_frozen,
    (
      -- Check if the same user has an active streak continuing from the previous day
      CASE
        WHEN @prev_user_id = user_id AND @prev_streak_active = 1 AND streak_active = 1
        THEN @streak_count := @streak_count + 1
        ELSE @streak_count := 0 
      END
    ) AS streak_length,
    -- Update the values of previous row variables
    @prev_user_id := user_id,
    @prev_streak_active := streak_active
  FROM
   user_streaks_sql  
  ORDER BY
    user_id, streak_created
);
Streak lengths are calculated based on whether the current user matches the previous one and if the user's streak is still active. If the conditions are met, the streak count increases; otherwise, it’s reset to 0.

Step 4: Identify the Top Performers:

Having identified the longest streak for each user, we can pull all streaks with length 30 or more. We will do so using the temporary table streaks_new with the help of the following code:

SELECT 
  user_id,
  MAX(streak_length) AS max_streak_length
FROM 
  streaks_new
GROUP BY 
  user_id
HAVING
	MAX(streak_length) >= 30
ORDER BY 
  max_streak_length DESC;
This command selects the user_id and the maximum streak length, groups the result by the individual IDs, then selects only the users who achieved a streak of 30 days or longer, and orders them in descending order.

end