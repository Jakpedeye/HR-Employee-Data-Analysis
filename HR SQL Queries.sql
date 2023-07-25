CREATE DATABASE hr_project;

use hr_project;

select * from Human_Resources;

describe Human_Resources;

##--Correct the employee id column name --

alter table Human_Resources
change column ï»¿id employee_id varchar(20) null;

## change the date format and data type of birthdate column

set sql_safe_updates = 0;
update Human_Resources
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
	ELSE NULL
END;

Alter Table human_resources
Modify column birthdate date;

## change the date format and data type of hire_date column
update Human_Resources
SET hire_date = CASE
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
	ELSE NULL
END;

Alter Table Human_Resources
Modify Column hire_date Date;

select * from human_resources;

## Change data type and date format of termdate column
Update Human_Resources
Set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
Where termdate Is Not Null and termdate != '';

Update Human_Resources
Set termdate = Null
where termdate ='';

##Create new column - age
Alter Table Human_Resources
Add Column age Int;

Update Human_Resources
Set age = timestampdiff(YEAR, birthdate, curdate());


##Exploratory data analysis
-- Racial distribution of current employee
select race, Count(*) as count
From Human_Resources
Where termdate Is Null
Group By race;

-- Gender distribution of current employees
Select gender, count(*) as count
From Human_Resources
Where termdate Is Null
Group By Gender;

-- Age distribution of current employees
SELECT 
  MIN(age) AS youngest,
  MAX(age) AS oldest
FROM Human_Resources
WHERE age >= 18;

SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender,
  COUNT(*) AS count
FROM Human_Resources
WHERE age >= 18 and termdate Is Null
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- Location of employees
Select location, Count(*) as count
From Human_Resources
Where age >= 18 and termdate Is Null
Group By Location;

-- Average length of employment in age of terminated employees in the company
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_employment_length
FROM Human_Resources
WHERE termdate Is Not Null AND termdate <= CURDATE() AND age >= 18;

-- Gender distribution across department
SELECT department, gender, COUNT(*) as count
FROM Human_Resources
WHERE age >= 18 and termdate Is Null
GROUP BY department, gender
ORDER BY department;

-- Job title distribution
Select jobtitle, Count(*) as count
From Human_Resources
Where age >= 18 and termdate is Null
Group By jobtitle
Order By count DESC;

-- Turnover rate
SELECT department, COUNT(*) as total_count, 
    SUM(CASE WHEN termdate <= CURDATE() AND termdate Is Not Null THEN 1 ELSE 0 END) as terminated_count, 
    SUM(CASE WHEN termdate Is Null THEN 1 ELSE 0 END) as active_count,
    (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) as turnover_rate
FROM Human_Resources
WHERE age >= 18
GROUP BY department
ORDER BY turnover_rate DESC;

-- Count of employee by state
Select location_state, Count(*) as count
From Human_Resources
Where age >= 18 and termdate Is Null
Group By location_state
Order By count Desc;

-- Net percentage change of employees
Select 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    Round(((hires - terminations) / hires * 100), 2) AS net_change_percent
From (
    Select
        YEAR(hire_date) As year, 
        Count(*) As hires, 
        SUM(Case When termdate is Not Null And termdate <= CURDATE() Then 1 Else 0 End) As terminations
    From Human_Resources
    Where age >= 18
    Group By YEAR(hire_date)) subquery
Order By year ASC;

-- Employee duration in company before leaving
Select department, ROUND(Avg(Datediff(Curdate(), termdate)/365),0) as avg_tenure
From Human_Resources
Where termdate <= Curdate() And termdate Is Not Null And age >= 18
Group By department;

