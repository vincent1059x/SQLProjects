USE GoogleDataAnalyticProject

--selecting distinct ids to find number of unique participants with daily activity data
SELECT DISTINCT id
FROM dailyActivity_merged
--33 unique ids reported in dailyActivity_merged table

--selecting distinct ids in sleepday_merged table
SELECT DISTINCT id
FROM sleepDay_merged
--24 distinct ids in sleepday_merged table

--selecting distinct ids in weightLogInfo_merged table
SELECT DISTINCT id
FROM weightLogInfo_merged
--8 distinct ids in weightLogInfo_merged table

--finding start and end date of data tracked in dailyActivity_merged table
SELECT MIN(ActivityDate) AS StartDate, MAX(ActivityDate) AS EndDate
FROM dailyActivity_merged
--notice that start date 2016-4-12, end date 2016-5-12

--finding start and end date of data tracked in sleepday_merged table
SELECT MIN(SleepDay) AS StartDate, MAX(SleepDay) AS EndDate
FROM sleepday_merged
--notice that start date 2016-4-12, end date 2016-5-12

--finding start and end date of data tracked in weightLogInfo_merged table
SELECT MIN(date) AS StartDate, MAX(Date) AS EndDate
FROM weightLogInfo_merged
--notice that start date 2016-4-12, end date 2016-5-12

--Finding duplicate rows, if any, in dailyActivity_merged table
SELECT 	id, activitydate, count(*) AS numRow
FROM 	dailyActivity_merged
GROUP BY id, ActivityDate
HAVING count(*) > 1
--No duplicate rows in the dailyActivity_merged table

--Finding duplicate rows, if any, in sleepday_merged table
SELECT 	*, count(*) AS numRow
FROM 	sleepDay_merged
GROUP BY id, SleepDay, TotalMinutesAsleep, TotalSleepRecords, TotalTimeInBed
HAVING count(*) > 1
--3 duplicate rows returned

--Creating new SleepLog table with all distinct values
SELECT DISTINCT * INTO SleepLog2 FROM sleepDay_merged

--Double checking new table no longer has duplicate rows
SELECT *, COUNT(*) AS numRow
FROM SleepLog2
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING COUNT(*) > 1
--0 duplicate rows returned in new table; duplicate rows delete

--Dropping origional SleepLog table, just remaining the new one
DROP TABLE sleepDay_merged

--Finding duplicate rows, if any, in weightLogInfo_merged table
SELECT *, COUNT(*) AS numRow
FROM weightLogInfo_merged
GROUP BY Id, Date, WeightKg, WeightPounds, Fat, BMI, IsManualReport, LogId
HAVING COUNT(*) > 1
-- 0 duplicate rows returned

--To make the column easier to understand, converting bit values in IsManualReport to varchar "true" and "false"
ALTER TABLE weightLogInfo_merged
ALTER COLUMN IsManualReport varchar(255)

UPDATE weightLogInfo_merged
SET IsManualReport = 'True'
WHERE IsManualReport = '1'

UPDATE weightLogInfo_merged
SET IsManualReport = 'False'
WHERE IsManualReport = '0'

--Double checking that ids in DailyActivity have the same number of characters
SELECT LEN(CAST(Id AS bigint))
FROM dailyActivity_merged

SELECT id
FROM dailyActivity_merged
WHERE LEN(CAST(Id AS bigint)) > 10 OR LEN(CAST(Id AS bigint)) < 10
--all ids have the same length - 10 characters

--Looking for IDs in WeightLog table with more or less than 10 characters
SELECT Id
FROM weightLogInfo_merged
WHERE LEN(CAST(Id AS bigint)) > 10 OR LEN(CAST(Id as bigint)) < 10
--all ids have the same length - 10 characters

