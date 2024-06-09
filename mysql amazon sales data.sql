-- 1. Data Wrangling

--  Build a database
create database AmazonSalesData;
use AmazonSalesData;

-- Create a table named 'amazon' to store sales data
create table amazon (
invoice_id VARCHAR(30) NOT NULL,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10, 2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT  NOT NULL,
total DECIMAL(10, 2) NOT NULL,
date DATE NOT NULL,
time TIME NOT NULL,
payment VARCHAR(50) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_percentage FLOAT NOT NULL,
gross_income DECIMAL(10, 2) NOT NULL,
rating FLOAT NOT NULL 
);


-- Display the structure of the 'amazon' table
select * from amazon;

-- 2. Feature Engineering
--  Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.

SET SQL_SAFE_UPDATES = 0;					-- Disable SQL_SAFE_UPDATES temporarily


ALTER TABLE amazon							-- Add a new column named timeofday to the amazon table
ADD column timeofday VARCHAR(20);

UPDATE amazon								-- Update the new column with timeofday values based on the time column
SET timeofday =
    CASE
        WHEN time BETWEEN '12:00:0' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '17:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;

SET SQL_SAFE_UPDATES = 1;					-- Re-enable SQL_SAFE_UPDATES

-- 2.   Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).

SET SQL_SAFE_UPDATES = 0;					-- Disable SQL_SAFE_UPDATES temporarily


ALTER TABLE amazon
ADD column dayname VARCHAR(20);

UPDATE amazon 
SET dayname = DATE_FORMAT(date, '%a');

SET SQL_SAFE_UPDATES = 1;					-- Re-enable SQL_SAFE_UPDATES

-- 3. Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)

SET SQL_SAFE_UPDATES = 0;						-- Disable SQL_SAFE_UPDATES temporarily

ALTER TABLE amazon
ADD column monthname VARCHAR(20);

update amazon 
set monthname = date_format(date, '%M');

SET SQL_SAFE_UPDATES = 1;						-- Re-enable SQL_SAFE_UPDATES

-- Business Questions

-- 1. What is the count of distinct cities in the dataset?

SELECT COUNT(DISTINCT city) as city_count from amazon;   #The DISTINCT keyword ensures that each city is counted only once, eliminating duplicates.
														 # we have total three distinct city in our dataset.

-- 2. For each branch, what is the corresponding city?
SELECT DISTINCT branch, city from amazon;				#The DISTINCT keyword ensures that each city is counted only once, eliminating duplicates.
														#we have total three distinct city in our dataset thats name is Yangon, Naypyitaw, Mandalay.

-- 3. What is the count of distinct product lines in the dataset?		# the COUNT() function is an aggregate function that use to determine the number of rows that match a specified condition. 
select count(DISTINCT product_line) as product_line_count from amazon;    

-- 4. Which payment method occurs most frequently?
select max(payment) as payment_count from amazon;

-- 5. Which product line has the highest sales?
select product_line, sum(gross_income) as high_sales from amazon 
group by product_line order by high_sales desc;

-- 6. How much revenue is generated each month?
select monthname, sum(total) as monthly_revenue from amazon    #Maximum revenue generated in jan > march > feb.
group by monthname 
order by monthly_revenue desc;

-- 7. In which month did the cost of goods sold reach its peak?
select monthname, max(cogs) as max_cogs from amazon   # cogs = Cost Of Goods sold
group by monthname									  #maximum cogs receved in Feb > Jan > March.
order by max_cogs desc;

-- 8.Which product line generated the highest revenue?
select product_line, sum(total) as high_revenue from amazon
group by product_line 
order by high_revenue DESC limit 1;

-- 9.In which city was the highest revenue recorded?
select city, sum(total) as high_revenue from amazon
group by city
order by high_revenue DESC;

-- 10.Which product line incurred the highest Value Added Tax?
select product_line, sum(total) as high_vat from amazon
group by product_line
order by high_vat DESC;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT
    product_line,
    CASE WHEN gross_income > (SELECT AVG(gross_income) FROM amazon AS a2
	WHERE a2.product_line = a1.product_line) THEN "Good"
	ELSE "Bad"
    END AS sales_performance
FROM
    amazon AS a1;

-- 12.Identify the branch that exceeded the average number of products sold.

SELECT DISTINCT branch 
FROM amazon 
GROUP BY branch 
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazon); 

-- 13.Which product line is most frequently associated with each gender? 

with rank_product_lines as (
select gender, product_line, count(*) as product_line_count,
rank() over (partition by gender order by count(*) desc) as rank_num
from amazon
group by gender, product_line
)
select gender, product_line, product_line_count 
from rank_product_lines 
where rank_num =1;   

-- 14.Calculate the average rating for each product line.
select product_line, avg(rating) as avg_rating 
from amazon 
group by product_line;   
    
 -- 15.Count the sales occurrences for each time of day on every weekday.
select dayname, timeofday, count(*) as sale_occur 
from amazon
group by dayname, timeofday 
order by dayname, sale_occur desc;   
    
-- 16.Identify the customer type contributing the highest revenue.
select customer_type, sum(total) as high_revenue 
from amazon 
group by customer_type 
order by high_revenue desc;

-- 17.Determine the city with the highest VAT percentage.
select city, sum(vat) as high_vat, sum(total) as total_revenue, (sum(vat)/sum(total))*100 as vat_percent 
from amazon 
group by city 
order by vat_percent desc;

-- 18.Identify the customer type with the highest VAT payments.
select customer_type, sum(vat) as high_vat 
from amazon 
group by customer_type 
order by high_vat desc;

-- 19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as customer_type_count from amazon;

-- 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment) as payment_method_count from amazon;

-- 21.Which customer type occurs most frequently?
select customer_type, count(*) as most_freq 
from amazon 
group by customer_type;

-- 22.Identify the customer type with the highest purchase frequency.
select customer_type, sum(quantity) as high_pur_freq 
from amazon 
group by customer_type 
order by high_pur_freq DESC 
limit 1;

-- 23.Determine the predominant gender among customers.
select gender, count(*) as customer_count 
from amazon 
group by gender 
order by customer_count DESC 
limit 1 ;

-- 24.Examine the distribution of genders within each branch.
select branch, gender, count(gender) as gender_dist 
from amazon 
group by branch, gender 
order by branch, gender_dist desc;

-- 25.Identify the time of day when customers provide the most ratings.
select timeofday, count(rating) as rating_count 
from amazon 
group by timeofday 
order by rating_count desc;

-- 26.Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, count(rating) as rating_count 
from amazon 
group by branch, timeofday 
order by branch;

-- 27.Identify the day of the week with the highest average ratings.
select dayname, avg(rating) as avg_rating
from amazon 
group by dayname
order by avg_rating desc
limit 1;

-- 28.Determine the day of the week with the highest average ratings for each branch.
with branch_high_rating as 
(select branch, dayname, avg(rating) as avg_rating,
rank() over (partition by branch order by avg(rating) desc) as rank_num 
from amazon 
group by branch, dayname)
select branch, dayname, avg_rating 
from branch_high_rating 
where rank_num=1;

-- Analysis Result


-- 1. we have 6 product line in our dataset in which "Food and Beverages" gives highest sales and revenue.
-- Companies may focus on scaling up production, expanding market reach to maximize revenue potential.

-- 2. Health and beauty product line has lowest sales and revenue so we need to improved this product line.

-- 3. E-wallets are the most frequently used method by customers, so the company can partner with e-wallet providers
-- to offer additional benefits to its customers, such as exclusive discounts, loyalty rewards, and more