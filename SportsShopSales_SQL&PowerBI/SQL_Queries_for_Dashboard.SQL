-- 1. View raw sales transactions
SELECT order_date, sales_amount 
FROM fact_sales;


-- 2. Extract Year from Order Date and Sum Sales Amount per Year
SELECT YEAR(order_date) AS OrderYear, 
       SUM(sales_amount) AS TotalSales 
FROM fact_sales
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date) 
ORDER BY OrderYear;


-- 3. Calculate Running Total (Cumulative Sales) Using a Subquery
SELECT OrderYear, 
       TotalSales, 
       SUM(TotalSales) OVER (ORDER BY OrderYear) AS CumulativeSales 
FROM (
    SELECT YEAR(order_date) AS OrderYear, 
           SUM(sales_amount) AS TotalSales 
    FROM fact_sales 
    WHERE order_date IS NOT NULL 
    GROUP BY YEAR(order_date)
) AS SalesData
ORDER BY OrderYear;


-- 4. Fetch Previous Year's Sales Using LAG Function for Year-over-Year Comparison
SELECT YEAR(order_date) AS OrderYear, 
       SUM(sales_amount) AS TotalSales,
       LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS PreviousYearSales 
FROM fact_sales 
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date)
ORDER BY OrderYear;


-- 5. Calculate Year-over-Year Sales Difference
SELECT YEAR(order_date) AS OrderYear, 
       SUM(sales_amount) AS TotalSales,
       LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS PreviousYearSales, 
       SUM(sales_amount) - LAG(SUM(sales_amount)) OVER (ORDER BY YEAR(order_date)) AS YearlyChange 
FROM fact_sales 
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date)
ORDER BY OrderYear;


-- 6. View Raw Customer Transactions
SELECT customer_key, order_date, sales_amount 
FROM fact_sales;


-- 7. Aggregate Sales Data by Customer (Total Amount Spent and Total Orders)
SELECT customer_key, 
       SUM(sales_amount) AS TotalSpent, 
       COUNT(DISTINCT order_number) AS TotalOrders 
FROM fact_sales 
GROUP BY customer_key;


-- 8. Categorize Customers Based on Spending Behavior
SELECT customer_key, TotalSpent, TotalOrders, 
       CASE 
           WHEN TotalSpent > 10000 THEN 'High Value'
           WHEN TotalSpent BETWEEN 5000 AND 10000 THEN 'Medium Value'
           ELSE 'Low Value' 
       END AS CustomerCategory
FROM (
    SELECT customer_key, 
           SUM(sales_amount) AS TotalSpent, 
           COUNT(DISTINCT order_number) AS TotalOrders 
    FROM fact_sales 
    GROUP BY customer_key
) AS CustomerSummary;


-- 9. View Raw Product Sales Transactions
SELECT product_key, order_date, sales_amount 
FROM fact_sales;


-- 10. Aggregate Total Revenue and Order Count Per Product
SELECT product_key, 
       SUM(sales_amount) AS TotalRevenue, 
       COUNT(DISTINCT order_number) AS TotalOrders 
FROM fact_sales 
GROUP BY product_key;


-- 11. Rank Top-Selling Products Based on Total Revenue
SELECT product_key, TotalRevenue, TotalOrders, 
       RANK() OVER (ORDER BY TotalRevenue DESC) AS SalesRank 
FROM (
    SELECT product_key, 
           SUM(sales_amount) AS TotalRevenue, 
           COUNT(DISTINCT order_number) AS TotalOrders 
    FROM fact_sales 
    GROUP BY product_key
) AS ProductSummary;


-- 12. Segment Customers by Age Group Using Birthdate
SELECT customer_key, 
       birthdate,
       DATEDIFF(YEAR, birthdate, GETDATE()) AS Age,
       CASE 
           WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 25 THEN 'Young'
           WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 25 AND 50 THEN 'Middle Age'
           ELSE 'Senior' 
       END AS AgeCategory
FROM dim_customers;


-- 13. Categorize Products by Price Range
SELECT product_key, cost, 
       CASE 
           WHEN cost > 100 THEN 'Premium'
           WHEN cost BETWEEN 50 AND 100 THEN 'Standard'
           ELSE 'Budget' 
       END AS PriceCategory
FROM dim_products;
