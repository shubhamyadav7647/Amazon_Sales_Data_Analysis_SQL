select * from amazon_sales;

-- Checking the null values

SELECT 
    SUM(invoice_id IS NULL) AS invoice_id_count,
    SUM(branch IS NULL) AS branch_count,
    SUM(city IS NULL) AS city_count,
    SUM(customer_type IS NULL) AS customer_type_count,
    SUM(gender IS NULL) AS gender_count,
    SUM(product_line IS NULL) AS product_line_count,
    SUM(unit_price IS NULL) AS unit_price_count,
    SUM(quantity IS NULL) AS quantity_count,
    SUM(`tax_5%` IS NULL) AS tax_count, 
    SUM(total IS NULL) AS total_count,
    SUM(date IS NULL) AS date_count,
    SUM(time IS NULL) AS time_count,
    SUM(payment IS NULL) AS payment_count,
    SUM(cogs IS NULL) AS cogs_count,
    SUM(gross_margin_percentage IS NULL) AS gross_margin_percentage_count,
    SUM(gross_income IS NULL) AS gross_income_count,
    SUM(rating IS NULL) AS rating_count
FROM 
    amazon_sales;
    
-- #### Feature Engeneering

-- ## Adding new columns time_of_day

ALTER TABLE amazon_sales ADD time_of_day VARCHAR(20);
UPDATE amazon_sales
SET time_of_day = CASE
	WHEN EXTRACT(HOUR FROM time) < 12 THEN "Morning"
    WHEN EXTRACT(HOUR FROM time) < 18 THEN 'Afternoon'
    ELSE "Evening"
    END;

-- ## Adding new column month_name 

ALTER TABLE amazon_sales ADD month_name VARCHAR(30);
UPDATE amazon_sales
SET month_name = monthname(date);

-- ## Adding new column weekday

ALTER TABLE amazon_sales ADD day_of_week VARCHAR(30);
UPDATE amazon_sales
SET day_of_week = dayname(date);

# Answer the Business Questions;

-- QUestion: 1. What is the count of distinct cities in the dataset?
-- Answer: There are 3 Unique Cities Yangon, Naypyitaw and Mandalay

SELECT
    COUNT(DISTINCT city) distinct_city_count
FROM 
    amazon_sales;

-- Question: 2. For each branch, what is the corresponding city?
-- Answer: Branch A in Yangon City, Branch B in Mandalay City, Brance C in Naypyitaw City

with cte as(
SELECT 
    branch,
    city,
    row_number() OVER (partition by branch order by city) AS r1
FROM
    amazon_sales)
select * from cte where r1=1;

-- Question: 3. What is the count of distinct product lines in the dataset?
--  Answer: There are 6 DISTINCT product line.

SELECT 
    COUNT(DISTINCT product_line) count_product_line
FROM
    amazon_sales;
    
-- Question: 4. Which payment method occurs most frequently?
-- Answer: Ewallet is most frequent method most number of count is 345.

SELECT 
    payment AS most_frequent_payment_method,
    COUNT(*) AS frequency
FROM
    amazon_sales
GROUP BY
    payment
ORDER BY 
    frequency desc
limit 
    0,1;

-- Question: 5. Which product line has the highest sales?
-- Answer: Food and beverages product line has higest sale with quantity of 971.

SELECT 
    product_line,
    SUM(quantity) AS total_sales
FROM 
    amazon_sales
GROUP BY 
    product_line
ORDER BY 
    total_sales DESC
LIMIT 
    0,1
;

-- Question: 6. How much revenue is generated each month?
-- Answer: January month generate highest revenue with amount 116291.86.
SELECT 
    month_name,
    SUM(total) AS total_sales
FROM 
    amazon_sales
GROUP BY
    month_name
ORDER BY 
	total_sales DESC
LIMIT
    0,1
;

-- Question: 7. In which month did the cost of goods sold reach its peak?
-- Answer: Month of January cogs reach its peak with amount 110754.16.
SELECT 
    month_name,
    SUM(cogs) AS Total_cost
FROM
    amazon_sales
GROUP BY
    month_name
ORDER BY 
    Total_cost DESC
LIMIT 
    0,1;

-- Question: 8. Which product line generated the highest revenue?
-- Answer: 

SELECT 
    product_line,
    SUM(total) AS Total_Revenue
FROM
    amazon_sales
GROUP BY 
    product_line
ORDER BY 
    Total_Revenue DESC
LIMIT
    0,1;

-- Question: 9.In which city was the highest revenue recorded?    
-- Answer: Naypyitaw City recorded the highest revenue of 110568.70.
SELECT 
    city,
    SUM(total) AS Total_Revenue
FROM 
    amazon_sales
GROUP BY
    city
ORDER BY
    Total_Revenue DESC
LIMIT
    0,1;
    
    
-- Question: 10. Which product line incurred the highest Value Added Tax?
-- Answer: Food and beverages has the highest Value Added Tax of 2673.56.

SELECT 
    product_line,
    SUM(`tax_5%`) AS Value_Added_Tax
FROM
    amazon_sales
GROUP BY
    product_line
ORDER BY
    Value_Added_Tax DESC
LIMIT 0,1;

-- Question: 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- Answer: Only Health and beauty is Bad and all are good and above the average sales.

SELECT 
    product_line,
    Total_sales,
    (CASE WHEN Total_sales > avg_sales THEN "Good" ELSE "Bad" END) AS Target
FROM
(SELECT 
    product_line,
    SUM(total) AS Total_sales,
    AVG(SUM(total)) OVER () avg_sales
FROM
    amazon_sales
GROUP BY
    product_line) AS T1
