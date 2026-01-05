-- Create a Database
CREATE DATABASE Zomato_Analysis;

-- use the created database
USE Zomato_Analysis;

-- 1. Users Table
CREATE TABLE Users(
user_id int primary Key,
name varchar(100),
city varchar(100),
registration_date datetime
);

-- 2. Restaurants Table
CREATE TABLE Restaurants(
restaurant_id int Primary Key,
Restaurant_name varchar(100),
city varchar(100),
cuisine_type varchar(100)
);

-- 3. Orders Table
CREATE TABLE Orders(
order_id int Primary Key,
user_id int,
restaurant_id int,
order_time datetime,
delivery_time datetime,
total_amount decimal(10,2),
FOREIGN KEY (user_id) REFERENCES Users(user_id),
FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
);

-- 4. Order_Items Table
CREATE TABLE Order_Items(
order_id int ,
item_name varchar(100),
quantity int,
price decimal(10,2),
FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- 5. Reviews Table
CREATE TABLE Reviews(
review_id int Primary key,
user_id int,
restaurant_id int,
rating int,
review_text varchar(100),
review_date datetime,
FOREIGN KEY (user_id) REFERENCES Users(user_id),
FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
);

-- import the data from the csv files two mwthods 1) direct import 2) load data infile method
-- used direct import

-- Preview first 5 rows from the Users table
SELECT * FROM users LIMIT 5;

-- Preview first 5 rows from the Restaurants table
SELECT * FROM restaurants LIMIT 5;

-- Preview first 5 rows from the Orders table
SELECT * FROM order_items;

-- Preview first 5 rows from the Order_Items table
SELECT * FROM orders LIMIT 5;

-- Preview first 5 rows from the Reviews table
SELECT * FROM reviews LIMIT 5;

-- Now let's check detailed structure of each table
DESCRIBE users;
DESCRIBE Restaurants;
DESCRIBE Orders;
DESCRIBE Order_Items;
DESCRIBE Reviews;

-- Calculating Total no. of orders 
SELECT count(*) as total_orders from orders;
-- --------------------
-- Output:
-- Total_no_of_orders
-- '500'
-- --------------------

-- How many total active users are there?
select * from users;
SELECT count(distinct user_id) as total_active_users from users;
-- --------------------
-- Output:
-- total_active_users
-- '100'
-- --------------------

-- Calculating Total Revenue
-- net revenue (after discount,tax)
select sum(total_amount) as total_revenue from orders;
-- --------------------
-- Output:
-- total_revenue
-- '248145.32'
-- --------------------
-- gross revenue
select SUM(price * quantity) as revenue_from_items from order_items;
-- --------------------
-- Output:
-- revenue_from_items
-- '414478.29'
-- --------------------

-- Calculate the Average Order Value (AOV)
select avg(total_amount) as avg_order_value from orders;
-- --------------------
-- Output:
-- avg_order_value
-- '496.290640'
-- --------------------

-- What is the growth trend of new users over time?
select date_format(registration_date , '%y-%m') as Months,count(*) as new_users 
from users 
group by Months 
order by Months;
-- --------------------
-- Output:
-- Months new_users
-- 22-01	7
-- 22-02	7
-- 22-03	8
-- 22-04	9
-- 22-05	6
-- 22-06	4
-- 22-07	14
-- 22-08	8
-- 22-09	7
-- 22-10	14
-- 22-11	4
-- 22-12	12
-- --------------------

-- Which locations have the most active users?
select city, count(*) as users from users 
group by city 
order by users desc;
-- --------------------
-- Output:
-- City      users
-- Hyderabad	18
-- Delhi	    17
-- Pune	        13
-- Chennai	    12
-- Kolkata	    12
-- Bengaluru	11
-- Mumbai	    10
-- Ahmedabad	7
-- --------------------

-- calculate the city-wise revenue
select r.city ,sum(o.total_amount) as revenue 
from restaurants r join orders o 
on r.restaurant_id = o.restaurant_id
group by r.city
order by revenue desc; 
-- --------------------
-- Output:
-- City       revenue
-- Hyderabad  77129.97
-- Delhi	  62028.17
-- Mumbai	  45065.64
-- Kolkata	  38906.43
-- Ahmedabad  25015.11
-- --------------------

-- Who are the top 5 high-value customers by total spend?
select o.user_id , u.name ,round(sum(o.total_amount),2) as total_spend 
from orders o join users u 
on o.user_id= u.user_id
group by o.user_id,u.name
order by total_spend desc 
limit 5;
-- -------------------------------
-- Output:
-- user_id  name     total_spend
-- 36       User_36  5104.69
-- 11       User_11  4820.10
-- 49       User_49  4818.39
-- 92       User_92  4704.93
-- 86       User_86  4626.20
-- -------------------------------

