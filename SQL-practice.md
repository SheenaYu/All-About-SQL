###### Prepared by Sheena Yu

[Scenario 1](#scenario-1)

[Scenario 2](#scenario-2)

[Scenario 3](#scenario-3)

[Scenario 4](#scenario-4)

[Scenario 5](#scenario-5)

# Scenario 1

| id | company | year_start |
|-----|------|-------|
|1 | Microsoft | 2000 |
|1 | Google | 2006 |
|1 | Facebook |2012 |
|2 | Microsoft | 2001 |
|2| Oracle | 2004 |
|2| Google | 2007 |
|3| Uber | 2009 |
|3| Google | 2012 |
|4| Yelp | 2008 |
|4| Airbnb | 2011 |
|4| Microsoft | 2013 |
|4| Google | 2016 |

1. How many members ever moved from Microsoft to Google? (both member #1, #2, #4 count)

```sql
INSERT INTO public.linkedin(id, company, year_start)
VALUES (1, 'Microsoft', 2000)
(1, 'Google', 2006),
(1, 'Facebook', 2012),
(2, 'Microsoft', 2001),
(2, 'Oracle', 2004),
(2, 'Google', 2007),
(3, 'Uber', 2009),
(3, 'Google', 2012),
(4, 'Yelp', 2008),
(4, 'Airbnb', 2011),
(4, 'Microsoft', 2013),
(4, 'Google', 2016);


select * from linkedin

-- how many members ever moved from Microsoft to Google? (both member #1, #2, #4 count)
select count(*) from linkedin a, linkedin b
where a.id = b.id
and a.company = 'Microsoft' and b.company = 'Google'
and a.year_start < b.year_start


-- how many members moved directly from Microsoft to Google? 
-- (Member 2 does not count since Microsoft -> Oracle -> Google)

SELECT count(*) FROM linkedin c1, linkedin c2
WHERE c1.id = c2.id
AND c1.Company = 'Microsoft' 
AND c2.Company = 'Google'
AND c1.Year_Start < c2.Year_Start
AND c1.id NOT IN (SELECT c3.id FROM linkedin c3 
                  WHERE c3.id = c1.id AND c3.Year_Start > c1.Year_Start AND c3.Year_Start < c2.Year_Start)
```

* * *

# Scenario 2

There are four tab delimited files in the dataset:

**table1.txt** : each record corresponds to the cost of treatment for a patient with a specific disease by a specific doctor - a patient can have many diseases - a patient sees only one doctor per disease but may see different doctors for each of their diseases


|patient_id|disease_id|doctor_id|cost|
|---|---|---|---|
|2046|6|25|177|
|30365|2|454|183|
|9100|15|689|111|
|23602|5|312|464|


**table2.txt** : names of the diseases in the dataset


|disease_id|disease_name|
|---|---|
|1|Upper respiratory infections|
|2|Disorders of lipid metabolism|
|3|Sinusitis|
|4|Other arthropathy disorders|
|5|Low back pain|

**table3.txt** : zip codes of the patients in the dataset

|patient_id|patient_zip|
|---|---|
|1|10191|
|2|10270|
|3|10270|
|4|10561|


**table4.txt**: efficiency scores of the doctors in the dataset - the meaning of this score is not relevant to this assessment
You may use any tools available to you to analyze this dataset and answer the following questions.

|doctor_id|doctor_score|
|---|---|
|1|0.68|
|2|1 |
|3|0.89 |
|4|1.01 |


```sql
/* What is the average cost of treating a patient for "Low back pain" ? */

select avg(t1.cost) from t1 
left join t2 
on t1.disease_id = t2.disease_id
where t2.disease_name = 'Low back pain'

/* How many doctors treat patients in the 10424 zip code ?*/

select count(distinct t1.doctor_id) from t1 
left join t3 on t1.patient_id = t3.patient_id
where t3.patient_zip = '10424'

/* If doctors are ranked by their average cost of treating a patient with 
"Low back pain", at what average cost does a doctor at the 75th percentile treat 
a patient with "Low back pain" ? */

create view ranked_cost as 
(select avg(t1.cost) as avg_cost, t1.doctor_id
from t1  
left join t2 
on t1.disease_id = t2.disease_id
where t2.disease_name = 'Low back pain'
group by t1.doctor_id
order by 1)

select percentile_disc(0.75) within group (order by avg_cost)
from ranked_cost

/* Doctors with a doctor_score of 1 or less are considered efficient. 
Which disease (specify the disease_name) has the highest percentage of patients 
being treated by efficient doctors ? */

select e.disease_name, 
       sum(e.is_efficient), count(e.patient_id), 
       (sum(e.is_efficient)*1.0) / (count(e.patient_id)*1.0) as ratio
from
	(select t1.patient_id, t1.disease_id, t2.disease_name, 
	 (case when t4.doctor_score <= 1 then 1 else 0 end) as is_efficient 
	from t1 
	left join t4 on t1.doctor_id = t4.doctor_id
	left join t2 on t1.disease_id = t2.disease_id) as e
group by e.disease_id, e.disease_name
order by ratio desc

/* For which disease (specify the disease_name) is the doctor_score most positively 
correlated with the average cost of a doctor treating a patient with that disease ? */

create view disease_corr as
select cost.*, t4.doctor_score
from
	(select t1.disease_id, t1.doctor_id, 
            avg(t1.cost) as avg_cost_per_disease from t1 
	group by t1.doctor_id, t1.disease_id
	) cost
left join t4 on cost.doctor_id = t4.doctor_id
order by cost.disease_id


select t2.disease_name, cor.correlation 
from 
	(select disease_id, corr(avg_cost_per_disease, doctor_score) as correlation 
	from disease_corr
	group by disease_id) cor
left join t2 on cor.disease_id = t2.disease_id
order by cor.correlation desc
```

* * *

# Scenario 3

|id|price|
|---|---|
|1|200|
|2|233|
|3|13|
|4|94|
|5|42|
|6|301|
|7|200|
|8|200|

```sql
-- Median calculation
create view ordered_purchases as 
    (select price,
      		row_number() over (order by price) as row_id,
      		(select count(1) from price) as ct
    from price)


select avg(price) as median
from ordered_purchases
where row_id between ct/2.0 and ct/2.0 + 1

-- Mode
select price, count(1) from price
group by 1
order by 2 desc
limit 1

```

* * *

# Scenario 4

**Table user_action**

|userid|action|date|
|---|---|---|
|123|purchase|2016-11-06 00:00:00|
|123|login|2016-11-06 00:00:00|
|123|play|2016-11-07 00:00:00|
|222|level_up|2016-11-06 00:00:00|
|333|sign_out|2016-11-06 00:00:00|
|444|play|2016-11-08 00:00:00|
|222|login|2016-11-08 00:00:00|
|222|sign_out|2016-11-08 00:00:00|
|333|sign_out|2016-11-07 00:00:00|
|444|play|2016-11-06 00:00:00|


**Table user_os**

|userid|os|
|---|---|
|123|Android|
|222|ios|
|444|ios|
|333|Android|

**Table song**

|userid|song_name|timestamp|
|---|---|---|
|123|aaa|147864-07-06 00:00:00|
|123|aaa|147864-07-06 00:00:00|
|123|bbb|147864-07-09 00:00:00|
|222|ccc|147864-08-08 00:00:00|
|123|aaa|147864-05-05 00:00:00|
|123|aaa|147864-09-09 00:00:00|
|222|ddd|147864-01-23 00:00:00|
|333|acc|147864-01-27 00:00:00|
|222|bbb|147864-01-09 00:00:00|
|222|bbb|147864-05-09 00:00:00|
|222|bbb|147864-05-19 00:00:00|


**Table app_log**

|appid|latency|
|---|---|
|123|1.699|
|123|0.8|
|124|1.08|
|124|0.9|
|124|1.4|
|124|0.88|
|125|0.98|
|126|1.22|


```sql

/* Question 1 -
Calculate daily active users (DAU) between 2016-11-06 and 2016-11-12 */

SELECT date, COUNT(DISTINCT userid) as DAU FROM user_action
GROUP BY date
HAVING CAST(date as DATE) BETWEEN '2016-11-06' and '2016-11-12'
ORDER BY date

/* Question 2 - 
We have another table that records the OS version of each user. 
The columns are: userid (STRING), OS (STRING). 
Update the SQL query/code from Question 1 to get us the DAU per OS 
(Assume we only have Android and iOS) */

SELECT a.date, o.OS, COUNT(DISTINCT a.userid) as DAU FROM user_action a
JOIN user_OS o ON o.userid = a.userid
GROUP BY a.date, o.OS
HAVING CAST(a.date as DATE) BETWEEN '2016-11-06' AND '2016-11-12'
ORDER BY a.date

/* Question 3 - Using the sample table from Question 1, 
Get list of all users who have: done at least 5 unique events AND done "purchase" at least once 
AND done "level_up" at least once And for each user, 
show all unique events that they have done. */

create view user_action_conditions as
select userid, action,
       (case when action ='purchase' then 1 else 0 end) as purchase,
       (case when action ='level_up' then 1 else 0 end) as level_up
from user_action 

select distinct userid, action
from user_action
where userid in (select userid
                 from user_action_conditions 
                 group by userid
                 having count(distinct action) >= 5 
                        and sum(purchase) >= 1 
                        and sum(level_up) >= 1)

/* Question 4 - Imagine our customer has a music app and every time a user plays a song, 
we add a row of data in our database. 
The columns are: userid (STRING), song_name (STRING), timestamp (TIMESTAMP). 
So if a user played 100 songs, we would have 100 rows for this one user. 
Write a query that would tell us the top 3 played songs per user. */

SELECT summary.*
FROM
    (
    SELECT t.userid, t.song_name,
            ROW_NUMBER() OVER (PARTITION BY t.userid ORDER BY t.times_to_play desc) as song_rank
    FROM 
        (select userid, song_name, count(*) as times_to_play from song
         group by userid, song_name) t
    ) summary
WHERE summary.song_rank <= 3

/* Question 5 - In our backend logs, we record every API call that we receive from our customers. 
The columns that we have are: app_id (STRING), latency (float). 
Find the average latency of the top 5% slowest API requests (based on latency) per app. 
In other words, for each app, find the 5% slowest API requests and get the average of the latency. */


create view ordered_app_log as
(select *, row_number() over (partition by appid order by latency) as num 
from app_log)


select t1.appid, avg(t1.latency)
from ordered_app_log t1
join
(select appid, max(num)*0.9 as threshold
from ordered_app_log
group by appid) t2
on t1.appid = t2.appid
where t1.num >= t2.threshold
group by t1.appid

```

* * *

# Scenario-5

|id|start_date|end_date|
|---|---|---|
|01|2016-01-02|2017-02-02|
|02|2016-03-22| |
|03|2016-04-30| |
|04|2016-05-08| |
|05|2016-05-23| |
|06|2016-06-11|2016-09-09|
|07|2016-06-14|2016-07-22|
|08|2016-06-20| |
|09|2016-06-21|2016-07-13|
|10|2016-07-05| |
|11|2016-07-23|2016-07-30|
|12|2016-08-03|2016-08-22|
|13|2016-08-30|2016-09-03|


```sql

/* Given the app user table, calculate the number of new customers and the number 
of churned customers per month. */

select s.start_month as months, s.new_customers, e.churned_customers  
from
(select date_trunc('month', start_date) as start_month, count(id) as new_customers
from persons
group by start_month) as s
left join 
(select date_trunc('month', end_date) as end_month, count(id) as churned_customers
from persons
group by end_month) as e
on s.start_month = e.end_month
order by s.start_month

/* How many active users per month? */

create view customers_table as
(select s.start_month as months, 
       coalesce(s.new_customers, 0), coalesce(e.churned_customers, 0)  
from
(select date_trunc('month', start_date) as start_month, count(id) as new_customers
from persons
group by start_month) as s
left join 
(select date_trunc('month', end_date) as end_month, count(id) as churned_customers
from persons
group by end_month) as e
on s.start_month = e.end_month
order by s.start_month)

-- first approach: self join
select a.months, 
       sum(b.new_customers - b.churned_customers) as active_customers
from customers_table a
join customers_table b
on a.months >= b.months
group by a.months
order by a.months

-- second approach: window functions
select months, 
       sum(new_customers - churned_customers) over (order by months rows unbounded preceding) as active_customers
from customers_table


```

