![Apple Logo](Apple-Store.jpg.large.jpg) 

# Apple Retail Sales SQL Project - Analyzing Millions of Sales Rows

## Project Overview

This project focuses on analyzing a retail sales database using SQL to extract meaningful business insights.
The dataset includes information on stores, products, sales transactions, product categories, and warranty claims.
Advanced SQL concepts such as joins, aggregations, window functions, and CTEs were applied to solve real-world business problems.
The project demonstrates the ability to analyze structured data and support data-driven decision-making.

## Entity Relationship Diagram (ERD)

![ERD](https://github.com/najirh/Apple-Retail-Sales-SQL-Project---Analyzing-Millions-of-Sales-Rows/blob/main/erd.png)

---

## Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

## Objectives

The project is split into three tiers of questions to test SQL skills of increasing complexity:

### Easy to Medium (10 Questions)

Q1. Find the number of stores in each country.
 ```sql
   select country,count( store_id)  as number_of_stores
   from stores
   Group by country
   order by  number_of_stores desc;
```
Q2.Calculate the total number of units sold by each store.
```sql
   select s.store_id ,
	st.store_name,
	sum(s.quantity) as total_unit_sold
from sales as s
join stores as st
on st.store_id = s.store_id
group by 1,2
order by 3 Desc;
```
Q3. Identify how many sales occurred in December 2023.
```sql
   select count(sale_id) as total_sales_in_december
from sales
where TO_CHAR(sale_date, 'YYYY-MM') = '2023-12'
```
Q4. Determine how many stores have never had a warranty claim filed.
```sql
   SELECT 
    COUNT(*) AS stores_with_no_warranty_claims
FROM stores st
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    JOIN warranty w
        ON s.sale_id = w.sale_id
    WHERE s.store_id = st.store_id
);
```
Q5.Calculate the percentage of warranty claims marked as "Completed".
```sql
   select
 ROUND(count(claim_id)/(select Count(*) from warranty)::numeric * 100,2) AS Warranty_Completed
 from warranty
where repair_status ='Completed'
```
Q.6Identify which store had the highest total units sold in the year 2024.
```sql
   select store_id ,sum(quantity) as Total_sales
from sales
where to_char(sale_date,'YYYY') ='2024'
Group by store_id
order by Total_sales
limit 3;
```
Q7.Count the number of unique products sold in the last 2024.
```sql
   SELECT 
    COUNT(DISTINCT sl.product_id) AS total_unique_products_sold
FROM sales sl
WHERE sl.sale_date >= DATE '2024-01-01'
  AND sl.sale_date <  DATE '2025-01-01';
```
Q8.Find the average price of products in each category.
```sql
   select p.category_id ,c.category_name,round(avg(p.price) ,2)as avg_price
from products as p
join category as c
on p.category_id=c.category_id
group by p.category_id,2
order by avg_price desc;
```
Q9.How many warranty claims were filed in 2024?
```sql
   select count(*) as Total_claims
from warranty
where to_char(claim_date,'YYYY') ='2024'
```
Q10. For each store, identify the best-selling day based on highest quantity sold.
```sql
   SELECT * FROM
(
	SELECT
		store_id,
		TO_CHAR(sale_date,'Day') as day_name,
		sum(quantity) as total_unit_sold,
		RANK() over(PARTITION BY store_id ORDER BY SUM(quantity)DESC)as rank
		from sales
		Group by store_id,day_name
)as t1
where rank=1;
```

### Medium to Hard (5 Questions)

Q11.Identify the least selling product in each country for each year based on total units sold.
```sql
   WITH product_rank
AS(
select st.country,
		p.product_name,
		SUM(s.quantity) as total_qty_sold,
		RANK() over(PARTITION BY st.country ORDER BY SUM(s.quantity)) as rank
From sales as s
JOIN
stores as st
on s.store_id = st.store_id
JOIN
products as p
ON s.product_id =p.product_id
Group by country,product_name
)
select * FROM product_rank
where rank =1;
```
Q12.Calculate how many warranty claims were filed within 180 days of a product sale.
```sql
select count(*) as Total_Warranty_claims
FROM warranty as w
LEFT JOIN 
sales as s
ON s.sale_id = w.sale_id
where
	w.claim_date - sale_date <= 180;
```
Q13.Determine how many warranty claims were filed for products launched in the last two years.
```sql
select p.product_name,COUNT(w.claim_id) as no_claim
	,COUNT(s.sale_id)
FROM warranty as w
 RIGHT JOIN 
sales as s
on s.sale_id = w.sale_id
JOIN  products as p
on p.product_id = s.product_id
Where p.launch_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1
HAVING Count(w.claim_id) > 0 ;
```
Q14.List the months in the last three years where sales exceeded 5,000 units in the USA.
```sql
select 
	to_char(sale_date,'MM-YYYY') as month,
	sum(s.quantity)as total_unit_sold
from sales as s
join 
stores as st
on s.store_id =st.store_id
where st.country ='United States'
AND 
s.sale_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1
Having SUM (s.quantity)>5000
```
Q15. Identify the product category with the most warranty claims filed in the last two years.
```sql
SELECT 
	  c.category_name,
	  COUNT(w.claim_id) as total_claims
FROM warranty as w
LEFT JOIN
sales as s
on w.sale_id = s.sale_id
JOIN products as p 
ON p.product_id =s.product_id
JOIN 
category as c
ON c.category_id =p.category_id
Where
	w.claim_date >= CURRENT_DATE - INTERVAL '2 year'
Group by 1;
```
### Complex (5 Questions)

Q16.Determine the percentage chance of receiving warranty claims after each purchase for each country.
```sql
SELECT
    st.country,
    SUM(s.quantity) AS total_units_sold,
    COUNT(DISTINCT w.claim_id) AS total_claims,
    ROUND(
        COUNT(DISTINCT w.claim_id)::numeric
        / NULLIF(SUM(s.quantity), 0) * 100,
        2
    ) AS risk_percent
FROM sales s
JOIN stores st
    ON s.store_id = st.store_id
LEFT JOIN warranty w
    ON w.sale_id = s.sale_id
GROUP BY st.country
ORDER BY risk_percent DESC;
```
17. Analyze the year-by-year growth ratio for each store.
```sql
With yearly_sales
AS (SELECT s.store_id,
		st.store_name,
		EXTRACT(YEAR FROM sale_date)as year,
		SUM(s.quantity * p.price) as total_sale
from sales as s
JOIN 
products as p
on s.product_id=p.product_id
JOIN stores as st
on st.store_id = s.store_id
Group by 1,2,3
order by 2,3
),
growth_ratio
AS
(
select 
		store_name,
		year,
		LAG(total_sale,1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
		total_sale as current_year_sale
from yearly_sales
)
SELECT 
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND((current_year_sale - last_year_sale):: numeric/last_year_sale * 100,3) as growth_ratio
from growth_ratio 
where last_year_sale is not null
and
year <> EXTRACT(YEAR FROM CURRENT_DATE)
```
Q18.Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
```sql
SELECT 
	CASE
		WHEN p.price < 500 THEN 'Less Expenses Product'
		WHEN p.price BETWEEN 500 AND 1000 THEN 'Mid Range Product'
		ELSE 'Expensive Product'
	End as price_segment,
	count(w.claim_id) as total_claim
FROM warranty as w
LEFT JOIN
sales as s
ON w.sale_id =s.sale_id
JOIN 
products as p
ON p.product_id=s.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 year'
Group by price_segment;
```
Q19.Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
```sql
SELECT
    s.store_id,
    st.store_name,
    SUM(CASE WHEN w.repair_status = 'Completed' THEN 1 ELSE 0 END) 
        AS paid_repaired,
    COUNT(w.claim_id) AS total_repaired,
    ROUND(
        SUM(CASE WHEN w.repair_status = 'Completed' THEN 1 ELSE 0 END)::numeric
        / NULLIF(COUNT(w.claim_id), 0) * 100,
        2
    ) AS percentage_paid_repaired
FROM warranty w
JOIN sales s
    ON w.sale_id = s.sale_id
JOIN stores st
    ON s.store_id = st.store_id
GROUP BY s.store_id, st.store_name
ORDER BY percentage_paid_repaired DESC;
```
Q20.Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
```sql
WITH monthly_sales
AS
(SELECT 
	store_id,
	EXTRACT (Year FROM sale_date)as year,
	EXTRACT(MONTH FROM sale_date)as month,
	SUM(p.price * s.quantity)as total_revenue
FROM sales as s
JOIN 
products as p
on s.product_id =p.product_id
GROUP BY 1,2,3
order by 1,2,3
)
SELECT store_id,
month,year,total_revenue,
SUM(total_revenue) over(Partition BY store_id ORDER BY year,month)as running_total
FROM monthly_sales
```
### Bonus Question

Q21.Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
```sql
select 
	p.product_name,
	CASE 
	When s.sale_date BETWEEN p.launch_date AND p.launch_DATE + INTERVAL '6 month' THEN '0-6 month'
	When s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + interval '12 month' THEN '6-12'
	When s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + interval '18 month' THEN '6-12'
	ELSE'18'
	END as plc,
	SUM(S.quantity) as total_qty_sale
FROM sales as s
JOIN products as p
on s.product_id=p.product_id
GROUP BY 1,2
ORDER BY 1,3 DESC;
```

## Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.


## Dataset

- **Size**: 1 million+ rows of sales data.
- **Period Covered**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.

## Project  Business Insights

-- Sales volume is strongly influenced by geographical store distribution, with countries having more stores generating higher overall sales.
-- A small number of stores contribute the majority of total units sold, indicating performance concentration among top stores.
-- Warranty claim rates vary across countries, suggesting region-specific product usage or service quality differences.
-- Certain product categories account for a higher share of warranty claims, highlighting potential quality or durability issues.
-- Sales follow clear monthly and daily patterns, which can be used to optimize inventory planning and staffing.

## Conclusion

This project involved designing and analyzing a relational retail database using advanced SQL techniques.Various business-focused queries were implemented to evaluate sales performance, store efficiency, and warranty trends.The analysis converted raw transactional data into meaningful insights to support data-driven decision-making. Overall, the project demonstrates strong practical SQL skills and real-world analytical capability.
---
