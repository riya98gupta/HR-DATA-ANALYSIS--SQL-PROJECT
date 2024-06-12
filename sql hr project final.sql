SELECT * FROM hrproject.hr_data;
SELECT * FROM hr_data;
/*
1. Fix the Gender 
2. Fix DataScientist, Marketinganalyst
3. Create a group +-30
4. Create a SalaryBucket 50-60, etc. 
5. Date column
*/
SELECT Years_Of_Service, count(*) FROM hr_data GROUP BY Years_Of_Service;

SELECT MIN(Age), MAX(Age) FROM hr_data;

SELECT DISTINCT(Performance_Rating) FROM hr_data;


/*
1. we check the year of service and promotions given, if promotion is not given and satisfaction score is less, we can check if this is the reason for leaving the job
2. can we check year of service and performance over the year of employement
3. Department, Position, Gender, Salary x Attrition (yes/no)
4. training hours against promotion , to infer what is the optimum training hours
5. what the satisfaction score of that dept and number of service an emp is giving in that dept
6. Compare performance ratings and satisfaction score
7. which team high satisfaction score and attrition in each teams
8. how many employess left the company and there performance rating and the years in the company
9. work hours and satisfaction score can be check along with the department if the working hours are more for a particular department, and then check the attrition rate
10. we can check those are leaving the company have been seen promotion or not
11. Curr() - yearsofservice = 

1. Fix the Gender 
2. Fix DataScientist, Marketinganalyst
3. Create a group +-30
4. Create a SalaryBucket 50-60, etc. 
5. Date column
*/

-- 

DROP TABLE IF EXISTS hr_database;

CREATE TABLE hr_database AS 
SELECT
	Employee_ID,
    Age,
    CASE
		WHEN Age <= 30 THEN '<= 30 years'
        ELSE '> 30 years'
        END AS AgeGroup,
	REPLACE(REPLACE(GENDER, 'Female', 'F'), 'Male', 'M') AS Gender,
    Department,
	REPLACE(REPLACE(Position, 'DataScientist', 'Data Scientist'), 'Marketinganalyst', 'Marketing Analyst') AS Position,
    Years_Of_Service,
    Salary,
    CASE 
		WHEN Salary >= 90000 THEN '90K - 100K'
		WHEN Salary >= 80000 THEN '80K - 90K'
        WHEN Salary >= 70000 THEN '70K - 80K'
        WHEN Salary >= 60000 THEN '60K - 70K'
        ELSE '50K - 60K'
        END AS SalaryBucket,
        Performance_Rating,
        Work_Hours,
        Attrition,
        Promotion,
        Training_Hours,
        Satisfaction_Score,
        Last_Promotion_Date
FROM hr_data;

