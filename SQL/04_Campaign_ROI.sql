-- 1. Overall Campaign Performance Summary

SELECT
	c.campaign_id,
	c.campagin_name,
	c.channel,
	c.budget_inr,
	COUNT(r.responses_id) AS emails_sent,
	SUM(CAST(r.opened AS INT)) AS total_opens,
	SUM(CAST(r.clicked AS INT)) AS total_clicked,
	SUM(CAST(r.converted AS INT)) AS total_converted,
	ROUND(SUM(CAST(r.opened AS INT))*100.0/NULLIF(COUNT(r.responses_id),0), 2) AS open_rate_pct,
	ROUND(SUM(CAST(r.clicked AS INT))*100.0/NULLIF(COUNT(r.opened), 0),2) AS clicked_pct,
	ROUND(SUM(CAST(r.converted AS INT))*100.0/NULLIF(COUNT(r.clicked), 0), 2) AS conversion_rate_pct,
	ROUND(SUM(r.revenue_generated), 0) AS total_revenue,
	ROUND(SUM(r.revenue_generated) - c.budget_inr, 0) AS net_profit,
	ROUND((SUM(r.revenue_generated) - c.budget_inr)*100/NULLIF(c.budget_inr, 0), 0) AS roi_pct,
	ROUND(CAST(c.budget_inr AS FLOAT)/NULLIF(COUNT(r.converted), 0), 2) AS cac_inr
FROM campaigns AS c
LEFT JOIN responses AS r ON c.campaign_id = r.campaign_id
GROUP BY c.campaign_id, c.campagin_name, c.channel, c.budget_inr
ORDER BY roi_pct DESC;

-- 2. Campaign ROI Broken Down by Customer Segment

SELECT 
	camp.campagin_name,
	camp.channel,
	c.segment_label,
	COUNT(r.responses_id) AS reached,
	SUM(r.converted) AS conversaions, 
	ROUND(100.0*SUM(r.converted)/NULLIF(COUNT(r.responses_id), 0), 2) AS conversion_rate_pct,
	ROUND(SUM(r.revenue_generated), 0) AS reveune_generated,
	ROUND(AVG(r.revenue_generated), 2) AS avg_reveune_per_response
FROM responses AS r
JOIN campaigns AS camp ON r.campaign_id = camp.campaign_id
JOIN customers AS c ON r.customer_id = c.customer_id
GROUP BY camp.campagin_name, camp.channel, c.segment_label
ORDER BY camp.campagin_name, reveune_generated DESC;

-- 3. Best Performing Campaign per Segment

WITH ranked_campaigns AS (
	SELECT
		c.segment_label,
		camp.campagin_name,
		camp.channel,
		SUM(r.converted) AS conversions,
		ROUND(SUM(r.revenue_generated), 0) AS revenue,
		ROUND(100.0*SUM(r.converted)/NULLIF(COUNT(r.responses_id), 0), 2) AS conversion_rate_pct,
		ROW_NUMBER() OVER(PARTITION BY c.segment_label ORDER BY SUM(r.revenue_generated) DESC) AS rn
	FROM responses AS r
	JOIN campaigns AS camp ON r.campaign_id = camp.campaign_id
	JOIN customers AS c ON r.customer_id = c.customer_id
	GROUP BY c.segment_label, camp.campagin_name, camp.channel
)

SELECT
	segment_label,
	campagin_name AS best_campaign,
	channel,
	conversions,
	revenue,
	conversion_rate_pct
FROM ranked_campaigns
WHERE rn = 1
ORDER BY revenue DESC;

-- 4. CAC by Channel Across all Campaigns

SELECT
	c.channel, 
	SUM(c.budget_inr) AS total_spend,
	SUM(r.converted) AS total_conversions,
	ROUND(CAST(SUM(c.budget_inr) AS FLOAT)/NULLIF(SUM(r.converted), 0), 2) AS cac_inr,
	ROUND((SUM(r.revenue_generated) - SUM(c.budget_inr))*100.0/NULLIF(SUM(c.budget_inr), 0), 2) AS roi_pct
FROM campaigns AS c
JOIN responses AS r ON c.campaign_id = r.campaign_id
GROUP BY c.channel
ORDER BY roi_pct DESC;

-- 5. Reveune Concentration: Top 20% is driving what % of revenue

WITH customer_revenue AS (
	SELECT
		customer_id,
		SUM(amount) AS total_spend,
		NTILE(5) OVER(ORDER BY SUM(amount) DESC) AS quintile
	FROM orders
	GROUP BY customer_id
)

SELECT
	quintile,
	COUNT(customer_id) AS total_customers,
	ROUND(SUM(total_spend), 0) AS total_revenue,
	ROUND(SUM(total_spend)*100.0/SUM(SUM(total_spend)) OVER(), 2) AS revenue_share_pct
FROM customer_revenue
GROUP BY quintile
ORDER BY quintile;

-- 6. Month-Over-Month Campaign ROI Trend

SELECT
	FORMAT(CAST(c.start_date AS DATE), 'yyyy-MM') AS campaign_month,
	c.channel,
	ROUND(SUM(r.revenue_generated), 0) AS revenue,
	ROUND((SUM(r.revenue_generated) - SUM(c.budget_inr))/NULLIF(SUM(c.budget_inr), 0)*100, 2) AS roi_pct
FROM campaigns AS c
JOIN responses AS r ON c.campaign_id = r.campaign_id
GROUP BY FORMAT(CAST(c.start_date AS DATE), 'yyyy-MM'), c.channel
ORDER BY campaign_month;

-- 7. Segment-Level Email Engagement Funnel

SELECT
	c.signup_channel,
	c.segment_label,
	COUNT(r.responses_id) AS sent,
	SUM(r.opened) AS opened,
	SUM(r.clicked) AS clicked,
	SUM(r.converted) AS converted,
	ROUND(100.0*SUM(r.opened)/NULLIF(COUNT(responses_id), 0), 1) AS open_rate_pct,
	ROUND(100.0*SUM(r.clicked)/NULLIF(SUM(r.opened), 0), 1) AS click_rate_pct,
	ROUND(100.0*SUM(r.converted)/NULLIF(SUM(r.clicked), 0), 1) AS convert_rate_pct
FROM responses AS r
JOIN customers AS c ON r.customer_id = c.customer_id
WHERE c.signup_channel = 'Email'
GROUP BY c.signup_channel, c.segment_label
ORDER BY convert_rate_pct DESC;