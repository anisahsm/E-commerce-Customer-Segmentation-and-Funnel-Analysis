SELECT *
FROM customers;

SELECT *
FROM sessions;

SELECT *
FROM transactions;

-- Check Duplicates
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER () OVER (
PARTITION BY customer_id, signup_date, age, gender, country, segment, is_churned, lifetime_value, email_opt_in, has_app) AS row_num
FROM customers 
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

SELECT customer_id,
COUNT(customer_id)
FROM customers
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

SELECT session_id,
COUNT(session_id)
FROM sessions
GROUP BY session_id
HAVING COUNT(session_id) > 1;

SELECT transaction_id,
COUNT(transaction_id)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(transaction_id) > 1;


-- CUSTOMERS --

SELECT *
FROM customers;

-- First and Last Signup Date
SELECT
MIN(signup_date),
MAX(signup_date)
FROM customers;

-- 1. CUSTOMER PROFILE

-- Total Customers
SELECT 
COUNT(customer_id) AS total_customers
FROM customers;

-- Total Customer by Gender
SELECT
gender,
COUNT(gender) AS total_customers
FROM customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total Customer by Country
SELECT
country,
COUNT(country) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC;

-- Age
SELECT
AVG(age) AS avg_age,
min(age) AS min_age,
max(age) AS max_age
FROM customers;

-- 2. RFM ANALYSIS

WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF('2025-01-31', MAX(transaction_date)) AS recency,
        COUNT(transaction_id) AS frequency,
        ROUND(SUM(total_amount - (total_amount * discount_applied/100)), 2) AS monetary
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC,  customer_id) AS r_score,   -- 5 = bought most recently
        NTILE(5) OVER (ORDER BY frequency ASC, customer_id) AS f_score,   -- 5 = buys most often
        NTILE(5) OVER (ORDER BY monetary ASC,  customer_id) AS m_score    -- 5 = spends the most
    FROM customer_rfm
),
segmented AS (
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE
		WHEN r_score >= 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
		WHEN r_score >= 3 AND f_score >= 4 AND m_score >= 3 THEN 'Loyal Customers'
		WHEN r_score >= 4 AND f_score >= 2                  THEN 'Potential Loyalists'
		WHEN r_score = 5  AND f_score = 1                   THEN 'New Customers'
		WHEN r_score = 4  AND f_score = 1                   THEN 'Promising'
		WHEN r_score = 3  AND (f_score >= 3 OR m_score >= 3) THEN 'Need Attention'
		WHEN r_score = 3                                    THEN 'About to Sleep'
		WHEN r_score <= 2 AND f_score = 5 AND m_score >= 4 THEN 'Can''t Lose Them'
		WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) THEN 'At Risk'
		ELSE 'Hibernating'
    END AS customer_segment
FROM rfm_scores
ORDER BY customer_id)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS pct_customers,
    ROUND(SUM(monetary), 2) AS revenue,
    ROUND(SUM(monetary) * 100 / SUM(SUM(monetary)) OVER (), 1) AS pct_revenue
FROM segmented
GROUP BY customer_segment
ORDER BY customers DESC;

-- Create New RFM Table

CREATE TABLE rfmsegment AS
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF('2025-01-31', MAX(transaction_date)) AS recency,
        COUNT(transaction_id) AS frequency,
        ROUND(SUM(total_amount - (total_amount * discount_applied/100)), 2) AS monetary
    FROM transactions
    WHERE status = 'completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC,  customer_id) AS r_score,   -- 5 = bought most recently
        NTILE(5) OVER (ORDER BY frequency ASC, customer_id) AS f_score,   -- 5 = buys most often
        NTILE(5) OVER (ORDER BY monetary ASC,  customer_id) AS m_score    -- 5 = spends the most
    FROM customer_rfm
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE
		WHEN r_score >= 5 AND f_score >= 4 AND m_score >= 4 	THEN 'Champions'
		WHEN r_score >= 3 AND f_score >= 4 AND m_score >= 3 	THEN 'Loyal Customers'
		WHEN r_score >= 4 AND f_score >= 2                  	THEN 'Potential Loyalists'
		WHEN r_score = 5  AND f_score = 1                   	THEN 'New Customers'
		WHEN r_score = 4  AND f_score = 1                   	THEN 'Promising'
		WHEN r_score = 3  AND (f_score >= 3 OR m_score >= 3) 	THEN 'Need Attention'
		WHEN r_score = 3                                    	THEN 'About to Sleep'
		WHEN r_score <= 2 AND f_score = 5 AND m_score >= 4 		THEN 'Can''t Lose Them'
		WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) 	THEN 'At Risk'
		ELSE 'Hibernating'
    END AS customer_segment
FROM rfm_scores
ORDER BY customer_id;

