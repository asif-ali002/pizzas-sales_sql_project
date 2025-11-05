CREATE DATABASE pizzahut;

CREATE TABLE orders(
order_id INT NOT NULL,
order_date date NOT NULL,
order_time time not NULL,
PRIMARY KEY (order_id));


CREATE TABLE orders_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id text NOT NULL,
quantity  int  NOT NULL,
PRIMARY KEY (order_details_id));


-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) as total_orders 
FROM orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
    
    
    -- Identify the highest-priced pizza.
    
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size, 
    COUNT(orders_details.order_details_id) AS order_count
FROM 
    pizzas
JOIN 
    orders_details 
    ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY 
    pizzas.size
ORDER BY 
    order_count DESC
LIMIT 1000;


-- List the top 5 most ordered pizza types along with their quantities.


SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.


SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

 
 
 -- Determine the distribution of orders by hour of the day.
 
SELECT 
    HOUR(o.order_time) AS order_hour, COUNT(*) AS total_orders
FROM
    orders o
GROUP BY order_hour
ORDER BY order_hour;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(daily_pizzas), 0) AS avg_pizzas_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS daily_pizzas
    FROM
        orders o
    JOIN orders_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS daily_totals;



-- Determine the top 3 most ordered pizza types based on revenue.


SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    orders_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pt.name AS pizza_name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    SUM(od2.quantity * p2.price)
                FROM
                    orders_details od2
                        JOIN
                    pizzas p2 ON od2.pizza_id = p2.pizza_id) * 100),
            2) AS revenue_percent
FROM
    orders_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;



-- Analyze the cumulative revenue generated over time


SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
    ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date), 2) AS cumulative_revenue
FROM orders o
JOIN orders_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category


SELECT 
    category,
    pizza_name,
    total_revenue
FROM (
    SELECT 
        pt.category,
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