GROUP BY
    product_line,
    Total_sales
;

-- Question: 12. Identify the branch that exceeded the average number of products sold.
-- Answer: Branch C is exceed the Average Number of product sold.

SELECT 
    branch, 
	avg_product_sold

FROM
(SELECT 
    branch,
    AVG(quantity) AS avg_product_sold
FROM
    amazon_sales
GROUP BY 
    branch) T1
WHERE
    avg_product_sold > (SELECT AVG(quantity) FROM amazon_sales);


-- Question: 13. Which product line is most frequently associated with each gender?
-- Answer: For Female Food and beverages product_line with total_sales of 33170 and For male Health and beauty product line with total_sale of 30632.

SELECT 
    gender,
    product_line,
    SUM(total) AS Total_sales
FROM
    amazon_sales
GROUP BY
    gender,
    product_line
ORDER BY
    Total_sales DESC
LIMIT 0,2
;

-- Question: 14.Calculate the average rating for each product line.
-- Answer: 

SELECT  
    product_line,
    AVG(rating) AS Average_rating
FROM 
    amazon_sales
GROUP BY
    product_line
;

-- Question: 15. Count the sales occurrences for each time of day on every weekday.
-- Answer: 

SELECT
    day_of_week,
    time_of_day,
    COUNT(total) AS Sales_counts
FROM 
    amazon_sales
GROUP BY
    day_of_week,
    time_of_day
HAVING
    day_of_week in ("Monday","Tuesday","Wednesday","Thursday","Friday")
ORDER BY
    Sales_counts DESC
;

-- Question: 16. Identify the customer type contributing the highest revenue.
-- Answeer: Member contributing to the Highest revenue.

SELECT 
     customer_type,
     SUM(total) AS Total_Revenue
FROM 
    amazon_sales
GROUP BY 
    customer_type
ORDER BY
    Total_Revenue DESC
LIMIT 0,1
;

-- Question: 17. Determine the city with the highest VAT percentage.
-- Answer: 5%

SELECT city, MAX((`tax_5%` / (total - `tax_5%`)) * 100) AS max_vat_percentage
FROM amazon_sales
GROUP BY city
ORDER BY max_vat_percentage DESC
LIMIT 1;

-- Question: 17. Identify the customer type with the highest VAT payments.
-- Answer: Members with 7820

SELECT 
    customer_type,
    SUM(`tax_5%`) AS VAT
FROM 
    amazon_sales
GROUP BY
    customer_type
LIMIT
    0,1
    ;

-- Question: 18. What is the count of distinct customer types in the dataset?
-- Answer: 2

SELECT 
    COUNT(DISTINCT customer_type) AS Customer_count 
FROM 
    amazon_sales;

-- Question: 19. What is the count of distinct payment methods in the dataset?
-- Answer: 3

SELECT 
    COUNT(DISTINCT payment) AS Customer_count 
FROM 
    amazon_sales;


-- Question: 21. Which customer type occurs most frequently?
-- Answer: Member = 501

SELECT 
     customer_type,
     COUNT(*) customer_type_count
FROM
    amazon_sales
GROUP BY
	customer_type 
LIMIT 0,1
;


-- Question: 22. Identify the customer type with the highest purchase frequency.
-- Answer: 

SELECT
    customer_type,
    COUNT(*) AS purchase_frequency
FROM
    amazon_sales
GROUP BY
    customer_type
LIMIT 0,1;


-- Question: 23. Determine the predominant gender among customers.
-- Answer: Female

SELECT 
    gender,
    count(*) AS gender_count
FROM 
    amazon_sales
GROUP BY
	gender
LIMIT 0,1
    ;
    
 -- Question: 24. Examine the distribution of genders within each branch.
 -- 
 
 SELECT 
     gender,
     branch,
     COUNT(branch) AS branch_count
FROM 
     amazon_sales
GROUP BY
     gender,
     branch
;


-- Question: 25. Identify the time of day when customers provide the most ratings.
-- Answer: Afternoon with 528 rating count

SELECT 
    time_of_day,
    COUNT(rating) AS rating_counts
FROM
    amazon_sales
GROUP BY
    time_of_day
ORDER BY
    rating_counts DESC
LIMIT 0,1
;

-- Question: 26. Determine the time of day with the highest customer ratings for each branch.
-- Answer: 

WITH cte AS (
    SELECT 
        time_of_day,
        branch,
        MAX(rating) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY MAX(rating) DESC) AS row_num
    FROM
        amazon_sales
    GROUP BY
        time_of_day,
        branch
)
SELECT 
    time_of_day,
    branch,
    rating_count
FROM 
    cte
WHERE 
    row_num = 1
ORDER BY 
    rating_count DESC;



-- Question: 27. Identify the day of the week with the highest average ratings.
-- Answer: 

SELECT 
    day_of_week, AVG(rating) average_rating
FROM 
    amazon_sales
GROUP BY 
    day_of_week
ORDER BY 
    average_rating DESC
LIMIT 0,1;

-- Question: 28. Determine the day of the week with the highest average ratings for each branch.
-- Answer: 

with cte as (
SELECT 
   day_of_week,
   branch,
   AVG(rating) average_rating
FROM
   amazon_sales
GROUP BY
   day_of_week,
   branch),
cte2 AS (
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY average_rating DESC) row_num
FROM
    cte
)
SELECT day_of_week, branch, average_rating 
FROM cte2 
WHERE row_num = 1 
;


-- *********************************************************** THANK YOU ***************************************************************************
    

select * from amazon_sales;