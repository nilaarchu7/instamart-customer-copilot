
import sqlite3
import pandas as pd

# Connect to database
conn = sqlite3.connect("../data/instamart.db")

print("INSTAMART PART A - VALIDATION")
print("=" * 40)

# Check 1: Customers table
customers = pd.read_sql_query("SELECT COUNT(*) AS total FROM customers", conn)
print("Check 1 - Customers:", customers.iloc[0, 0])

# Check 2: Products table
products = pd.read_sql_query("SELECT COUNT(*) AS total FROM products", conn)
print("Check 2 - Products:", products.iloc[0, 0])

# Check 3: Orders table
orders = pd.read_sql_query("SELECT COUNT(*) AS total FROM orders", conn)
print("Check 3 - Orders:", orders.iloc[0, 0])

# Check 4: High-value customers
q1 = pd.read_sql_query("""
SELECT COUNT(*) AS total FROM (
    SELECT customer_id
    FROM orders
    WHERE status = 'completed' AND order_amount > 500
    GROUP BY customer_id
    HAVING SUM(order_amount) > 8000
)
""", conn)
print("Check 4 - High-value customers:", q1.iloc[0, 0])

# Check 5: Products above average price
q3 = pd.read_sql_query("""
SELECT COUNT(*) AS total
FROM products
WHERE price_inr > (SELECT AVG(price_inr) FROM products)
""", conn)
print("Check 5 - Products above average price:", q3.iloc[0, 0])

# Check 6: Customers without completed orders
q4 = pd.read_sql_query("""
SELECT COUNT(*) AS total
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
AND o.status = 'completed'
WHERE o.order_id IS NULL
""", conn)
print("Check 6 - Customers without completed orders:", q4.iloc[0, 0])

# Check 7: Customers spending above average
q5 = pd.read_sql_query("""
WITH spending AS (
    SELECT customer_id, SUM(order_amount) AS total_spending
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT COUNT(*) AS total
FROM spending
WHERE total_spending > (SELECT AVG(total_spending) FROM spending)
""", conn)
print("Check 7 - Above-average spending customers:", q5.iloc[0, 0])

# Check 8: Daily revenue records
q7 = pd.read_sql_query("""
SELECT COUNT(*) AS total
FROM (
    SELECT DATE(order_ts)
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE(order_ts)
)
""", conn)
print("Check 8 - Daily revenue records:", q7.iloc[0, 0])

conn.close()

print("=" * 40)
print("VALIDATION COMPLETED")