--Looking at LogIDs in WeightLog table to determine if they are its primary key
SELECT LogId, COUNT(LogId) AS NumOfLogIds
FROM weightLogInfo_merged
GROUP BY LogId
HAVING COUNT(LogId) > 1
ORDER BY LogId DESC
--Ten LogIds with a count greater than 1, suggesting there are duplicates or that the LogId column doesnot contain the primary key to this table
--Looking at records with matching LogIds to see if they are duplicates
SELECT *
FROM weightLogInfo_merged
WHERE LogId IN (
		SELECT LogId
		FROM weightLogInfo_merged
		GROUP BY LogId
		HAVING COUNT(LogId) > 1)
ORDER BY LogId
--Matching LogIds occur on the same Date but don't have anything else in common

--Examining records with 0 in TotalSteps colum of DailyActivity table
SELECT id, COUNT(*) AS NumZeroStepsDays
FROM dailyActivity_merged
WHERE TotalSteps = 0
GROUP BY Id
ORDER BY NumZeroStepsDays DESC

--Examining total records with 0
SELECT SUM(NumZeroStepsDays) AS TotalRecords
FROM (
		SELECT COUNT(*) AS NumZeroStepsDays
		FROM dailyActivity_merged
		WHERE TotalSteps = 0) AS z
--77 records with 0 step

--Looking at all attributes of each zero-step day
SELECT *, ROUND(sedentaryminutes/60, 2) AS SedentaryHours
FROM dailyActivity_merged
WHERE TotalSteps = 0
--While technically possible that these records reflect days that users were wholly inactive 
--(most records returned in the above query claim 24 total hours of sedentary activity), 
--they're more likely reflective of days the users didn't wear their FitBits, making the records potentially misleading
--So we should delete rows where totalsteps = 0

DELETE FROM dailyActivity_merged
WHERE TotalSteps = 0

--VISUALIZING ON QUERIES
--selecting dates and corresponding days of the week to indentify weekdays and weekends
SELECT ActivityDate, DATENAME(dw, ActivityDate) AS DayOfWeek
FROM dailyActivity_merged

SELECT ActivityDate,
		CASE 
			WHEN DayOfWeek = 'Monday' THEN 'Weekday'
			WHEN DayOfWeek = 'Tuesday' THEN 'Weekday'
			WHEN DayOfWeek = 'Wednesday' THEN 'Weekday'
			WHEN DayOfWeek = 'Thursday' THEN 'Weekday'
			WHEN DayOfWeek = 'Friday' THEN 'Weekday'
			ELSE 'Weekend'
		END AS PartOfWeek
FROM (SELECT *, DATENAME(dw, ActivityDate) AS DayOfWeek FROM dailyActivity_merged) AS temp

--Looking at average steps, distance and calories on weekdays vs. weekends
SELECT PartOfWeek, ROUND(AVG(CAST(TotalSteps AS float)),0) AS AverageSteps, ROUND(AVG(CAST(TotalDistance AS float)),0) AS AverageDistance, ROUND(AVG(CAST(Calories AS float)),0) AS AverageCalories
FROM
	(SELECT *, CASE
					WHEN DayOfWeek = 'Monday' THEN 'Weekday'
					WHEN DayOfWeek = 'Tuesday' THEN 'Weekday'
					WHEN DayOfWeek = 'Wednesday' THEN 'Weekday'
					WHEN DayOfWeek = 'Thursday' THEN 'Weekday'
					WHEN DayOfWeek = 'Friday' THEN 'Weekday'
					ELSE 'Weekend'
				END AS PartOfWeek
	FROM (SELECT *, DATENAME(dw, ActivityDate) AS DayOfWeek FROM dailyActivity_merged) AS temp1) AS temp2
GROUP BY PartOfWeek

--Looking at average steps, distance, calories per day of the week
SELECT	DayOfWeek, 
		ROUND(AVG(CAST(TotalSteps AS float)),0) AS AverageSteps, 
		ROUND(AVG(CAST(TotalDistance AS float)),0) AS AverageDistance, 
		ROUND(AVG(CAST(Calories AS float)),0) AS AverageCalories
FROM (SELECT *, DATENAME(dw, ActivityDate) AS DayOfWeek FROM dailyActivity_merged) AS temp1
GROUP BY DayOfWeek
ORDER BY AverageSteps DESC

