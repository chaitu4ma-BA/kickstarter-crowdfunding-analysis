SELECT * FROM crowdfunding.projects;
SELECT 
    ProjectID,
    FROM_UNIXTIME(created_at) AS created_date,
    FROM_UNIXTIME(deadline) AS deadline_date
FROM projects;
select
ProjectID,
 FROM UNIXTIME (created at) as created_date;
 

ALTER TABLE projects
ADD created_date DATETIME,
ADD deadline_date DATETIME;
SET SQL_SAFE_UPDATES = 0;


UPDATE projects
SET
    created_date = FROM_UNIXTIME(created_at),
    deadline_date = FROM_UNIXTIME(deadline);
    
    select * from projects;
     use crowdfunding;
    show databases;
    drop  table if exists calender;
    
    CREATE TABLE `calendar` (
  cal_date DATE PRIMARY KEY,
  cal_year INT,
  month_no INT,
  month_fullname VARCHAR(20),
  cal_quarter VARCHAR(2),
     weekday_no INT,
  weekday_name VARCHAR(10),
  financial_month VARCHAR(4),
  financial_quarter VARCHAR(3)
);

INSERT INTO calendar (cal_date)
SELECT 
    DATE_ADD(
        (SELECT DATE(MIN(created_date)) FROM projects),
        INTERVAL seq DAY
    ) AS cal_date
