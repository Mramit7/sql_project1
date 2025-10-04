#import the dataset and do usual exploratory analysis steps like checking the str. and characterstics of the dataset:
#1. Data type of all columns in the "customers" table.
#2. Get the time range between which the orders were placed.

select *
from SQL_PROJECT.customers
LIMIT 10;

select *
from  SQL_PROJECT.geolocation
limit 5;
 
 #Get the time range between which the orders were placed.

 select 
 min(order_purchase_timestamp) as start_time,
 max(order_purchase_timestamp) as end_time
 from SQL_PROJECT.orders;

 #details the citits and states of customers who ordered during the given period

select
c.customer_city, c.customer_state

FROM SQL_PROJECT.orders as o
join SQL_PROJECT.customers as c
on o.customer_id = c.customer_id
WHERE EXTRACT(YEAR from o.order_purchase_timestamp) = 2018
AND EXTRACT (MONTH FROM order_purchase_timestamp) BETWEEN 1 and 3;

#is there a growing trend in the no. of orders placed over the past years?
SELECT 
EXTRACT(month from order_purchase_timestamp) as month,
count(order_id) as order_num
from SQL_PROJECT.orders
GROUP BY EXTRACT (month from order_purchase_timestamp)
Order by order_num desc
;
/*
During what time of the day, do the Brazilian customers mostly placed their orders?(Dawn,morning,Afternoon or night)

0-6 hrs :Dawn
7-12 hrs :Mornings
13-18 hrs :Afternoon
19-23 hrs : Night
*/
SELECT
EXTRACT (hour from order_purchase_timestamp) as time,
count(order_id) as order_num
from SQL_PROJECT.orders
GROUP BY EXTRACT (hour from order_purchase_timestamp)
Order by order_num desc;
# 3. GET month on month number of orders.
select 
EXTRACT(MONTH from order_purchase_timestamp) as month,
extract(year from order_purchase_timestamp)  as year,
count(*) as order_num
from SQL_PROJECT.orders
GROUP by year, month
ORDER by year, month
;
#2. Distribution of customers across the states of brazil
select 
customer_city, customer_state,

COUNT(DISTINCT customer_id) as customer_count

from SQL_PROJECT.customers
 GROUP BY customer_city,customer_state
 order by customer_count DESC;

 # Get the % increase in the cost of orders from year 2017 to 2018 (include months between jan to aug only)
 # you can use the "payment_value" column in the payments table to get the cost of orders.

 #step 1 : calculate total payments per year
 with yearly_totals as (
 select 
 EXTRACT(YEAR from o.order_purchase_timestamp)as year,
 SUM(p.payment_value) as total_payment
 from SQL_PROJECT.payments as p 
 join SQL_PROJECT.orders as o 
 ON p.order_id = o.order_id
 WHERE EXTRACT(YEAR from o.order_purchase_timestamp) in (2017,2018) and EXTRACT (MONTH from o.order_purchase_timestamp)between 1 and 8
 GROUP BY EXTRACT(YEAR from o.order_purchase_timestamp) 
 ),
 
 # step 2: USE LEAD WINDOW function to compare each year's payments with the previous year
yearly_comparisons as (
  select 
  year, 
  total_payment,
  lead(total_payment) over (order by year desc) as prev_year_payment
  from yearly_totals
)

 #step 3 : Calculate % increase
 SELECT 
 round(((total_payment - prev_year_payment) / prev_year_payment)*100,2)
 FROM yearly_comparisons;

 # Mean and sum of price and frieght value by customer state
 SELECT 
 c.customer_state,
 AVG(price) as avg_price,
 SUM(price) as total_price,
 AVG(freight_value) as avg_freight,
 SUM(freight_value) as total_freight
 from `SQL_PROJECT.orders` as o 
 JOIN `SQL_PROJECT.order_items` as oi
 ON o.order_id = oi.order_id
 JOIN `SQL_PROJECT.customers` as c
 ON o.customer_id = c.customer_id
 GROUP BY c.customer_state;

 #Calculate days between purchasing,delivering, and estimated delivery.
SELECT order_id,
DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp),DAY) as days_to_delivery,
DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) as diff_estimated_delivery
from `SQL_PROJECT.orders`;

#find out the top 5 states with the highest & lowest average freight value.


SELECT 
c.customer_state,
avg(freight_value) as avg_freight_value
from `SQL_PROJECT.orders` as o
join `SQL_PROJECT.order_items` as oi
on o.order_id = oi.order_id
JOIN `SQL_PROJECT.customers` as c 
ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY avg_freight_value DESC
LIMIT 5;

#find out the top 5 states with the highest & lowest average delivery time.

SELECT 
c.customer_state,
avg(extract(DATE from o.order_delivered_customer_date) - EXTRACT (DATE from order_purchase_timestamp ))as avg_time_to_delivery
from `SQL_PROJECT.orders` as o
join `SQL_PROJECT.order_items` as oi
on o.order_id = oi.order_id
JOIN `SQL_PROJECT.customers` as c 
ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY avg_time_to_delivery DESC
LIMIT 5;

# Find the month on month no. of orders placed using different payment types

SELECT 
Payment_type,
EXTRACT(YEAR FROM order_purchase_timestamp) as year,
EXTRACT(MONTH FROM order_purchase_timestamp) as month,
COUNT(DISTINCT o.order_id) as number_of_order
FROM `SQL_PROJECT.orders` as o 
inner join `SQL_PROJECT.payments` as p 
ON o.order_id = p.order_id
 GROUP BY payment_type, year, month
 ORDER BY payment_type, year, month;

 # Count of orders based on the number of payment installments.
 select 
 payment_installments,
 COUNT(DISTINCT order_id) as num_orders
 FROM `SQL_PROJECT.payments`
 GROUP BY payment_installments