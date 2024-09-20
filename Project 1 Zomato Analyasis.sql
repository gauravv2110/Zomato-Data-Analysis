-- Project 1 Zomato Data Analysis

-- In this Zomato data analysis project, we aim to explore and 
-- derive insights from a dataset comprising restaurant information, 
-- including details such as location, cuisine, pricing, 
-- and customer reviews. We will examine factors influencing 
-- restaurant popularity, assess the relationship between 
-- price and customer ratings, and investigate the prevalence 
-- of services like online delivery and table booking. 
--  The project seeks to provide valuable insights into the restaurant 
--  industry and enhance decision-making for both customers and 
--  restaurateurs

-- task 1 >> import data


-- NOTE >> only CSV or JSON files can be importes in SQL

CREATE DATABASE zomato_analysis;
USE zomato_analysis;


--  Description of the dataset:

-- RestaurantID: A unique identifier for each restaurant in the dataset.

-- RestaurantName: The name of the restaurant.

-- CountryCode: A code indicating the country where the restaurant 
-- is located.

-- City: The city in which the restaurant is situated.

-- Address: The specific address of the restaurant.

-- Locality: The locality (neighborhood or district) where the restaurant 
-- is located.

-- LocalityVerbose: A more detailed description or name of the locality.

-- Longitude: The geographical longitude coordinate of the restaurant's 
-- location.

-- Latitude: The geographical latitude coordinate of the restaurant's 
-- location.

-- Cuisines: The types of cuisines or food offerings available at the 
-- restaurant. This may include multiple cuisines separated by commas.

-- Currency: The currency used for pricing in the restaurant.

-- Has_Table_booking: A binary indicator (0 or 1) that shows whether 
-- the restaurant offers table booking.

-- Has_Online_delivery: A binary indicator (0 or 1) that shows 
-- whether the restaurant provides online delivery services.

-- Is_delivering_now: A binary indicator (0 or 1) that indicates 
-- whether the restaurant is currently delivering food.

-- Switch_to_order_menu: A field that might suggest whether customers 
-- can switch to an online menu to place orders.

-- Price_range: A rating or category that indicates the price 
-- range of the restaurant's offerings (e.g., low, medium, high).

-- Votes: The number of votes or reviews that the restaurant has received.

-- Average_Cost_for_two: The average cost for two people to dine 
-- at the restaurant, often used as a measure of affordability.

-- Rating: The rating of the restaurant, possibly on a scale 
-- from 0 to 5 or a similar rating system.

-- Datekey_Opening: The date or key representing the restaurant's 
-- opening date.


SHOW tables;

-- DESCRIBE both tables to understand them >>

DESC rest_data;
DESC country_data;


SELECT * FROM rest_data;
SELECT * FROM country_data;


-- task 2 >> DATA CLEANING >>

-- 2.1) country_data table >> convert column name "country name" to "country_name"

-- every time we have to write column name like this as shown below
-- which is very uncomfortable so rename column name

SELECT `country name` FROM country_data; 

ALTER TABLE country_data
RENAME COLUMN `country name` TO country_name;

SELECT country_name FROM country_data;

DESC country_data;


-- 2.2) datekey_opening >> contains date but have datatype as TEXT
-- convert the column to DATE and replace value format from
-- "2019_05_29" to 2019/05/29

 SELECT datekey_opening FROM rest_data;
 SET SQL_SAFE_UPDATES = 0; -- to update whole column values without WHERE clause
 
UPDATE rest_data SET datekey_opening = replace(datekey_opening,'-','/') ;
SELECT datekey_opening FROM rest_data;
  
 ALTER TABLE rest_data
 MODIFY COLUMN datekey_opening DATE; -- changed datatype from TEXT from DATE

 
 SET SQL_SAFE_UPDATES = 1;
 
 
 
 -- task 3 >> check unique values from categorical columns
 
SELECT DISTINCT countrycode FROM rest_data;
SELECT DISTINCT has_online_delivery FROM rest_data; 
SELECT DISTINCT has_table_booking FROM rest_data;
SELECT DISTINCT price_range FROM rest_data;
SELECT DISTINCT rating FROM rest_data;
SELECT DISTINCT is_delivering_now FROM rest_data;


-- task 4 >> find number of restaurants

SELECT COUNT(DISTINCT(restaurantid)) FROM rest_data;

# Total data is availabel for 9551 restaurants


-- task 5 >> country count 

SELECT COUNT(countryid) country_count FROM country_data;

-- total 15 countries data is availabel

-- task 6 >> country name

SELECT country_name FROM country_data;


-- task 7 >> country wise count of restaurants and percent of total restaurants 

SELECT c1.country_name,COUNT(r1.restaurantid) tot_rest, 
COUNT(r1.restaurantid)/(SELECT COUNT(restaurantid) FROM rest_data) * 100
FROM country_data c1 INNER JOIN rest_data r1
ON c1.countryid = r1.countrycode
GROUP BY c1.country_name
ORDER BY tot_rest DESC;

-- 90% of total restaurants are from india only


-- task 8 >> percentage of restaurants based on "Has_Online_Delivery"

SELECT COUNT(restaurantid) online_del,
COUNT(restaurantid)/(SELECT COUNT(restaurantid) FROM rest_data) * 100 tot_online_per
FROM rest_data 
GROUP BY Has_Online_Delivery;


