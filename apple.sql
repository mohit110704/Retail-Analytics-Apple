-- Create Creation

--STORES TABLE

create table stores(
store_id varchar(10) Primary key,
store_name varchar(30),
city varchar(30),
country varchar(30)
);
select * from stores;

--CAREGORIES TABLE

create table category(
category_id varchar(15) primary key,
category_name varchar(30)
);

select * from category;

--PRODUCTS TABLE

create table products(
product_id varchar(15) primary key,
product_name varchar(35),
category_id varchar(15),
launch_date date,
price float,
constraint fk_category foreign key (category_id) references category(category_id)
);

select * from products;

--SALES TABLE

create table sales(
sale_id varchar(15) primary key,
sale_date date,
store_id varchar(10),
product_id varchar(15),
quantity int,
constraint fk_store foreign key (store_id) references stores(store_id),
constraint fk_product foreign key (product_id) references products(product_id)
);

select * from sales;

--WARRANTY TABLE

create table warranty(
claim_id varchar(10) primary key,
claim_date date,
sale_id varchar(15),
repair_status varchar(20),
constraint fk_sale foreign key (sale_id) references sales(sale_id)
);

select * from warranty
select * from stores;
select * from sales;
select * from products;
select * from category;

select distinct repair_status from warranty;

select distinct store_name from stores;

select distinct category_name from category;

select distinct product_name from products;

select * from sales;

-- Improving Query optimization 

         --- Business problem ----
            
--Find the number of stores in each country.

select country,COUNT(distinct store_name) as number_of_store from stores
group by country
order by number_of_store desc

--Calculate the total number of units sold by each store.

SELECT 
    st.store_name,
    SUM(s.quantity) AS unit_sold
FROM sales AS s
JOIN stores AS st
    ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name
ORDER BY unit_sold;


--Identify how many sales occurred in December 2023.
select COUNT(sale_id) from sales
where month(sale_date)=12 and YEAR(sale_date)=2023

--Determine how many stores have never had a warranty claim filed.
SELECT COUNT(*) AS stores_no_warranty
FROM stores st
WHERE st.store_id NOT IN (
    SELECT DISTINCT s.store_id
    FROM sales s
    JOIN warranty w ON s.sale_id = w.sale_id
);


--Calculate the percentage of warranty claims marked as "Warranty Void".

SELECT 
    CAST(SUM(CASE WHEN repair_status = 'Warranty Void' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS void_percentage
FROM warranty;

--Identify which store had the highest total units sold in the last year.
SELECT TOP 1 st.store_name, SUM(s.quantity) AS total_units_sold
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) - 1
GROUP BY st.store_name
ORDER BY total_units_sold DESC;

--Count the number of unique products sold in the last year.
SELECT COUNT(DISTINCT product_id) AS unique_products_sold
FROM sales
WHERE YEAR(sale_date) = YEAR(GETDATE()) - 1;

--Find the average price of products in each category.
SELECT c.category_name, AVG(p.price) AS avg_price
FROM products p
JOIN category c ON p.category_id = c.category_id
GROUP BY c.category_name;

--How many warranty claims were filed in 2020?
SELECT COUNT(*) AS claims_2020
FROM warranty
WHERE YEAR(claim_date) = 2020;

--For each store, identify the best-selling day based on highest quantity sold.
WITH store_daily_sales AS (
    SELECT 
        store_id, 
        sale_date,
        SUM(quantity) AS total_qty,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rn
    FROM sales
    GROUP BY store_id, sale_date
)
SELECT s.store_name, sd.sale_date, sd.total_qty
FROM store_daily_sales sd
JOIN stores s ON sd.store_id = s.store_id
WHERE sd.rn = 1;

--Identify the least selling product in each country for each year based on total units sold.
WITH product_country_year AS (
    SELECT 
        p.product_id,
        p.product_name,
        st.country,
        YEAR(s.sale_date) AS sale_year,
        SUM(s.quantity) AS total_units_sold
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN stores st ON s.store_id = st.store_id
    GROUP BY p.product_id, p.product_name, st.country, YEAR(s.sale_date)
),
ranked_products AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY country, sale_year ORDER BY total_units_sold ASC) AS rn
    FROM product_country_year
)
SELECT country, sale_year, product_name, total_units_sold
FROM ranked_products
WHERE rn = 1
ORDER BY country, sale_year;

--Calculate how many warranty claims were filed within 180 days of a product sale.
SELECT COUNT(*) AS claims_within_180_days
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
WHERE DATEDIFF(DAY, s.sale_date, w.claim_date) <= 180;

--Determine how many warranty claims were filed for products launched in the last two years.
SELECT COUNT(*) AS recent_product_claims
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
WHERE p.launch_date >= DATEADD(YEAR, -2, GETDATE());

--List the months in the last three years where sales exceeded 5,000 units in the USA.
SELECT YEAR(s.sale_date) AS sale_year, MONTH(s.sale_date) AS sale_month, SUM(s.quantity) AS total_units
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE st.country = 'USA' 
  AND s.sale_date >= DATEADD(YEAR, -3, GETDATE())
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
HAVING SUM(s.quantity) > 5000
ORDER BY sale_year, sale_month;


--Identify the product category with the most warranty claims filed in the last two years.
SELECT TOP 1 c.category_name, COUNT(w.claim_id) AS total_claims
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE w.claim_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY c.category_name
ORDER BY total_claims DESC;