SELECT *
FROM rfmsegment;

-- Create New Customer Table

CREATE TABLE customers_new AS
SELECT
c.*,
r.customer_segment
FROM customers c
LEFT JOIN rfmsegment r 
ON c.customer_id = r.customer_id;

ALTER TABLE customers_new
RENAME COLUMN customer_segment TO rfm_segment;

SELECT *
FROM customers_new;

ALTER TABLE customers_new
ADD COLUMN age_group VARCHAR(50);

UPDATE customers_new
SET age_group = CASE
	WHEN age BETWEEN 10 AND 19 THEN '10-19'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
    WHEN age BETWEEN 50 AND 59 THEN '50-59'
    WHEN age BETWEEN 60 AND 69 THEN '60-69'
    WHEN age BETWEEN 70 AND 79 THEN '70-79'
END;

CREATE OR REPLACE VIEW customer AS
SELECT *
FROM customers_new;

CREATE OR REPLACE VIEW rfm_segment AS
SELECT *
FROM rfmsegment;

-- Total Customer by RFM Segment
SELECT
rfm_segment,
COUNT(customer_id) AS total_customer
FROM customers_new
GROUP BY rfm_segment
ORDER BY total_customer DESC;

-- Total Customer by Age Group
SELECT
age_group,
COUNT(*) AS total_customers
FROM customers_new
GROUP BY age_group
ORDER BY age_group;

-- 3. TRANSACTION

-- Status Transaction
SELECT
status,
COUNT(transaction_id) AS total_transaction
FROM transactions
GROUP BY status;

-- Total Revenue
SELECT
SUM(total_amount - (total_amount * discount_applied/100.0)) AS net_revenue
FROM transactions
WHERE status = "completed";

-- Total Revenue by RFM Segment
SELECT
rfm_segment,
SUM(total_amount - (total_amount * discount_applied/100.0)) AS net_revenue
FROM transactions t
JOIN customers_new c
ON t.customer_id = c.customer_id
WHERE status = "completed"
GROUP BY rfm_segment
ORDER BY net_revenue DESC;

-- Create New Transaction Table

CREATE TABLE transactions_new
LIKE transactions;

INSERT transactions_new
SELECT *
FROM transactions;

CREATE VIEW transaction AS
SELECT *
FROM transactions_new;

ALTER TABLE transactions_new
ADD COLUMN total_paid bigint;

ALTER TABLE transactions_new
MODIFY COLUMN total_paid DECIMAL(12,2);

UPDATE transactions_new
SET total_paid = total_amount - (total_amount * discount_applied/100.0);

ALTER TABLE transactions_new
ADD COLUMN yearmonth DATE;

UPDATE transactions_new
SET yearmonth = DATE_FORMAT(transaction_date, '%Y-%m-01');

-- AOV
SELECT
ROUND(AVG(total_paid),2) AS aov
FROM transactions_new
WHERE status = "completed";

-- Average Purchase Frequency
SELECT
COUNT(transaction_id)/COUNT(DISTINCT customer_id) AS apf
FROM transactions_new
WHERE status = "completed";

-- Average LTV
SELECT 
SUM(total_paid)/COUNT(DISTINCT customer_id) AS ltv
FROM transactions_new
WHERE status = "completed";

-- Average LTV by rfm_segment
SELECT
rfm_segment, 
SUM(total_paid)/COUNT(DISTINCT t.customer_id) AS ltv
FROM transactions_new t
JOIN customers_new c
ON t.customer_id = c.customer_id
WHERE status = "completed"
GROUP BY rfm_segment
ORDER BY ltv DESC;

-- 4. CHURN

-- Total Customer by Churned
SELECT
is_churned,
COUNT(is_churned) AS total_customers
FROM customers
GROUP BY is_churned
ORDER BY total_customers desc;

-- Churn Rate
SELECT
ROUND(SUM(is_churned)*100/COUNT(*),2) AS churn_rate
FROM customers;

-- Churn Rate by RFM Segment
SELECT
rfm_segment,
ROUND(SUM(is_churned)*100/COUNT(*),2) AS churn_rate
FROM customers_new
GROUP BY rfm_segment
ORDER BY churn_rate DESC;

-- SESSIONS --

-- 1. Conversion Rate
SELECT
ROUND(SUM(converted)*100/COUNT(*),2) AS conversion_rate
FROM sessions;

-- 2. Average Session Duration
SELECT
ROUND(AVG(duration_seconds),2) AS avg_duration
FROM sessions;

-- 3. Average Pages Viwed
SELECT
ROUND(AVG(pages_viewed),2) AS avg_pagesviewed
FROM sessions;

-- 4. Average Cart Additions
SELECT
ROUND(AVG(cart_additions),2) AS avg_cartadditions
FROM sessions;

