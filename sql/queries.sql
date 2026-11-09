
-- ==========================================
-- INSTAMART CUSTOMER INTELLIGENCE CAPSTONE
-- PART A: SQL ANALYSIS
-- ==========================================


-- QUERY 1: High-value customers

SELECT
    customer_id,
    SUM(order_amount) AS total_amount
FROM orders
WHERE status = 'completed'
AND order_amount > 500
GROUP BY customer_id
HAVING SUM(order_amount) > 8000;


-- QUERY 2: City-wise category revenue

SELECT
    c.city,
    p.category,
    SUM(o.order_amount) AS total_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON o.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY c.city, p.category
ORDER BY c.city, p.category;


-- QUERY 3: Products priced above average

SELECT
    product_id,
    product_name,
    category,
    price_inr
FROM products
WHERE price_inr > (
    SELECT AVG(price_inr)
    FROM products
)
ORDER BY price_inr DESC;


-- QUERY 4: Customers without completed orders

SELECT
    c.customer_id,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
WHERE o.order_id IS NULL;


-- QUERY 5: Customers spending above average

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spending
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),

average_spending AS (
    SELECT AVG(total_spending) AS avg_spending
    FROM customer_spending
)

SELECT
    cs.customer_id,
    cs.total_spending
FROM customer_spending cs
CROSS JOIN average_spending av
WHERE cs.total_spending > av.avg_spending
ORDER BY cs.total_spending DESC;


-- QUERY 6: Customer ranking within each city

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.city,
        SUM(o.order_amount) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.status = 'completed'
    GROUP BY c.customer_id, c.city
)

SELECT
    customer_id,
    city,
    total_spending,

    RANK() OVER (
        PARTITION BY city
        ORDER BY total_spending DESC
    ) AS rank_position,

    DENSE_RANK() OVER (
        PARTITION BY city
        ORDER BY total_spending DESC
    ) AS dense_rank_position,

    ROW_NUMBER() OVER (
        PARTITION BY city
        ORDER BY total_spending DESC
    ) AS row_number_position

FROM customer_spending
ORDER BY city, total_spending DESC;


-- QUERY 7: Daily and cumulative revenue

WITH daily_revenue AS (
    SELECT
        DATE(order_ts) AS day,
        SUM(order_amount) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE(order_ts)
)

SELECT
    day,
    revenue,
    SUM(revenue) OVER (
        ORDER BY day
    ) AS cumulative_revenue
FROM daily_revenue
ORDER BY day;