--Looking at average ammount of time spent asleep and average time to fall asleep per day of the week
SELECT *
FROM(
	SELECT	DayOfWeek, 
		ROUND(AVG(CAST(TotalMinutesAsleep AS float)),0) AS AverageMinAsleep, 
		ROUND(AVG(CAST(TotalMinutesAsleep/60 AS float)),0) AS AverageHourAsleep, 
		ROUND(AVG((CAST(TotalTimeInBed AS float)) - CAST(TotalMinutesAsleep AS float)),0) AS AverageMinToFallAsleep
	FROM (SELECT *, DATENAME(dw, SleepDay) AS DayOfWeek FROM SleepLog2) AS temp1
	GROUP BY DayOfWeek) AS temp3
ORDER BY AverageHourAsleep DESC

--Left joining all 3 tables
SELECT *
FROM dailyActivity_merged AS d 
	LEFT JOIN SleepLog2 AS s
	ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
		LEFT JOIN weightLogInfo_merged AS w
		ON s.SleepDay = w.Date AND s.Id = w.Id
ORDER BY d.Id, Date

--Finding unique participants in the DailyActivity who do not have records in either the SleepLog or WeightLog tables (or both)

SELECT DISTINCT id
FROM dailyActivity_merged
WHERE Id NOT IN (SELECT d.Id FROM dailyActivity_merged d
							 JOIN SleepLog2 s
							 ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
							 JOIN weightLogInfo_merged w
							 ON s.SleepDay = w.Date AND s.Id = w.Id)
--33 participants in the DailyActivity table, do not have records in either the SleepLog or WeightLog tables (or both)

--Looking at calories and active minutes
SELECT Id, ActivityDate, Calories, SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes
FROM dailyActivity_merged
;

--Looking at calories and active distances
SELECT Id, ActivityDate, Calories, SedentaryActiveDistance, LightActiveDistance, ModeratelyActiveDistance, VeryActiveDistance, TotalDistance
FROM dailyActivity_merged
;

--Looking at calories and total steps
SELECT Id, ActivityDate, Calories, TotalSteps
FROM dailyActivity_merged
;

--Looking at calories and total minutes asleep
SELECT d.Id, d.ActivityDate, Calories, TotalMinutesAsleep
FROM dailyActivity_merged AS d 
	INNER JOIN SleepLog2 AS s 
	ON d.Id = s.Id AND d.ActivityDate = s.SleepDay

--Looking at calories and total minutes & hours asleep from day before
SELECT d.Id, d.ActivityDate, Calories, TotalMinutesAsleep,
			LAG(TotalMinutesAsleep, 1) OVER (ORDER BY d.Id, d.ActivityDate) AS MinutesSleptDayBefore,
			LAG(TotalMinutesAsleep, 1) OVER (ORDER BY d.Id, d.ActivityDate) / 60 AS HoursSleptDayBefore
FROM dailyActivity_merged AS d 
	INNER JOIN SleepLog2 AS s 
	ON d.Id = s.Id AND d.ActivityDate = s.SleepDay

--Looking at number of days where total steps is equal to or greater than the CDC-recommended amount of 10,000

SELECT DayOfWeek, COUNT(*) AS NumDays
FROM (SELECT *, DATENAME(dw, ActivityDate) AS DayOfWeek FROM dailyActivity_merged) AS temp1
WHERE TotalSteps >= 10000	
GROUP BY DayOfWeek

--Looking at number of days where users got the CDC-recommended amount of sleep (7-9 hours a night)

SELECT DayOfWeek, COUNT(*) AS NumDays
FROM (SELECT DATENAME(dw, ActivityDate) AS DayOfWeek
		FROM dailyActivity_merged AS d 
			JOIN SleepLog2 AS s
			ON d.Id = s.Id AND d.ActivityDate = s.SleepDay
		WHERE TotalMinutesAsleep >= 420 AND TotalMinutesAsleep <= 540) AS Temp5
GROUP BY DayOfWeek
ORDER BY NumDays
