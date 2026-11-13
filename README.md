# E-commerce Customer Segmentation & Funnel Analysis

## Project Overview
Understanding customer behavior and identifying conversion barriers are essential for improving e-commerce business performance.  
This project analyzes customer purchasing behavior and website session activity to uncover patterns in customer value, segmentation, churn status, and conversion performance. Using SQL and Power BI, the analysis transforms raw e-commerce data into actionable business insights through RFM segmentation, customer analysis, and funnel evaluation.

## Key Takeaways
1. Most shopping carts never turn into sales. 76.77% of carts are abandoned, and this depends on the customer (New Customers 88.33%, Champions 70.09%), not the device or channel. That points to fixing the checkout for customers who buy rarely or have lapsed, which would be worth about $56,000 over two years.
2. More than a third of customers have gone quiet. Hibernating and At Risk customers make up 38.24% of customers who have bought, so bringing them back is a clear opportunity. A personal offer for At Risk and Can’t Lose Them customers and a low-cost email for Hibernating customers could be worth about $25,800 at a 10% response rate. Smaller steps support this, such as a second-purchase incentive for New and Promising customers (about $2,600) and a reminder before customers go quiet (about $4,300).
3. A small core of customers carries the revenue. Loyal Customers and Champions bring in $2.86M, so protecting and growing their spend pays off quickly. Perks such as early access or free shipping would be worth about $28,600 for every 1% rise in their spend.

## Business Objectives
- Identify customer segments based on purchasing behavior using RFM analysis.
- Evaluate customer value and revenue contribution across segments.
- Examine churn by segment, and test whether the churn flag overlaps with RFM recency.
- Locate the largest drop-off in the conversion funnel and break it down by driver.
- Translate analytical findings into prioritized, testable actions.

## Dataset Overview
The dataset consists of three interconnected tables:
|Table|Records|Description|
|-----|-------|-----------|
|Customers|10,000|Customer profiles and attributes|
|Transactions|120,000|Customer purchase and transaction records|
|Sessions|80,000|Website activity and conversion data|

