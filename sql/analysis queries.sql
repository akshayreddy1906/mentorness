-- Q1: The total number of orders placed        
SELECT COUNT(order_id) 
AS "Total orders"
FROM orders;

-- Q2: The total revenue generated from pizza sales
SELECT SUM(o.quantity * p.price) AS "Total Revenue"
FROM order_details o 
JOIN pizza p 
ON o.pizza_id = p.pizza_id;

-- Q3: The highest priced pizza
SELECT price AS "highest price",pizza_id
FROM pizza 
ORDER BY price DESC 
LIMIT 1;

-- Q4: The most common pizza size ordered
SELECT p.size, COUNT(*) AS count
FROM order_details o 
JOIN pizza p 
ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY count DESC
LIMIT 1;

-- Q5: The top 5 most ordered pizza types along their quantities
SELECT p.pizza_type_id, sum(o.quantity) AS quantity
FROM order_details o 
JOIN pizza p 
ON o.pizza_id = p.pizza_id
GROUP BY p.pizza_type_id
ORDER BY quantity DESC
LIMIT 5;
 
-- Q6: The quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Q7: The distribution of orders by hours of the day
SELECT EXTRACT(HOUR FROM time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY hour
ORDER BY hour;

-- Q8: The category-wise distribution of pizzas
SELECT pt.category, COUNT(p.pizza_id) AS pizza_count
FROM pizza p
JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Q9: The average number of pizzas ordered per day
SELECT AVG(daily_order_count) AS avg_pizzas_per_day
FROM (
    SELECT COUNT(od.quantity) AS daily_order_count
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY o.date
) daily_orders;

-- Q10: Top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Q11: The percentage contribution of each pizza type to revenue
WITH category_revenue AS (
    SELECT
        pt.category,
        SUM(od.quantity * p.price) AS category_total
    FROM
        pizza_type pt
        JOIN pizza p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY  
        pt.category
),
total_revenue AS (
    SELECT SUM(category_total) AS total
    FROM category_revenue
)
SELECT
    cr.category,
    ROUND((cr.category_total / tr.total * 100), 2) AS percentage_of_total_revenue
FROM
    category_revenue cr,
    total_revenue tr
ORDER BY
    percentage_of_total_revenue DESC;


-- Q12: The cumulative revenue generated over time
SELECT o.date, SUM(od.quantity * p.price) OVER (ORDER BY o.date) AS cumulative_revenue
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN pizza p ON od.pizza_id = p.pizza_id
ORDER BY o.date;

-- Q13: The top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, name, total_revenue 
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS `rank`
    FROM order_details od
    JOIN pizza p ON od.pizza_id = p.pizza_id
    JOIN pizza_type pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked 
WHERE `rank` <= 3  
ORDER BY category, total_revenue DESC;