-- 25.66%  Has_Table_Booking
-- but remaining 74.34% restaurants does NOT HAVE online delivery option


-- task 9 >> percentage of restaurants based on "Has_Table_Booking"

SELECT COUNT(restaurantid) online_del,
COUNT(restaurantid)/(SELECT COUNT(restaurantid) FROM rest_data) * 100 tot_online_per
FROM rest_data 
GROUP BY Has_Table_Booking;

-- 87.87% Has_Table_Booking remaining 12.12% DOES NOT HAVE Table_Booking

 
 -- task 10 >> top 5 restaurants with country name who has most number of votes >>
 
 SELECT r1.restaurantid,r1.restaurantname,votes,c1.country_name FROM 
 country_data c1 INNER JOIN rest_data r1
 ON c1.countryid = r1.countrycode
 ORDER BY r1.votes DESC
 LIMIT 5;
 
 
 -- task 11 >> find most common cuisines from database
 
 SELECT cuisines,count(cuisines) cuis_count FROM rest_data
 GROUP BY cuisines
 ORDER BY cuis_count DESC;
 
 -- North Indian is the most common cuisine in dataset
 
 
 -- task 12 Number of restaurants opening based on Year,Quarter,Month
 
-- Year wise restaurant opening
 
 SELECT YEAR(datekey_opening) open_year ,count(restaurantid) tot_rest
 FROM rest_data
 GROUP BY open_year
 ORDER BY open_year ASC;
 
 -- Month wise restaurant opening
 
SELECT MONTHNAME(datekey_opening) open_month ,count(restaurantid) tot_rest
FROM rest_data
GROUP BY open_month,MONTH(datekey_opening)
ORDER BY MONTH(datekey_opening) ASC;

 -- Quarter wise restaurant opening
 
 SELECT QUARTER(datekey_opening) open_quart ,count(restaurantid) tot_rest
FROM rest_data
GROUP BY open_quart
ORDER BY open_quart ASC;


-- task 13 >> find the city with highest average cost for two people in india

SELECT r1.city,AVG(average_cost_for_two) avg_cost FROM 
country_data c1 INNER JOIN rest_data r1
ON c1.countryid = r1.countrycode
WHERE c1.country_name = "India"
GROUP BY r1.city
ORDER BY avg_cost Desc;

-- the top 2 expensive city for dining are >> Panchkula , Hyderabad , pune


-- task 14 >>  highest voting restaurant in each country

WITH 
CTE1 AS
(
SELECT c1.country_name,r1.restaurantname,r1.votes tot_votes,
ROW_NUMBER() OVER(PARTITION BY c1.country_name ORDER BY r1.votes DESC) rn FROM
country_data c1 INNER JOIN rest_data r1
ON c1.countryid = r1.countrycode
)

SELECT * FROM cte1 WHERE rn = 1;


-- task 15 >> highest rating restaurant in each country

WITH 
cte1 AS
(
SELECT c1.country_name,r1.restaurantname,r1.rating,
ROW_NUMBER() OVER(PARTITION BY c1.country_name ORDER BY r1.rating DESC) rn
FROM country_data c1 INNER JOIN rest_data r1
ON c1.countryid = r1.countrycode
)

SELECT * FROM cte1 WHERE rn = 1;


-- task 16 >> meaning of price range category

SELECT DISTINCT(price_range) FROM rest_data;


SELECT price_range,MIN(average_cost_for_two) min_price,MAX(average_cost_for_two) max_price
FROM rest_data
GROUP BY price_range;


-- 1	0	450  >> Cheap (D)
-- 2	15	70000 >> Expensive (B)
-- 3	30	800000 >> Most Expensive (A)
-- 4	50	8000 >> Moderate (C)


ALTER TABLE rest_data
ADD COLUMN status VARCHAR(40);

SELECT status FROM rest_data;

SET SQL_SAFE_UPDATES = 0;

UPDATE rest_data SET status = 
case 
WHEN price_range = 1 THEN "Cheap"
WHEN price_range = 2 THEN "Expensive"
WHEN price_range = 3 THEN "Most Expensive"
WHEN price_range = 4 THEN "Moderate"
END;

SET SQL_SAFE_UPDATES = 1;

SELECT price_range,status FROM rest_data;



-- task 17 >> find count of restaurants by the countries where
-- the majority of restaurants offer Online Delivery and Table Booking


SELECT c1.country_name,COUNT(restaurantid) tot_rest
FROM country_data c1 INNER JOIN rest_data r1
ON c1.countryid = r1.countrycode
WHERE has_online_delivery = "yes" AND has_table_booking = "yes"
GROUP BY c1.country_name;



-- task 18 >> find restaurant where name of character > 15 character

SELECT restaurantname,LENGTH(restaurantname) tot_chars FROM rest_data
WHERE LENGTH(restaurantname) > 15
ORDER BY tot_chars DESC;


-- task 19 >> avg_cost > 1000 "GOOD" otherwise "BAD"


SELECT 
restaurantname,average_cost_for_two,CASE
WHEN average_cost_for_two > 1000 THEN "GOOD"
WHEN average_cost_for_two < 1000 THEN "BAD"
END as Experience
FROM rest_data;


-- task 20 >> find the restaurants that are currently delivering


SELECT restaurantname,is_delivering_now FROM rest_data
WHERE is_delivering_now = "yes";
