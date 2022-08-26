-- create new database
CREATE DATABASE foodsec;

-- import datasets via the sql server import and export data app

-- exploring our 4 datasets
SELECT *
FROM foodsec..nigeria;
SELECT *
FROM foodsec..africalist;
SELECT *
FROM foodsec..africatotal;
SELECT *
FROM foodsec..worldlist;

-- delete column "F5" from africalist table
ALTER TABLE foodsec..africalist
DROP COLUMN F5;

-- analysis

-- total number of undernourished people in africa (2021)
SELECT Item, SUM(Value) AS Sum_Undernourished_Africa
FROM foodsec..africatotal
WHERE Item_code = 210010 
		AND Year = '2021'
GROUP BY Item;

-- total number of undernourished people in africa by year
SELECT Item, Value, Year
FROM foodsec..africatotal
WHERE Item_code = 210010
GROUP BY Value, Item, Year
ORDER BY 2 DESC;

-- total % of prevalence of undernourishment in africa by year
SELECT Item, Value, Year
FROM foodsec..africatotal
WHERE Item_code = 210040
GROUP BY Value, Item, Year
ORDER BY 2 DESC;

-- countries with the highest number of undernourished people in africa(3-year average). 
SELECT Area, Item, Year, Value,
MAX(Value) OVER(PARTITION BY Year) AS Max_value
FROM foodsec..africalist
WHERE Item_code = 210011 
		AND Year = '2019-2021'
GROUP BY Area, Item, Year, Value
ORDER BY 4 DESC, 3;

--most undernourished countries in the World (Most recent 3-year average)
SELECT w.Area, MAX(w.Value) AS Max_undernourished 
FROM foodsec..worldlist AS w
LEFT JOIN foodsec..africalist AS a
ON w.Area = a.Area
WHERE w.Item_code = 210011 
		AND w.Year = '2019-2021'
GROUP BY w.Area
ORDER BY 2 DESC;

-- sum of severely food insecure people in Nigeria, Africa and the World (2019 - 2021)
SELECT Item, SUM(Value) AS Sum_SFIP_Nig
FROM foodsec..nigeria
WHERE Item_code = 210071 
		AND Year = '2019-2021'
GROUP BY Item;

SELECT Item, SUM(Value) AS Sum_SFIP_Af
FROM foodsec..africatotal
WHERE Item_code = 210071 
		AND Year = '2019-2021'
GROUP BY Item;

SELECT Item, SUM(Value) AS Sum_SFIP_W
FROM foodsec..worldlist
WHERE Item_code = 210071 
		AND Year = '2019-2021'
GROUP BY Item;

--yearly progression of food insecure people in nigeria
SELECT Year, Value
FROM foodsec..nigeria
WHERE Item_code = 210071 
GROUP BY Year, Value
ORDER BY 1 DESC;

-- countries with the highest number of severely food insecure people (sfip) in Africa and World (3-year averages from 2014-2021)
SELECT Area, MAX(Value) AS MSFIP_Af, Year,
RANK() OVER(PARTITION BY Year ORDER BY MAX(Value) DESC) AS Rank
FROM foodsec..africalist
WHERE Item_code = 210071 
GROUP BY Area, Year
ORDER BY 2 DESC;

-- individual average numbers of sfip in countries in africa (average from 2014-2021)
SELECT Area, ROUND(AVG(Value), 2) AS country_avg
FROM foodsec..africalist
WHERE Item_code = 210071 
		AND Value IS NOT NULL			
GROUP BY Area
ORDER BY 2 DESC;

-- total average number of sfip in africa (2014-2021)
SELECT ROUND(AVG(Value), 2) AS africa_avg
FROM foodsec..africalist
WHERE Item_code = 210071 
		AND Value IS NOT NULL; 

-- countries in africa with number of sfip higher than world average
SELECT Area, ROUND(AVG(Value), 2) AS more_than_africaavg
FROM foodsec..africalist
GROUP BY Area
HAVING AVG(Value) >
(SELECT ROUND(AVG(Value), 2) AS africa_avg
FROM foodsec..africalist
WHERE Item_code = 210071 
		AND Value IS NOT NULL)
ORDER BY 2 DESC;

-- count of countries above
WITH list AS (
	SELECT Area, ROUND(AVG(Value), 2) AS more_than_africaavg
FROM foodsec..africalist
GROUP BY Area
HAVING AVG(Value) > 
	(SELECT ROUND(AVG(Value), 2) AS africa_avg
FROM foodsec..africalist
WHERE Item_code = 210071 
		AND Value IS NOT NULL)
)
	SELECT COUNT(*) AS Count
	FROM list;


-- end
