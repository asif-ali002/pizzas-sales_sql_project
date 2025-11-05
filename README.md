🍕 Pizza Sales Analysis (PizzaHut Database)
📘 Overview

This project analyzes pizza sales data using SQL.
It involves creating a relational database (pizzahut) and running various queries to extract meaningful business insights — such as total revenue, most popular pizzas, and sales patterns.

The database contains order-level and pizza-level details, allowing for analysis of sales performance, customer preferences, and time-based trends.

🧱 Database Structure
Database

pizzahut

Tables

orders

Column	Type	Description
order_id	INT	Unique ID for each order
order_date	DATE	Date of order
order_time	TIME	Time when the order was placed

orders_details

Column	Type	Description
order_details_id	INT	Unique ID for each order detail record
order_id	INT	References order in the orders table
pizza_id	TEXT	References pizza in the pizzas table
quantity	INT	Number of pizzas ordered

(Assumed supporting tables)

pizzas: contains pizza_id, pizza_type_id, size, and price

pizza_types: contains pizza_type_id, name, and category

🧮 SQL Queries and Insights
1. Total Orders
SELECT COUNT(order_id) AS total_orders FROM orders;


Retrieves the total number of orders placed.

2. Total Revenue
SELECT ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_sales
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id;


Calculates the total revenue generated from pizza sales.

3. Highest-Priced Pizza
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


Finds the most expensive pizza on the menu.

4. Most Common Pizza Size
SELECT pizzas.size, COUNT(orders_details.order_details_id) AS order_count
FROM pizzas
JOIN orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


Identifies which pizza size is most frequently ordered.

5. Top 5 Most Ordered Pizza Types
SELECT pt.name, SUM(od.quantity) AS quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;


Displays the top 5 most ordered pizzas by quantity.

6. Total Quantity by Category
SELECT pt.category, SUM(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;


Shows which pizza categories (e.g., Classic, Veggie, Supreme) sell the most.

7. Order Distribution by Hour
SELECT HOUR(o.order_time) AS order_hour, COUNT(*) AS total_orders
FROM orders o
GROUP BY order_hour
ORDER BY order_hour;


Analyzes order frequency based on the time of day.

8. Category-Wise Pizza Distribution
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;


Displays how many pizza types belong to each category.

9. Average Number of Pizzas Ordered per Day
SELECT ROUND(AVG(daily_pizzas), 0) AS avg_pizzas_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS daily_pizzas
    FROM orders o
    JOIN orders_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_totals;


Calculates the daily average of pizzas ordered.

10. Top 3 Pizzas by Revenue
SELECT pt.name AS pizza_name,
       ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM orders_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


Lists the top 3 pizzas that generate the highest revenue.

11. Revenue Contribution by Pizza Type
SELECT pt.name AS pizza_name,
       ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
       ROUND((SUM(od.quantity * p.price) / 
              (SELECT SUM(od2.quantity * p2.price)
               FROM orders_details od2
               JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id) * 100), 2) AS revenue_percent
FROM orders_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;


Shows each pizza’s percentage contribution to total sales.

12. Cumulative Revenue Over Time
SELECT o.order_date,
       ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
       ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date), 2) AS cumulative_revenue
FROM orders o
JOIN orders_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;


Tracks cumulative sales growth day by day.

13. Top 3 Pizzas by Revenue per Category
SELECT category, pizza_name, total_revenue
FROM (
    SELECT pt.category,
           pt.name AS pizza_name,
           ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
           ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn
    FROM orders_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked
WHERE rn <= 3
ORDER BY category, total_revenue DESC;


Finds the top 3 best-performing pizzas (by revenue) in each category.

📊 Key Insights You Can Discover

Total orders and overall revenue

Most and least popular pizza types

Sales distribution by size, category, and time of day

Top-performing pizzas by revenue

Daily and cumulative sales trends

🛠️ Tools Used

Database: MySQL / PostgreSQL

Query Language: SQL

Data Source: Pizza sales dataset
