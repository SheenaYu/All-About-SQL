/* Query a count of the number of cities in CITY having a Population larger than 100,000 */
select count(distinct name) as n_city
from CITY
where POPULATION > 100000

/* Query the total population of all cities in CITY where District is California.*/
select sum(POPULATION) as total_population
from CITY
where DISTRICT = "California"

/*Query the average population of all cities in CITY where District is California.*/
select avg(POPULATION)
from CITY
where DISTRICT = "California"

/*Query the average population for all cities in CITY, rounded down to the nearest integer.*/
select round(avg(POPULATION), 0)
from CITY

/*Query the sum of the populations for all Japanese cities in CITY. The COUNTRYCODE for Japan is JPN.*/
select sum(POPULATION) as Jpn_population
from CITY
where COUNTRYCODE = "JPN"

/*Query the difference between the maximum and minimum populations in CITY.*/
select (max(POPULATION) - min(POPULATION)) as max_diff
from CITY

/******************************************************************************************************/

/*Write a query calculating the amount of error (i.e.:  average monthly salaries), and round it up to the next integer.*/
select ceil(avg(Salary) - avg(replace(Salary, '0', ''))) as miscalculated_amt
from EMPLOYEES

/******************************************************************************************************/
/* Top Earners */
/* We define an employee's total earnings to be their monthly  worked, and the maximum total earnings to be the maximum 
total earnings for any employee in the Employee table. Write a query to find the maximum total earnings for all employees 
as well as the total number of employees who have maximum total earnings. Then print these values as  space-separated integers.*/
select salary*months as earnings, count(employee_id)
from Employee
group by earnings
order by earnings desc
limit 1

/******************************************************************************************************/

/* Weather Observation Station 2 */

/* Query the following two values from the STATION table:
The sum of all values in LAT_N rounded to a scale of  decimal places.
The sum of all values in LONG_W rounded to a scale of  decimal places. */
select round(sum(LAT_N), 2) as lat, round(sum(LONG_W), 2) as lon
from STATION

/******************************************************************************************************/

/* Weather Observation Station 13 */
/* Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than  and less than . Truncate your answer to  decimal places. */

select round(sum(LAT_N), 4) as nl
from STATION
where LAT_N between 38.7880 and 137.2345

/* Weather Observation Station 14 */
/* Query the greatest value of the Northern Latitudes (LAT_N) from STATION that is less than 137.2345. 
Truncate your answer to  decimal places. */

select round(max(LAT_N), 4)
from STATION
where LAT_N < 137.2345

/* Weather Observation Station 15 */
/* Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than 137.2345. 
Round your answer to 4 decimal places. */

select round(LONG_W, 4)
from STATION
where LAT_N = 
    (select max(LAT_N) from STATION where LAT_N < 137.2345)


 /* Weather Observation Station 18 */
 /* Consider P1(a, b) and P2(c, d) to be two points on a 2D plane.

 happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
 happens to equal the minimum value in Western Longitude (LONG_W in STATION).
 happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
 happens to equal the maximum value in Western Longitude (LONG_W in STATION).
 Query the Manhattan Distance between points P1 and P2 and round it to a scale of 4 decimal places.
 */

select round(abs(min(LAT_N) - max(LAT_N)) + abs(min(LONG_W) - max(LONG_W)), 4) as manhattan_distance
from STATION

/* Weather Observation Station 19 */
/* Consider P1(a, c) and P2(b, d) to be two points on a 2D plane where (a, b) are the respective minimum and maximum values of Northern Latitude (LAT_N)
 and (c, d) are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.
Query the Euclidean Distance between points P1 and P2 and format your answer to display  decimal digits. */

select round(sqrt(power(min(LAT_N) - max(LAT_N), 2) + power(min(LONG_W) - max(LONG_W), 2)), 4) as euclidean_distance
from STATION

/* Weather Observation Station 20 */
/* A median is defined as a number separating the higher half of a data set from the lower half. 
Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to 4 decimal places. */

SELECT ROUND(avg(t1.lat_n), 4) as median_val FROM (
SELECT @rownum:=@rownum+1 as row_number, d.lat_n
  FROM STATION d,  (SELECT @rownum:=0) r
  WHERE 1
  -- put some where clause here
  ORDER BY d.lat_n
) as t1, 
(
  SELECT count(*) as total_rows
  FROM STATION d
  WHERE 1
  -- put same where clause here
) as t2
WHERE 1
AND t1.row_number in ( floor((total_rows+1)/2), floor((total_rows+2)/2) );