Source: [E-commerce Behavior Explorer V2](https://www.kaggle.com/code/lorenzoscaturchio/ecommerce-behavior-explorer-v2) by Lorenzo Scaturchio (Kaggle).

## Key Insights 
### Customer Segmentation & Value
__Over a third of customers have gone quiet__  
Loyal Customers account for 21.1% of the customer base, making them the largest segment. However, Hibernating and At Risk customers together make up 38.2% of customers, indicating that a large part of the customer base is drifting away.  

__The biggest earners and the most valuable customers are different groups__  
Loyal Customers bring in the most revenue ($1.73M). Champions are worth the most per customer, with an average lifetime value of $1,122. Keeping Loyal Customers buying protects today’s revenue, while getting more from Champions raises the value of each customer.  

__Can’t Lose Them customers are valuable but show signs of inactivity__  
They have spent about $1,081 each on average, but haven’t bought for around 186 days (about six months). They are only about 1.8% of customers (171 people), so a personal approach is practical.   

__Promising customers have the highest churn rate, and inactivity doesn’t explain it__  
28.9% of Promising customers are marked as churned, even though all 152 bought within the last 180 days. Hibernating customers follow at 25.3%, which is expected given how long they have been away. Promising customers buy recently but haven’t built a habit yet, which points to an early-stage retention problem worth testing.  
### Funnel Performance & Conversion
__The largest conversion drop-off occurs between cart and purchase__  
Although 46.54% of explored sessions progress to the cart stage, only 23.23% of cart sessions result in a conversion. This brings the overall session conversion rate to 10.81%. The cart-to-purchase stage is the largest conversion bottleneck and a key opportunity for improving funnel performance.  

__Converted sessions demonstrate higher engagement across key metrics__  
Compared with non-converted sessions, converted sessions record:    
•	Pages viewed: 7.70 vs. 6.34  
•	Cart additions: 2.99 vs. 0.60  
•	Session duration: 440.66 vs. 363.29 seconds  
These differences indicate that converted sessions are associated with deeper browsing activity, more cart interactions, and longer engagement.  

__Established customer segments show higher session conversion rates__  
Champions have the highest session conversion rate at 14.67%, followed by Loyal Customers at 13.55% and Can't Lose Them at 13.13%. In comparison, New Customers convert at only 5.05%. Among cart sessions, Champions complete 29.9% and New Customers 11.7%.   

__Cart abandonment depends on customer segment, not on device or channel__  
76.77% of cart sessions end without a purchase. Abandonment is almost the same on every device and traffic channel, but it varies a lot by customer type. It differs by only 1.2 points across devices and 1.6 points across channels, so a checkout bug on one device or a weak traffic source is unlikely to be the cause. By customer segment, the spread is 18.2 points, with the lowest abandonment among Champions (70.09%) and the highest among New Customers (88.3%).  

## Business Recommendations
|No|Action|Target Group|Test Design|Primary KPI|Impact Estimate|Effort|
|--|------|------------|-----------|-----------|---------------|------|
|1|Test checkout changes aimed at low-frequency and lapsing buyers, for example guest checkout, trust signals, clearer shipping costs, and a return-visit incentive|Carts from Hibernating, At Risk, Potential Loyalists and Need Attention customers (about 79% of the gap to Champions’ completion rate)|A/B test the new checkout against the current one|Cart-to-purchase rate: 23.23% → 25.23% (+2 pts)|~745 orders, ~$56,000 ($28,000–$140,000 at +1 to +5 pts)|Medium|
|2|Offer loyalty perks, for example early access, free shipping or points|Loyal Customers and Champions (largest revenue source and highest value per customer)|Perks vs. no-perks holdout|Spend per customer over 90 days|~$28,600 per +1% spend among Loyal Customers and Champions ($14,300–$57,200 at +0.5% to +2%), before perk costs|Medium|
|3|Send win-back offers: a personal offer for Can’t Lose Them and At Risk customers, a low-cost email for Hibernating customers|Can’t Lose Them, At Risk and Hibernating (3,892 customers)|Offer vs. no-offer holdout|60-day reactivation rate|About $25,800 at a 10% response rate ($12,900–$38,600 at 5–15%); At Risk is the largest part (about $14,700)|Low|
|4|Offer a second-purchase incentive 14 days after first order|New and Promising|Offer vs. no-offer holdout|Repeat purchase rate within 60 days|~$2,600 at a 10% response rate (276 customers); $1,300–$3,900 at 5–15%|Low|
|5|Send a reminder nudge to customers 91–180 days after their last purchase, before they go quiet|Customers 91–180 days since last purchase (2,851 customers, 15.4% churn)|Nudge vs. no-nudge holdout|Share who buy again within 60 days|~$4,300 at a 2-point drop in churn (~57 customers kept); $2,100–$6,400 at 1–3 points|Low|

## Limitations
- Synthetic Kaggle dataset: patterns may not reflect a real business.
- Churn flag: its definition is unknown and has not been independently verified. It is not a simple recency cutoff, but it is moderately related to recency (13.1% churn at 0–90 days vs. 24.4% at 366+ days), so segment churn comparisons are partly influenced by inactivity.
- Transactions and sessions table cover 1 January 2023 to 31 December 2024, but converted sessions (about 8,648) are far fewer than transactions (120,000), so the session table is likely a sample or covers only some purchase channels. Session-based figures, including the cart recovery estimate, should not be scaled to all transactions.
- Assumed estimates: Impact estimates rest on assumed improvement and response rates, not measured results. Segment sizes range from 124 to 1,987 customers, so the estimates for the smaller segments are less certain.
- No time-series or cohort analysis: all results are a snapshot.
- Association, not causation: findings on engagement are associations, not causal effects.  

## Dashboard
<img width="6150" height="3525" alt="E-Commerce Customer Segmentation and Funnel Analysis-page-00001" src="https://github.com/user-attachments/assets/f64233e2-eedf-4c34-88fe-d6b0e3885156" />
<img width="6150" height="3525" alt="E-Commerce Customer Segmentation and Funnel Analysis-page-00002" src="https://github.com/user-attachments/assets/feab87af-647d-42b8-9975-49c3ab37e8c6" />

## Appendix
### A. Tools
|Tool|Application|
|----|-----------|
|SQL|Data extraction, transformation, aggregation, and RFM calculations|
|Power BI|Data modeling, DAX calculations, interactive dashboards, and visualization|
|Power Query|Data transformation and preparation|

### B. Analytical Methodology
__1. Data Preparation & Exploration__
- Inspected and explored the customer, transaction, and session datasets.
- Checked for nulls, duplicates, and date inconsistencies and prepared the datasets for analysis.
- Used SQL to extract, aggregate, and organize relevant information.
- Only customers with completed transactions receive RFM scores: 9,730 of the 10,000 customers. The 270 without scores are presumably customers with no completed transactions, and they are excluded from segment percentages.
- Net revenue: completed transaction amount minus discounts.
- Transactions: only transactions with a “complete” status are analyzed.
- Recency: days between each customer’s last completed transaction and 31 January 2025.
- Session conversion: a session flagged as converted.

__2. RFM Customer Segmentation__
- Calculated Recency, Frequency, and Monetary values using completed transaction records.
- Assigned RFM scores to classify customers into behavioral segments.
- Evaluated customer distribution, revenue contribution, and average customer value across segments.

|No|Segment|Business Definition|Rule|
|--|-------|-------------------|----|
|1|Champions|Our best customers. They bought very recently, purchase often, and spend the most.|r = 5, f >= 4, m >= 4|
|2|Loyal|Customers	Dependable repeat buyers who purchase regularly and spend well.|r >= 3, f >= 4, m >= 3|
|3|Potential Loyalists|Recent customers who have purchased more than once and are building a buying habit.|r >= 4, f >= 2|
|4|New Customers|Customers who just made their first purchase, with limited history so far.|r = 5, f = 1|
|5|Promising|Recent first-time buyers who are still warm but haven't formed a habit.|r = 4, f = 1|
|6|Need Attention|Customers with average recency who still show some purchasing value, but whose engagement is starting to slip.|r = 3, and (f >= 3 or m >= 3)|
|7|About to Sleep|Customers with low activity and low spend whose last purchase is getting old. They will be lost without a reminder.|r = 3 (remaining)|
|8|Can't Lose Them|Former top customers (frequent, high spend) who have gone quiet. A small group with a large revenue impact.|r <= 2, f = 5, m >= 4|
|9|At Risk|Previously valuable customers who haven't purchased in a long time.|r <= 2, and (f >= 3 or m >= 3)|
|10|Hibernating	Customers|who have been inactive for a long time and were always low in frequency and spend.|r <= 2 (remaining)|

_Notes_
- _Thresholds are a design choice adapted from common RFM segment definitions, not an industry standard._
- _Recommended actions are common industry practice, not rules derived from the data._
- _Scores are assigned with NTILE(5) quintiles; recency is inverted so that 5 = most recent purchase._

__3. Customer Churn Analysis__
- Used the existing is_churned classification provided in the customer dataset, where 0 represents Active and 1 represents Churned.
- Calculated and compared churn rates across RFM segments and identified whether churn overlaps with RFM recency.
- The original churn classification methodology was not independently developed or verified.

__4. Funnel & Session Behavior Analysis__
- Evaluated session progression from exploration to cart addition and conversion.
- Calculated conversion rates and examined session conversion performance across RFM segments.
- Calculated cart abandonment rates and broke them down by device, channel, and RFM segment.
- Compared average pages viewed, cart additions, and session duration (in seconds) between converted and non-converted sessions.

__5. Dashboard Development__
- Developed interactive Power BI dashboards to communicate key metrics, customer patterns, and funnel performance.
- Created DAX measures and visualizations to support business analysis and exploration.

## Author  
Anisah Septiani M.  
LinkedIn: https://www.linkedin.com/in/anisahseptiani/  
GitHub: https://github.com/anisahsm  
Email: anisahseptianim@gmail.com