-- Which are the top 10 most ordered-from restaurants?
select r.Restaurant_name , count(o.restaurant_id) as total_orders 
from restaurants r join orders o 
on r.restaurant_id = o.restaurant_id 
group by r.Restaurant_name 
order by total_orders desc
limit 10;
-- -------------------------------
-- Output:
-- Restaurant_name  total_spend
-- Restaurant_18	35
-- Restaurant_20	28
-- Restaurant_16	28
-- Restaurant_15	28
-- Restaurant_8	    28
-- Restaurant_3	    27
-- Restaurant_5	    27
-- Restaurant_19	26
-- Restaurant_10	26
-- Restaurant_6	    25
-- -------------------------------

-- Which cuisines are the most popular among customers?
select r.cuisine_type,count(o.restaurant_id) as total_orders 
from restaurants r join orders o 
on r.restaurant_id = o.restaurant_id 
group by r.cuisine_type 
order by total_orders desc;
-- -------------------------------
-- Output:
-- cuisine_type  total_orders
-- Desserts	     126
-- Fast Food	 99
-- South Indian	 86
-- Italian	     76
-- North Indian  48
-- Continental	 25
-- Chinese	     23
-- Mexican	     17
-- -------------------------------

-- calculate the average delivery duration for each order
select round(avg(timestampdiff(minute,order_time,delivery_time)),0) as Average_Duration from orders;
-- --------------------
-- Output:
-- Average_Duration
-- '40'
-- --------------------

-- calculate the average delivery time by city
SELECT r.city,round(avg(TIMESTAMPDIFF(minute,o.order_time,o.delivery_time)),0) as Average_delivery_time
FROM orders o
JOIN restaurants r
ON o.restaurant_id=r.restaurant_id
GROUP BY city
ORDER BY Average_delivery_time DESC;
-- --------------------
-- Output:
-- city        Average_delivery_time
-- Delhi	   41
-- Kolkata	   40
-- Ahmedabad   40
-- Hyderabad   40
-- Mumbai	   40
-- --------------------

-- calculate the total number of orders received by each restaurant
SELECT r.Restaurant_name,count(o.order_id) as Total_Order
FROM orders as o
JOIN restaurants as r
ON o.restaurant_id=r.restaurant_id
GROUP BY Restaurant_name
ORDER BY total_order DESC;

-- -------------------------------
-- Output:
-- Restaurant_name  Total_Order
-- Restaurant_18	35
-- Restaurant_8	    28
-- Restaurant_15	28
-- Restaurant_16	28
-- Restaurant_20	28
-- Restaurant_3	    27
-- Restaurant_5 	27
-- Restaurant_10	26
-- Restaurant_19	26
-- Restaurant_6	    25
-- Restaurant_11	25
-- Restaurant_13	25
-- Restaurant_9 	24
-- Restaurant_4 	23
-- Restaurant_14	23
-- Restaurant_2 	22
-- Restaurant_7	    22
-- Restaurant_17	22
-- Restaurant_12	19
-- Restaurant_1  	17
-- -------------------------------

-- calculate the average rating per restaurant based on the reviews provided by customers
select r.Restaurant_name,round(avg(re.rating),2) as Average_Rating
from restaurants r right join reviews re 
on r.restaurant_id=re.restaurant_id 
group by Restaurant_name
order by Average_Rating desc;
-- -------------------------------
-- Output:
-- Restaurant_name  Average_Rating
-- Restaurant_13	3.47
-- Restaurant_3	    3.36
-- Restaurant_14	3.22
-- Restaurant_5	    3.20
-- Restaurant_8	    3.11
-- Restaurant_6	    3.08
-- Restaurant_10	3.06
-- Restaurant_15	2.94
-- Restaurant_11	2.79
-- Restaurant_18	2.73
-- Restaurant_12	2.71
-- Restaurant_17	2.71
-- Restaurant_4	    2.70
-- Restaurant_7	    2.64
-- Restaurant_16	2.63
-- Restaurant_20	2.63
-- Restaurant_1	    2.60
-- Restaurant_9	    2.54
-- Restaurant_19	2.47
-- Restaurant_2	    2.31
-- ------------------------

-- identify the best-selling items from the orders placed by customers.
SELECT item_name,sum(quantity) as Total_quantity
FROM order_items 
GROUP BY item_name
ORDER BY Total_quantity DESC;

-- --------------Output:----------------
-- item_name             Total_quantity
-- Margarita Pizza	     389
-- Chicken Biryani	     377
-- Pasta Alfredo	     350
-- Chocolate Cake	     331
-- Paneer Butter Masala	 325
-- Veg Burger	         300
-- -------------------------------------

