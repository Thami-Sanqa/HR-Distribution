CREATE DATABASE sqlpowerbi;

USE sqlpowerbi;

---- Cleaning the data----

---- Changing column name ----

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

SELECT * FROM hr;

---- Checking data types ----

DESCRIBE hr;

SET sql_safe_updates = 0;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT birthdate FROM hr;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;
    
SELECT hire_date FROM hr;
    
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

ALTER TABLE hr
RENAME COLUMN location_state TO state;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SELECT termdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*)
	FROM hr
    Where age < 18;
    
---- Questions to answer for Analysis ----

-- 1. What is the Gender breakdown of employees in the company?

SELECT gender, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY gender;


-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY race
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company?

SELECT
	min(age) AS youngest,
    max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate = '';

SELECT
	CASE
		WHEN age >= 18 AND age <= 29 THEN '18-29'
        WHEN age >= 30 AND age <= 39 THEN '30-39'
        WHEN age >= 40 AND age <= 49 THEN '40-49'
        WHEN age >= 50 AND age <= 59 THEN '50-59'
        ELSE '60+'
END AS age_group,
count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY age_group
ORDER BY age_group;

SELECT
	CASE
		WHEN age >= 18 AND age <= 29 THEN '18-29'
        WHEN age >= 30 AND age <= 39 THEN '30-39'
        WHEN age >= 40 AND age <= 49 THEN '40-49'
        WHEN age >= 50 AND age <= 59 THEN '50-59'
        ELSE '60+'
END AS age_group, gender,
count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?

SELECT location, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the avergae length of employment for employees who have been terminated?

SELECT
	round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate<> '' AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department, gender, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of the job titles across the company?

SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnaover rate?

SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;
    
-- 9. What is the distribution of employees across locations by city and state?

SELECT location_city, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_city
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100, 2) AS net_change_percent
FROM(
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    Group BY YEAR(hire_date)
    ) AS subquery
ORDER BY year ASC;  

-- 11. What is the tenure distribution for each department?

Select department, round(avg( datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;






