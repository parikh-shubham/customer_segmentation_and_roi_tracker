-- 1. Creating Orders Table

IF OBJECT_ID ('orders', 'U') IS NOT NULL
	DROP TABLE orders;
CREATE TABLE orders (
	orders_id INT PRIMARY KEY,
	customer_id INT,
	order_date DATE,
	amount DECIMAL(18, 2),
	category VARCHAR(100),
	channel VARCHAR(100),
	status VARCHAR(50)
);

-- 2. Creating Responses Table

IF OBJECT_ID ('reponses', 'U') IS NOT NULL
	DROP TABLE responses;
CREATE TABLE responses (
	responses_id INT PRIMARY KEY,
	campaign_id INT,
	customer_id INT,
	sent INT,
	opened INT,
	clicked INT,
	converted INT,
	revenue_generated DECIMAL(18, 2)
);

-- 3. Creating Customer Segment Table

IF OBJECT_ID ('customers') IS NOT NULL
	DROP TABLE customers;
CREATE TABLE customers (
	customer_id INT PRIMARY KEY,
	name VARCHAR(255),
	email VARCHAR(255),
	city VARCHAR(100),
	signup_channel VARCHAR(100),
	signup_date DATE,
	age INT,
	gender VARCHAR(10),
	recency FLOAT NULL,
	frequency FLOAT NULL,
	monetary DECIMAL(18,2) NULL,
	RFM_score FLOAT NULL,
	rfm_segment VARCHAR(100) NULL,
	cluster FLOAT NULL,
	segment_label VARCHAR(100) NULL
);

-- 4. Creating rfm_clustered Table

IF OBJECT_ID ('rfm', 'U') IS NOT NULL
	DROP TABLE rfm;
CREATE TABLE rfm(
	customer_id INT PRIMARY KEY,
	last_order_date DATE,
	frequency INT,
	monetary DECIMAL(18,2),
	recency INT,
	R_score INT,
	F_score INT,
	M_score INT,
	RFM_score INT,
	rfm_segment VARCHAR(100),
	cluster INT,
	segment_label VARCHAR(100)
);

-- 5. Creating Campaign Table

IF OBJECT_ID ('campaigns', 'U') IS NOT NULL
	DROP TABLE campaigns;
CREATE TABLE campaigns(
	campaign_id INT PRIMARY KEY,
	campagin_name VARCHAR(255),
	channel VARCHAR(100),
	start_date DATE,
	end_date DATE,
	budget_inr DECIMAL(18,2),
	target_segment VARCHAR(100)
);