-- calculate the total revenue generated by each item
SELECT item_name,sum(price * quantity) as Total_revenue
FROM order_items
GROUP BY item_name
ORDER BY Total_revenue DESC;
-- --------------Output:----------------
-- item_name             Total_revenue
-- Chicken Biryani	     77940.19
-- Margarita Pizza	     76134.20
-- Pasta Alfredo         69269.14
-- Chocolate Cake	     67398.09
-- Paneer Butter Masala	 65895.54
-- Veg Burger	         57841.13
-- -------------------------------------

-- analyze the distribution of customer ratings across all restaurants.
SELECT rating,count(*) Reviws_count
FROM reviews
GROUP BY rating
ORDER BY rating ASC;
-- --------------------
-- Output:
-- rating  Reviws_count
-- 1	    74
-- 2	    58
-- 3	    59
-- 4	    59
-- 5	    50
-- --------------------

-- Count Sentiment Distribution
SELECT 
CASE
	WHEN rating >=4 THEN "Positve"
    WHEN rating =3 THEN "Neutral"
    ELSE "Negative"
END as Sentiment,
count(*) as Review_count
FROM reviews
GROUP BY Sentiment
ORDER BY Review_count DESC;
select count(*) from reviews;

-- --------------------
-- Output:
-- Sentiment  Review_count
-- Negative	  132
-- Positve	  109
-- Neutral	  59
-- --------------------

-- City Revenue Summary Viewxxx	
CREATE VIEW city_revenue_view as 
SELECT u.city,round(sum(o.total_amount),2) as total_revenue
FROM orders o
JOIN users u
ON o.user_id=u.user_id
GROUP BY u.city;
select * from city_revenue_view;

-- --------------------
-- Output:
-- city        total_revenue
-- Delhi	   40152.19
-- Mumbai	   30271.02
-- Chennai	   28132.37
-- Hyderabad   43391.48
-- Bengaluru   26723.86
-- Pune	       30562.63
-- Ahmedabad   17489.32
-- Kolkata	   31422.45
-- --------------------

-- -------------------------- Key Insights ---------------------------
-- 1. User and Order Statistics
-- 100 users placed 500 orders (avg 5 per user).
-- Average Order Value: ₹496.29 — shows healthy spending.

-- 2. Revenue Insights
-- Net Revenue: ₹2,48,145.32 | Gross Revenue: ₹4,14,478.29.
-- Discounts/taxes reduce sales by ~40%.
-- Top cities: Hyderabad, Delhi, Mumbai (50%+ of revenue).

-- 3. User Growth Trends
-- Steady growth from Jan–Dec 2022.
-- Peaks in July and October, likely due to promotions or seasonal demand.

-- 4. Geographical Insights
-- Most active users: Hyderabad (18), Delhi (17), Pune (13).
-- Higher user activity aligns with higher city revenue.

-- 5. Customer Behavior & Preferences
-- Top Cuisines: Desserts (126), Fast Food (99), South Indian (86).
-- Top Restaurants: Restaurant_18 (35 orders), Restaurant_20 & 16 (28 each).
-- Consistent orders show customer loyalty.

-- 6. Delivery Insights
-- Avg delivery time: 40 mins.
-- Delhi (41 mins) slightly higher due to traffic or distance.

-- 7. Customer Satisfaction
-- Avg rating: 2.3–3.5 → improvement needed.
-- Top-rated: Restaurant_13, Restaurant_3 (>3.3).
-- Sentiments: Negative 49%, Positive 40%, Neutral 11%.
-- Indicates dissatisfaction with food or service quality.

-- 8. Top Performing Food Items
-- Most ordered: Margarita Pizza (389), Chicken Biryani (377), Pasta Alfredo (350).
-- Top revenue:
-- Biryani – ₹77,940
-- Pizza – ₹76,134
-- Pasta – ₹69,269
-- Biryani & Pizza are high-demand, high-profit items.

-- 9. City Revenue Summary
-- Top revenue cities:
-- Hyderabad – ₹43,391
-- Delhi – ₹40,152
-- Kolkata – ₹31,422
-- Pune & Mumbai follow closely — strong Tier-1 presence.


-- -------------------------- Suggestions & Recommendations -----------------------------
-- 1. Focus on top-performing cities (Hyderabad, Delhi, Mumbai) with targeted offers.
-- 2. Improve delivery efficiency in Delhi to reduce average time.
-- 3. Enhance food quality and service to raise customer ratings.
-- 4. Promote high-profit items like Biryani and Pizza through combos or discounts.
-- 5. Analyze negative feedback to reduce 49% dissatisfaction rate.



