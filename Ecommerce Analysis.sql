-- Total Orders
SELECT COUNT(order_id) FROM `bigquery-public-data.thelook_ecommerce.orders`;

-- Unique Customers
SELECT COUNT(DISTINCT id) as num_cust FROM `bigquery-public-data.thelook_ecommerce.users`;

-- Order Status' and num orders in each
SELECT status, COUNT(order_id) as num_order FROM `bigquery-public-data.thelook_ecommerce.orders` GROUP BY status ORDER BY num_order DESC;

-- Number of products in each category
SELECT category, COUNT(id) as num_products FROM `bigquery-public-data.thelook_ecommerce.products` GROUP BY category ORDER BY num_products DESC;

-- Average Retail price by category
SELECT ROUND(AVG(retail_price),2) as avg_price, category FROM `bigquery-public-data.thelook_ecommerce.products` GROUP BY category ORDER BY avg_price DESC;

-- Traffic Sources bringing most users
SELECT traffic_source, COUNT(*) as num_users FROM `bigquery-public-data.thelook_ecommerce.users` GROUP BY traffic_source ORDER BY num_users DESC;

-- Top 10 most expensive products by retail price
SELECT name, retail_price FROM `bigquery-public-data.thelook_ecommerce.products` 
ORDER BY retail_price DESC
LIMIT 10;

-- Number of Orders created each year
SELECT EXTRACT(YEAR FROM created_at) as year, COUNT(order_id) as num_orders FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY year
ORDER BY year DESC;

-- Total revenue generated from sold order items
SELECT SUM(sale_price) as tot_rev FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status<>'Cancelled' AND status<>'Returned';

-- Revenue by product category
SELECT category, SUM(sale_price) as rev FROM `bigquery-public-data.thelook_ecommerce.order_items` as a
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` as b ON a.product_id=b.id
WHERE status<>'Cancelled' AND status<>'Returned'
GROUP BY category
ORDER BY rev DESC;

-- Top 10 Brands by revenue
SELECT brand, SUM(sale_price) as rev FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` as p ON oi.product_id=p.id
WHERE status NOT IN ('Cancelled','Returned')
GROUP BY brand
ORDER BY rev DESC
LIMIT 10;

-- Monthly Revenue Trend
SELECT EXTRACT(MONTH FROM created_at) as mth, ROUND(SUM(sale_price),2) as rev FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY mth
ORDER BY mth ASC;

-- Average Order Value
WITH avg_num AS (SELECT SUM(sale_price) as tot_rev, COUNT(DISTINCT order_id) as num_orders FROM `bigquery-public-data.thelook_ecommerce.order_items`)
SELECT ROUND(tot_rev/num_orders, 2) as aov FROM avg_num;

-- Top 10 customers by spend
SELECT SUM(sale_price) as rev, user_id FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` as u ON u.id=oi.user_id
GROUP BY user_id
ORDER BY rev DESC
LIMIT 10;

-- Revenue by traffic source
SELECT SUM(sale_price) as rev, traffic_source FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` as u ON u.id=oi.user_id
GROUP BY traffic_source
ORDER BY rev DESC;

-- Age group generating most revenue
WITH grped_users AS (SELECT CASE WHEN age BETWEEN 12 AND 20 THEN 'Gen Z'
WHEN age BETWEEN 21 AND 30 THEN 'Millennial'
WHEN age BETWEEN 31 AND 40 THEN 'Gen X'
WHEN age BETWEEN 41 AND 50 THEN 'Baby Boomer'
WHEN age BETWEEN 51 AND 60 THEN 'Older'
ELSE 'Silent Generation'
END AS age_grp, age, id, first_name, last_name
FROM `bigquery-public-data.thelook_ecommerce.users`)
SELECT age_grp, SUM(sale_price) as rev FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN grped_users as u ON u.id=oi.user_id
GROUP BY age_grp
ORDER BY rev DESC;

-- Top 10 products by quantity sold
SELECT SUM(num_of_item) as qty_sold, SUM(sale_price) as rev, name FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` as o ON o.order_id=oi.order_id
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` as p ON p.id=oi.product_id
WHERE oi.status<>'Cancelled' AND oi.status<>'Returned'
GROUP BY name
ORDER BY qty_sold DESC
LIMIT 10;

-- Countries with most customers who placed orders
SELECT country, COUNT(*) as num_customers FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` as u ON u.id=oi.user_id
GROUP BY country
ORDER BY num_customers DESC;

-- Countries with most users
SELECT country, COUNT(*) as num_customers FROM `bigquery-public-data.thelook_ecommerce.users` 
GROUP BY country
ORDER BY num_customers DESC;

-- Cancellation/Return Items
SELECT status, COUNT(*) as dist FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status IN ('Cancelled','Returned')
GROUP BY status;

-- Categories with highest average discount from retail price to sale price
SELECT
  p.category,
  ROUND(AVG(p.retail_price - oi.sale_price), 2) AS avg_discount
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
GROUP BY p.category
ORDER BY avg_discount DESC;

-- Repeat Purchase Rate
WITH count_order AS (SELECT u.id, COUNT(*) as num_order FROM `bigquery-public-data.thelook_ecommerce.orders` as oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` as u ON u.id=oi.user_id
WHERE status NOT IN ('Cancelled','Returned')
GROUP BY id
ORDER BY num_order DESC)
SELECT (SELECT COUNT(DISTINCT id) FROM count_order WHERE num_order>1) as repeat_cus, (SELECT COUNT(DISTINCT id) FROM count_order) as total_cus, ((SELECT COUNT(DISTINCT id) FROM count_order WHERE num_order>1)/(SELECT COUNT(DISTINCT id) FROM count_order))*100 as repeat_purchase_rate FROM count_order LIMIT 1;