-- Problem Statement 1: "Identify Factors Influencing Employee Attrition"
-- 1) Stats
SELECT 
    COUNT(*) AS Total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count,
    ROUND((SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS Attrition_Count,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS Total_Active_employees,
    ROUND(AVG(Age),0) AS AvgAge,
    ROUND(AVG(Years_Of_Service),0) AS Avg_Years_Of_Service,
    ROUND(AVG(Salary),0) AS Avg_Salary,
    ROUND(AVG(Satisfaction_Score),0) AS Avg_Satisfaction_Score,
    ROUND(AVG(Work_Hours),0) AS Avg_Work_Hours,
    ROUND(AVG(Training_Hours),0) AS Avg_Training_Hours
FROM hr_database
WHERE Attrition = 'Yes';
/*
Attrition rate is 33.75%.
Avg Age is 31 years
Avg Time Spend is 5 years
Avg Salary is ~67K
Avg Satisfaction Score is 4
Avg Work Hours is 41

--Insight
Avg Working Hours for people who left the company was higher than the total average 
as well folks who are still working in the company.

Less training was provided compared to the average that's why they left.
*/

-- gender distribution
SELECT Gender,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Yes,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS Attrition_No
FROM hr_database
GROUP BY Gender;

-- DEPARTMENT
SELECT
	Department,
    COUNT(*) AS Total_Emp,
    ROUND(AVG(Salary),0) AS Avg_Salary,
    ROUND(AVG(Satisfaction_Score),0) AS Avg_Satisfaction_Score,
    ROUND(AVG(Work_Hours),0) AS AvgWorkHours,
    ROUND(AVG(Training_Hours),0) AS AvgTraining_Hours
FROM hr_database
WHERE Attrition = 'Yes'
GROUP BY Department;

SELECT Department, Attrition, Training_Hours, COUNT(*)
FROM hr_database
WHERE Department = 'HR'
GROUP BY Department, Training_Hours, Attrition;

-- POSITION
SELECT
	Position,
    COUNT(*) AS Total_Emp,
    ROUND(AVG(Salary),0) AS Avg_Salary,
    MIN(Salary) as Min_Sal,
    MAX(Salary) as Max_Sal,
    ROUND(AVG(Satisfaction_Score),0) AS Avg_Satisfaction_Score,
    ROUND(AVG(Work_Hours),0) AS Avg_Work_Hours,
    ROUND(AVG(Training_Hours),0) AS Avg_Training_Hours,
    ROUND(AVG(Years_Of_Service),0) AS Avg_Years_Of_Service,
	SUM(CASE WHEN Promotion = 'Yes' THEN 1 ELSE 0 END) AS Promotion_Yes,
    ROUND(AVG(Performance_Rating),0) AS Avg_Performance_Rating
FROM hr_database
WHERE Attrition = 'Yes'
GROUP BY Position;

SELECT 
	Years_Of_Service, Attrition,
    SUM(CASE WHEN Promotion = 'Yes' THEN 1 ELSE 0 END) AS Promoted,
    SUM(CASE WHEN Promotion = 'No' THEN 1 ELSE 0 END) AS Not_Promoted
FROM hr_database
GROUP BY Years_Of_Service, Attrition
ORDER BY Years_Of_Service, Attrition;

/*
Data Scientist 
HR Coordinator
Marketing Analyst
*/




/*
create table newdatacol as 
SELECT LastPromotionDate, NEWDATE 
FROM 
(SELECT
LastPromotionDate,
        DATE_FORMAT(STR_TO_DATE(LastPromotionDate, '%d-%m-%Y'),'%Y-%m-%d') AS NEWDATE
FROM hrdata) a
WHERE NEWDATE IS NOT NULL

UNION ALL

SELECT LastPromotionDate, IFNULL(NEWDATE, LastPromotionDate)
FROM 
(SELECT
LastPromotionDate,
        DATE_FORMAT(STR_TO_DATE(LastPromotionDate, '%d-%m-%Y'),'%Y-%m-%d') AS NEWDATE
FROM hrdata) a
WHERE NEWDATE IS NULL
;

SELECT
Last_Promotion_Date,
        DATE_FORMAT(STR_TO_DATE(Last_Promotion_Date, '%d-%m-%Y'),'%Y-%m-%d') AS NEW_DATE
FROM hr_data;
	
SELECT
Last_Promotion_Date,
COALESCE(Date_FORMAT(STR_TO_DATE(Last_Promotion_Date,'%d-%m-%Y'),'%Y-%m-%d'),Last_Promotion_Date)
FROM hr_data;

SELECT
Date_FORMAT(COALESCE(Date_FORMAT(STR_TO_DATE(Last_Promotion_Date,'%d-%m-%Y'),'%Y-%m-%d'),Last_Promotion_Date),'%Y-%m-%d') AS Updated_Last_Promotion_Date
from hr_data;

create table dummy_date as
SELECT
Last_Promotion_Date,
COALESCE(Date_FORMAT(STR_TO_DATE(Last_Promotion_Date,'%d-%m-%Y'),'%Y-%m-%d'),Last_Promotion_Date)
FROM hr_data;
*/