FROM
(
    SELECT a.N + b.N*10 + c.N*100 AS seq
    FROM 
        (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
        (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
        (SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c
) AS numbers
WHERE DATE_ADD(
        (SELECT DATE(MIN(created_date)) FROM projects),
        INTERVAL seq DAY
    ) <= (SELECT DATE(MAX(created_date)) FROM projects);
    
    
INSERT IGNORE INTO calendar (cal_date)
SELECT DATE(created_date)
FROM projects;


    
    
   UPDATE calendar
SET
    cal_year = YEAR(cal_date),
    month_no = MONTH(cal_date),
    month_fullname = MONTHNAME(cal_date),
    cal_quarter =  CONCAT('Q', QUARTER(cal_date)),
          weekday_no = WEEKDAY(cal_date) + 1,
    weekday_name = DAYNAME(cal_date),
    financial_month = CASE
        WHEN MONTH(cal_date) = 4 THEN 'FM1'
        WHEN MONTH(cal_date) = 5 THEN 'FM2'
        WHEN MONTH(cal_date) = 6 THEN 'FM3'
        WHEN MONTH(cal_date) = 7 THEN 'FM4'
        WHEN MONTH(cal_date) = 8 THEN 'FM5'
        WHEN MONTH(cal_date) = 9 THEN 'FM6'
        WHEN MONTH(cal_date) = 10 THEN 'FM7'
        WHEN MONTH(cal_date) = 11 THEN 'FM8'
        WHEN MONTH(cal_date) = 12 THEN 'FM9'
        WHEN MONTH(cal_date) = 1 THEN 'FM10'
        WHEN MONTH(cal_date) = 2 THEN 'FM11'
        WHEN MONTH(cal_date) = 3 THEN 'FM12'
    END,
    financial_quarter = CASE
        WHEN MONTH(cal_date) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(cal_date) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(cal_date) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END;

show tables;
SELECT * FROM calendar
LIMIT 20;

Convert the Goal amount into USD using the Static USD Rate

ALTER TABLE projects
ADD COLUMN goal_usd DECIMAL(15,2);

SET SQL_SAFE_UPDATES = 0;




UPDATE projects
SET goal_usd = goal * static_usd_rate;

SELECT goal, goal_usd,static_usd_rate
FROM projects
LIMIT 50;


Total Number of Projects based on outcome


SELECT state, COUNT(*) AS total_projects
FROM projects
GROUP BY state
ORDER BY total_projects DESC;







Total Number of Projects based on Locations

SELECT country, COUNT(*) AS total_projects
FROM projects
GROUP BY country
ORDER BY total_projects DESC;


Total Number of Projects based on  Category
SELECT c.name AS category_name,
       COUNT(p.ProjectID) AS total_projects
FROM projects p
JOIN crowdfunding_category c 
      ON p.category_id = c.id
GROUP BY c.name
ORDER BY total_projects DESC;

Projects created by Year, Quarter, and Month

SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    COUNT(*) AS total_projects
FROM projects
GROUP BY YEAR(FROM_UNIXTIME(created_at))
ORDER BY year;

Projects created Quarter

SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    CONCAT('Q', QUARTER(FROM_UNIXTIME(created_at))) AS quarter,
    COUNT(*) AS total_projects
FROM projects
GROUP BY year, quarter
ORDER BY year, quarter;

Projects created month


SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    MONTH(FROM_UNIXTIME(created_at)) AS month_no,
    DATE_FORMAT(FROM_UNIXTIME(created_at), '%b') AS month_name,
    COUNT(*) AS total_projects
FROM projects
GROUP BY year, month_no, month_name
ORDER BY year, month_no;

Successful Projects Amount Raised 

SELECT 
    SUM(pledged) AS total_amount_raised
FROM projects
WHERE state = 'successful';

Successful Projects Amount Raised 
SELECT 
    CONCAT(ROUND(SUM(usd_pledged) / 1000000000, 2), ' B') AS total_amount_raised_billions$
FROM projects
WHERE state = 'successful';

successful projects based Number of Backers

SELECT CONCAT(ROUND(SUM(backers_count) /1000000, 2), 'M')as TOTAL_BACKERS_M
FROM projects
WHERE state ='successful';

SELECT 
    CONCAT(ROUND(SUM(backers_count) / 1000, 2), 'K') AS total_backers_K
FROM projects
WHERE state = 'successful';

successful projects based ON AVERGAGE DAYS


SELECT 
    AVG(DATEDIFF(deadline_date, created_date)) AS average_days
FROM projects
WHERE state = 'successful';


Top Successful Projects Based on Number of Backers-

SELECT 
name,
 backers_count  as total_count
from projects
where state ='successful'
order by backers_count DESC
LIMIT 10;

  Top Successful Projects Based on Amount Raised.
  
  select name, usd_pledged as AMOUNT_RAISED
  FROM PROJECTS
  WHERE state ='successful'
  order by usd_pledged DESC
  LIMIT 10;

Percentage of Successful Projects overall-

SELECT 
    ROUND(
        (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100, 2
    ) AS success_percentage
FROM projects;


Percentage of Successful Projects  by Category
SELECT 
    c.name AS category_name,
    COUNT(p.ProjectID) AS total_projects,
    SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(
        (SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) 
        / COUNT(p.ProjectID)) * 100, 2
    ) AS success_percentage
FROM projects p
JOIN crowdfunding_category c
      ON p.category_id = c.id
GROUP BY c.name
ORDER BY success_percentage DESC
LIMIT 10;

Percentage of Successful Projects by Year 
SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    COUNT(ProjectID) AS total_projects,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(
        (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) 
        / COUNT(ProjectID)) * 100, 2
    ) AS success_percentage
FROM projects
GROUP BY year
ORDER BY year;

Percentage of Successful Projects by  Month etc..
SELECT 
    YEAR(FROM_UNIXTIME(created_at)) AS year,
    MONTH(FROM_UNIXTIME(created_at)) AS month_no,
    DATE_FORMAT(FROM_UNIXTIME(created_at), '%b') AS month_name,
    COUNT(ProjectID) AS total_projects,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(
        (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) 
        / COUNT(ProjectID)) * 100, 2
    ) AS success_percentage
FROM projects
GROUP BY year, month_no, month_name
ORDER BY year, month_no;

percentage of successful projects in each goal range.

SELECT 
    CASE
        WHEN goal BETWEEN 0 AND 1000 THEN '0 - 1K'
        WHEN goal BETWEEN 1001 AND 5000 THEN '1K - 5K'
        WHEN goal BETWEEN 5001 AND 10000 THEN '5K - 10K'
        WHEN goal BETWEEN 10001 AND 25000 THEN '10K - 25K'
        WHEN goal BETWEEN 25001 AND 50000 THEN '25K - 50K'
        WHEN goal BETWEEN 50001 AND 100000 THEN '50K - 1L'
        WHEN goal BETWEEN 100001 AND 500000 THEN '1L - 5L'
        ELSE 'Above 5L'
    END AS goal_range,
    COUNT(ProjectID) AS total_projects,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(
        (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) 
        / COUNT(ProjectID)) * 100, 2
    ) AS success_percentage
FROM projects
GROUP BY goal_range
ORDER BY MIN(goal);