-- Rank top 3 products by revenue in each category
WITH grped AS (SELECT category, p.id, name, SUM(sale_price) as rev FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi INNER JOIN `bigquery-public-data.thelook_ecommerce.products` as p ON oi.product_id=p.id
GROUP BY category, p.id, name), 
ranked AS (SELECT category, name, DENSE_RANK() OVER (PARTITION BY category ORDER BY rev DESC) as ranker FROM grped)
SELECT * FROM ranked WHERE ranker<=3;

-- Month over month revenue growth
WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC(DATE(created_at), MONTH) AS month,
    SUM(sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY month
)
SELECT
  month,
  ROUND(revenue, 2) AS revenue,
  ROUND(
    LAG(revenue) OVER (ORDER BY month),
    2
  ) AS prev_month_revenue,
  ROUND(
    (revenue - LAG(revenue) OVER (ORDER BY month))
    / LAG(revenue) OVER (ORDER BY month) * 100,
    2
  ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- RFM Customer Summary
WITH customer_metrics AS (
  SELECT
    o.user_id,
    MAX(DATE(o.created_at)) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    ROUND(SUM(oi.sale_price), 2) AS monetary
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  GROUP BY o.user_id
)
SELECT
  user_id,
  DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) AS recency_days,
  frequency,
  monetary
FROM customer_metrics
ORDER BY monetary DESC;

-- Traffic source with highest average customer lifetime value
WITH lifetime AS (SELECT SUM(sale_price) AS lifetime_value, u.id as user_id, traffic_source FROM `bigquery-public-data.thelook_ecommerce.users` as u JOIN `bigquery-public-data.thelook_ecommerce.orders` as o ON u.id=o.user_id JOIN
`bigquery-public-data.thelook_ecommerce.order_items` as oi ON oi.order_id=o.order_id
GROUP BY user_id, traffic_source)
SELECT AVG(lifetime_value) as avg_lft, traffic_source FROM lifetime GROUP BY traffic_source ORDER BY avg_lft DESC;

-- Users with at least 3 orders having highest average order value
WITH order_totals AS (
  SELECT
    o.user_id,
    o.order_id,
    SUM(oi.sale_price) AS order_value
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  GROUP BY o.user_id, o.order_id
),
customer_aov AS (
  SELECT
    user_id,
    COUNT(*) AS num_orders,
    AVG(order_value) AS avg_order_value
  FROM order_totals
  GROUP BY user_id
)
SELECT
  user_id,
  num_orders,
  ROUND(avg_order_value, 2) AS avg_order_value
FROM customer_aov
WHERE num_orders >= 3
ORDER BY avg_order_value DESC
LIMIT 20;

-- Top category purchase by each traffic source
WITH grping AS (SELECT u.traffic_source, p.category, SUM(sale_price) as rev FROM `bigquery-public-data.thelook_ecommerce.users` as u INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` o ON o.user_id=u.id INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` as oi ON oi.order_id=o.order_id INNER JOIN `bigquery-public-data.thelook_ecommerce.products` as p ON p.id=oi.product_id
GROUP BY u.traffic_source, p.category), 
ranked AS (SELECT traffic_source, category, rev, DENSE_RANK() OVER (PARTITION BY traffic_source ORDER BY rev) as ranker FROM grping)
SELECT * FROM ranked WHERE ranker=1 ORDER BY rev DESC;

-- Products sold at most markdown percentage
SELECT
  p.id AS product_id,
  p.name AS product_name,
  p.category,
  ROUND(AVG((p.retail_price - oi.sale_price) / p.retail_price * 100), 2) AS avg_markdown_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE p.retail_price > 0
GROUP BY product_id, product_name, category
ORDER BY avg_markdown_pct DESC
LIMIT 20;

-- Distribution centers handling most inventory items
SELECT d.id as dist, name, COUNT(product_id) as num_products FROM `bigquery-public-data.thelook_ecommerce.inventory_items` as i LEFT JOIN `bigquery-public-data.thelook_ecommerce.distribution_centers` as d ON d.id=i.product_distribution_center_id
GROUP BY dist, name
ORDER BY num_products DESC;

-- Traffic source with best balance of volume and value
WITH source_metrics AS (
  SELECT
    u.traffic_source,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.user_id) AS customers,
    SUM(oi.sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.users` u
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON u.id = o.user_id
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  GROUP BY u.traffic_source
)
SELECT
  traffic_source,
  customers,
  orders,
  ROUND(revenue, 2) AS revenue,
  ROUND(revenue / orders, 2) AS revenue_per_order,
  ROUND(revenue / customers, 2) AS revenue_per_customer
FROM source_metrics
ORDER BY revenue DESC;

-- Categories with high sales volume but low average selling price
SELECT
  p.category,
  COUNT(*) AS units_sold,
  ROUND(AVG(oi.sale_price), 2) AS avg_selling_price,
  ROUND(SUM(oi.sale_price), 2) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
GROUP BY p.category
ORDER BY units_sold DESC, avg_selling_price ASC;

-- Customers at risk of churn based on recency
WITH customer_summary AS (
  SELECT
    o.user_id,
    MAX(DATE(o.created_at)) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.sale_price) AS total_spent
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  GROUP BY o.user_id
)
SELECT
  user_id,
  DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) AS days_since_last_order,
  total_orders,
  ROUND(total_spent, 2) AS total_spent
FROM customer_summary
WHERE DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) > 180
ORDER BY total_spent DESC;


