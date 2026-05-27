-- 1. Segment Size and Revenue Share

SELECT
	c.segment_label,
	COUNT(c.customer_id) AS total_customers,
	ROUND(SUM(o.amount), 0) AS total_revenue,
	ROUND(AVG(o.amount), 2) AS avg_order_value,
	ROUND(SUM(o.amount)*100.0/ (SUM(SUM(o.amount)) OVER()), 2) AS reveune_share_pct
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.segment_label
ORDER BY total_revenue DESC;

-- 2. RFM Averages per Cluster

SELECT
	segment_label,
	COUNT(customer_id) AS total_customers,
	ROUND(AVG(recency), 1) AS avg_recency_days,
	ROUND(AVG(frequency), 1) AS avg_orders,
	ROUND(AVG(monetary), 0) AS avg_lifetime_spend,
	ROUND(AVG(RFM_score), 1) AS avg_rfm_score
FROM rfm
GROUP BY segment_label
ORDER BY avg_rfm_score DESC;

-- 3. Monthly Revenue Trend

SELECT
	FORMAT(CAST(order_date AS DATE), 'yyyy-MM') AS year_month,
	COUNT(DISTINCT customer_id) AS unique_buyers,
	COUNT(orders_id) AS total_orders,
	ROUND(SUM(amount), 0) AS total_revenue,
	ROUND(AVG(amount), 2) AS avg_order_value
FROM orders
GROUP BY FORMAT(CAST(order_date AS DATE), 'yyyy-MM')
ORDER BY year_month;

-- 4. Revenue By Category per Segment

SELECT
	c.segment_label,
	o.category,
	COUNT(o.orders_id) AS order_count,
	ROUND(SUM(o.amount), 0) AS total_revenue,
	ROUND(AVG(o.amount), 2) AS avg_order_value
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY c.segment_label, o.category
ORDER BY c.segment_label, total_revenue DESC;

-- 5. Top 10% customers by Revenue

WITH ranked AS (
	SELECT
		c.customer_id,
		c.segment_label,
		c.city,
		SUM(o.amount) AS lifetime_value,
		COUNT(o.orders_id) AS total_orders,
		NTILE(10) OVER(ORDER BY SUM(o.amount) DESC) AS decile
	FROM customers AS c
	LEFT JOIN orders AS o ON c.customer_id = o.customer_id
	GROUP BY c.customer_id, c.segment_label, c.city
)

SELECT
	*
FROM ranked
WHERE decile = 1
ORDER BY lifetime_value DESC

-- 6. Customer Acquisition by Signup Channel per Segment

SELECT
	signup_channel,
	segment_label,
	COUNT(customer_id) AS customers_acquired
FROM customers
WHERE segment_label IS NOT NULL
GROUP BY signup_channel, segment_label
ORDER BY signup_channel, customers_acquired DESC;

-- 7. Purchase Frequency Distribution

SELECT
	c.segment_label,
	r.frequency,
	COUNT(r.customer_id) AS total_customers
FROM rfm AS r
LEFT JOIN customers AS c ON r.customer_id = c.customer_id
GROUP BY c.segment_label, r.frequency
ORDER BY c.segment_label, r.frequency;

-- 8. City Wise Revenue And Segment Breakdown

SELECT
	c.city,
	c.segment_label,
	COUNT(DISTINCT c.customer_id) AS customers,
	ROUND(SUM(o.amount), 0) AS revenue
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.city, c.segment_label
ORDER BY c.city, revenue DESC;