CREATE DATABASE SQL_User_Analysis;
USE SQL_User_Analysis;

-- Creating Table for Upcoming Data 
CREATE TABLE User_Submissions (
	id SERIAL PRIMARY KEY, 
    user_id BIGINT, 
    question_id INT, 
    points INT, 
	submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    username VARCHAR(50)
);
SELECT * FROM User_Submissions;

-- Question One: List all distincts users and their stats (return user_name, total submissions, and points earned)

SELECT 
	-- COUNT(DISTINCT username) Query for the number of distinct users
    DISTINCT username,
    COUNT(id) as total_submissions,
    SUM(points) as points_earned 
FROM User_Submissions
GROUP BY username
ORDER BY points_earned DESC;

-- Questions Two: Calculate the daily average points for each user. 

SELECT 
	-- EXTRACT(DAY FROM submitted_at) as _day, #Gives information about daily points 
    DATE_FORMAT(submitted_at, '%d-%m') AS Daily,
    username,
    AVG(points) as avg_daily
 FROM User_Submissions
 GROUP BY Daily, username
 ORDER BY username ASC;
 
-- Question Three: Find the top three users with the top most correct submissions for each day

WITH daily_submissions 
AS
	(SELECT 
	-- EXTRACT(DAY FROM submitted_at) as _day, #Gives information about daily points 
    DATE_FORMAT(submitted_at, '%d-%m') AS Daily,
    username,
    AVG(points) as avg_daily, 
    
     SUM(CASE WHEN points > 0 THEN 1 
    ELSE 0 
    END) AS Correct_Submission 

 FROM User_Submissions
 GROUP BY Daily, username), 
 
 Users_Rank AS
 (SELECT Daily, username, Correct_Submission,
	DENSE_RANK() OVER(PARTITION BY Daily ORDER BY Correct_Submission DESC) AS rrank
 FROM daily_submissions)
 
 SELECT Daily, username, Correct_Submission
 FROM Users_Rank
 WHERE rrank<=3;
 
 -- Question Four : Find top users with the highest number of incorrect submissions. 
 
 SELECT username, 
 SUM(CASE WHEN points < 0 THEN 1
 ELSE 0
 END) AS Incorrect_Submission
 
 FROM User_Submissions 
 GROUP BY username
 ORDER BY Incorrect_Submission DESC
 LIMIT 5;

-- Question Five: Find the top ten performers for each week 
SELECT * 
FROM
(SELECT username, 
	WEEK(submitted_at) AS Weekly,
	SUM(points) AS points_earned,
    DENSE_RANK() OVER(PARTITION BY WEEK(submitted_at)  ORDER BY SUM(points) DESC) AS rrank
FROM User_Submissions
GROUP BY username, WEEK(submitted_at)) 
AS sub_query
WHERE rrank <= 10
ORDER BY Weekly, points_earned DESC;

 
 