-- 5. SESSIONS BY CONVERTED
SELECT
converted,
COUNT(session_id) AS total_session,
COUNT(distinct customer_id) AS total_customer,
ROUND(AVG(duration_seconds),2) AS avg_duration,
ROUND(AVG(pages_viewed),2) AS avg_pageviewed,
ROUND(AVG(cart_additions),2) AS avg_cartadditions,
SUM(CASE WHEN cart_additions >= 1 THEN 1 END) AS cart_sessions
FROM sessions
GROUP BY converted;

-- 6. SESSIONS BY RFM SEGMENT
SELECT 
rfm_segment,
ROUND(SUM(converted)*100/COUNT(*),2) AS conversion_rate,
COUNT(session_id) AS total_session,
COUNT(distinct s.customer_id) AS total_customer,
ROUND(AVG(duration_seconds),2) AS avg_duration,
ROUND(AVG(pages_viewed),2) AS avg_pageviewed,
ROUND(AVG(cart_additions),2) AS avg_cartadditions
FROM sessions s
JOIN customers_new c 
ON s.customer_id = c.customer_id
GROUP BY rfm_segment
ORDER BY total_session DESC;


-- FUNNEL ANALYSIS --

SELECT *
FROM sessions;

SELECT 
converted,
bounced,
COUNT(*) AS total_sessions
FROM sessions
GROUP BY converted, bounced;

SELECT
CASE 
	WHEN cart_additions > 0 AND converted = 1 THEN 'Cart + Converted'
	WHEN cart_additions > 0 AND converted = 0 THEN 'Cart + Not Converted'
	WHEN cart_additions = 0 AND converted = 1 THEN 'No Cart + Converted'
	ELSE 'No Cart + Not Converted'
END AS customer_behavior,
COUNT(*) AS total_sessions
FROM sessions
GROUP BY customer_behavior
ORDER BY total_sessions;

SELECT
COUNT(*) AS cart_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_cart_session,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)*100/ NULLIF(COUNT(*),0),2) AS cart_conversion_pct,
SUM(CASE WHEN converted = 0 THEN 1 ELSE 0 END) AS non_converted_cart_session,
ROUND(SUM(CASE WHEN converted = 0 THEN 1 ELSE 0 END)*100/ NULLIF(COUNT(*),0),2) AS cart_nonconversion_pct
FROM sessions
WHERE cart_additions > 0;

-- FUNNEL PERFORMANCE

SELECT
COUNT(*) AS total_sessions,
SUM(CASE WHEN pages_viewed > 0 THEN 1 ELSE 0 END) AS sessions_with_page_viewed,
SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END) AS sessions_with_cart_additions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions
FROM sessions;

WITH funnel AS (
SELECT
COUNT(*) AS total_sessions,
SUM(CASE WHEN pages_viewed > 0 THEN 1 ELSE 0 END) AS explored_sessions,
SUM(CASE WHEN cart_additions > 0 THEN 1 ELSE 0 END) AS cart_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions
FROM sessions)
SELECT
total_sessions,
explored_sessions,
cart_sessions,
converted_sessions,
ROUND(explored_sessions/total_sessions*100,2) AS explored_pct,
ROUND(cart_sessions/explored_sessions*100,2) AS cart_pct,
ROUND(converted_sessions/cart_sessions*100,2) AS converted_pct,
ROUND((total_sessions - converted_sessions)/total_sessions*100,2) AS overall_nonconverted_pct
FROM funnel;

SELECT
COUNT(*) AS total_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)*100,2) AS converted_rate
FROM sessions;

-- FUNNEL PERFORMANCE BY CUSTOMER SEGMENT

SELECT
rfm_segment,
COUNT(*) AS total_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)*100,2) AS converted_rate
FROM sessions s
JOIN customers_new c
ON s.customer_id = c.customer_id
GROUP BY rfm_segment
ORDER BY converted_rate DESC;

-- FUNNEL PERFORMANCE BY AGE GROUP

SELECT
age_group,
COUNT(*) AS total_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)*100,2) AS converted_rate
FROM sessions s
JOIN customers_new c
ON s.customer_id = c.customer_id
GROUP BY age_group
ORDER BY converted_rate DESC;

-- FUNNEL PERFORMANCE BY GENDER

SELECT
gender,
COUNT(*) AS total_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)*100,2) AS converted_rate
FROM sessions s
JOIN customers_new c
ON s.customer_id = c.customer_id
GROUP BY gender
ORDER BY converted_rate DESC;

-- FUNNEL PERFORMANCE BY COUNTRY

SELECT
country,
COUNT(*) AS total_sessions,
SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)*100,2) AS converted_rate
FROM sessions s
JOIN customers_new c
ON s.customer_id = c.customer_id
GROUP BY country
ORDER BY converted_rate DESC;