--Determine the percentage chance of receiving warranty claims after each purchase for each country.
SELECT 
    st.country,
    COUNT(DISTINCT w.sale_id) * 100.0 / COUNT(DISTINCT s.sale_id) AS warranty_claim_percentage
FROM sales s
JOIN stores st ON s.store_id = st.store_id
LEFT JOIN warranty w ON s.sale_id = w.sale_id
GROUP BY st.country;

--Analyze the year-by-year growth ratio for each store.

WITH yearly_sales AS (
    SELECT 
        store_id,
        YEAR(sale_date) AS sale_year,
        SUM(quantity) AS total_units
    FROM sales
    GROUP BY store_id, YEAR(sale_date)
)
SELECT 
    ys.store_id,
    st.store_name,
    ys.sale_year,
    ys.total_units,
    CASE 
        WHEN LAG(ys.total_units) OVER (PARTITION BY ys.store_id ORDER BY ys.sale_year) = 0 THEN NULL
        ELSE CAST(ys.total_units AS FLOAT) / LAG(ys.total_units) OVER (PARTITION BY ys.store_id ORDER BY ys.sale_year) - 1
    END AS growth_ratio
FROM yearly_sales ys
JOIN stores st ON ys.store_id = st.store_id
ORDER BY ys.store_id, ys.sale_year;

--Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
WITH recent_sales AS (
    SELECT 
        CAST(p.price AS FLOAT) AS price,
        CAST(CASE WHEN w.claim_id IS NOT NULL THEN 1 ELSE 0 END AS FLOAT) AS has_claim
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    LEFT JOIN warranty w ON s.sale_id = w.sale_id
    WHERE s.sale_date >= DATEADD(YEAR, -5, GETDATE())
)
SELECT 
    (COUNT(*) * SUM(price * has_claim) - SUM(price) * SUM(has_claim)) /
    NULLIF(SQRT(
        (COUNT(*) * SUM(price * price) - SUM(price) * SUM(price)) *
        (COUNT(*) * SUM(has_claim * has_claim) - SUM(has_claim) * SUM(has_claim))
    ), 0) AS correlation_price_claim
FROM recent_sales;



--Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
WITH store_claims AS (
    SELECT 
        st.store_id,
        st.store_name,
        COUNT(*) AS total_claims,
        SUM(CASE WHEN w.repair_status = 'Paid Repaired' THEN 1 ELSE 0 END) AS paid_repaired_claims
    FROM warranty w
    JOIN sales s ON w.sale_id = s.sale_id
    JOIN stores st ON s.store_id = st.store_id
    GROUP BY st.store_id, st.store_name
)
SELECT TOP 1 
    store_name,
    paid_repaired_claims,
    total_claims,
    CAST(paid_repaired_claims AS FLOAT) / total_claims * 100 AS paid_repaired_percentage
FROM store_claims
ORDER BY paid_repaired_percentage DESC;

--Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
WITH monthly_sales AS (
    SELECT 
        s.store_id,
        YEAR(s.sale_date) AS sale_year,
        MONTH(s.sale_date) AS sale_month,
        SUM(s.quantity) AS total_units
    FROM sales s
    WHERE s.sale_date >= DATEADD(YEAR, -4, GETDATE())
    GROUP BY s.store_id, YEAR(s.sale_date), MONTH(s.sale_date)
)
SELECT 
    ms.store_id,
    st.store_name,
    ms.sale_year,
    ms.sale_month,
    ms.total_units,
    SUM(ms.total_units) OVER (
        PARTITION BY ms.store_id 
        ORDER BY ms.sale_year, ms.sale_month 
        ROWS UNBOUNDED PRECEDING
    ) AS running_total
FROM monthly_sales ms
JOIN stores st ON ms.store_id = st.store_id
ORDER BY ms.store_id, ms.sale_year, ms.sale_month;


--Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months
WITH sales_with_age AS (
    SELECT 
        p.product_id,
        p.product_name,
        s.sale_date,
        s.quantity,
        DATEDIFF(MONTH, p.launch_date, s.sale_date) AS months_since_launch
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
),
sales_segmented AS (
    SELECT 
        product_id,
        product_name,
        CASE 
            WHEN months_since_launch BETWEEN 0 AND 5 THEN '0-6 months'
            WHEN months_since_launch BETWEEN 6 AND 11 THEN '6-12 months'
            WHEN months_since_launch BETWEEN 12 AND 17 THEN '12-18 months'
            ELSE '18+ months'
        END AS sales_period,
        CASE 
            WHEN months_since_launch BETWEEN 0 AND 5 THEN 1
            WHEN months_since_launch BETWEEN 6 AND 11 THEN 2
            WHEN months_since_launch BETWEEN 12 AND 17 THEN 3
            ELSE 4
        END AS period_order,
        SUM(quantity) AS total_units_sold
    FROM sales_with_age
    GROUP BY product_id, product_name,
             CASE 
                 WHEN months_since_launch BETWEEN 0 AND 5 THEN '0-6 months'
                 WHEN months_since_launch BETWEEN 6 AND 11 THEN '6-12 months'
                 WHEN months_since_launch BETWEEN 12 AND 17 THEN '12-18 months'
                 ELSE '18+ months'
             END,
             CASE 
                 WHEN months_since_launch BETWEEN 0 AND 5 THEN 1
                 WHEN months_since_launch BETWEEN 6 AND 11 THEN 2
                 WHEN months_since_launch BETWEEN 12 AND 17 THEN 3
                 ELSE 4
             END
)
SELECT 
    product_id,
    product_name,
    sales_period,
    total_units_sold
FROM sales_segmented
ORDER BY product_id, period_order;
