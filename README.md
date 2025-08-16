# Retail-Analytics-Apple
SQL queries and analysis for retail sales and warranty data

## Project Overview

This project demonstrates advanced SQL queries using a large Apple retail sales dataset. The data includes products, stores, sales transactions, and warranty claims from Apple stores around the world.

The goal is to answer real business questions—from simple summaries to more complex analyses—such as sales trends, product performance, warranty patterns, and store comparisons.

## What’s Included

- **50+ SQL Queries:** Covers a wide range of business questions, from basic summaries to advanced analytics.

- **Advanced Business Analysis:** Step-by-step solutions for complex queries like sales trends, warranty analysis, product lifecycle, and store performance.

- **5 Sample Tables:** Includes stores, category, products, sales, and warranty with sample data representing a large dataset (sales table originally has 641,232 rows).

- **Real-World Scenarios:** Queries are based on realistic retail business problems, helping you practice SQL for data analytics and reporting.

 ## Why Choose This Project?

- **Hands-on Learning:** Practice writing SQL queries on realistic retail datasets and solve real business problems.

- **Comprehensive Coverage:** Explore multiple tables (stores, category, products, sales, warranty) and tackle queries ranging from basic summaries to advanced analytics.

- **Real-World Insights:** Analyze sales trends, product performance, warranty claims, and store-level metrics—just like a professional data analyst would.

- **Scalable Practice:** Works with large datasets (sales table has 641,232 rows), giving experience handling real-world data volumes.

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

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.

## Dataset

- **Size:** Sales table contains 641,232 rows, with other tables (stores, category, products, warranty) providing additional context.

- **Period Covered:** Data spans multiple years, enabling analysis of long-term sales and warranty trends.

- **Geographical Coverage:** Includes stores from different cities and countries, allowing insights across locations.

## Conclusion

This project provides a hands-on opportunity to master advanced SQL techniques while working with realistic retail sales and warranty data. By exploring multiple tables, analyzing sales trends, and solving complex business questions, you will strengthen your ability to handle large datasets and extract meaningful insights.

---
