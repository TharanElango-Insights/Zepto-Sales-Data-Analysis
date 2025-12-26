# -------------------------- Zepto SQL Project ---------------------------------

-- zepto_sql_project creation
CREATE DATABASE IF NOT EXISTS zepto_sql_project;		
USE zepto_sql_project; 
show databases;

-- zepto Table creation
create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER);

show tables;
desc zepto;

-- after CSV file imported to zepto table
select * from zepto;
select * from zepto limit 10;
select count(*) from zepto;			#------ check total count on zepto table

-- Check NULL values in zepto table - directly [is NULL]
select * from zepto where 
category IS NULL 
or name IS NULL 
or mrp IS NULL 
or discountPercent IS NULL 
or availableQuantity IS NULL 
or discountedSellingPrice IS NULL 
or weightInGms IS NULL 
or outOfStock IS NULL 
or quantity IS NULL;

-- Check NULL values in zepto table - using COALESCE [is NULL]
select * from zepto where coalesce(
category, name, mrp, discountPercent, availableQuantity,
discountedSellingPrice, weightInGms, outOfStock, quantity) IS NULL;

-- Different product categories in zepto table
select distinct category from zepto order by category;		#------ List the "all unique product categories, sorted alphabetically.
select count(distinct category) as Total_no_distinct_Categories from zepto;	#------ To get the total number of unique  categories.
select category, count(*) AS No_of_rows_in_each_category
from zepto group by category order by category;		#------ Displays the unique categories with "Number of Rows/Items" in each Category.

-- Products in Stock & OutofStock in zepto table
select outOfStock as stock_status, count(sku_id) as product_count
from zepto 
group by outOfStock;		#------ List the total count of Instock & OutofStock.  "0"= OutofStock & "1"= Instock.

-- Product names present multiple times in zepto table
select name, count(sku_id) as "Number of SKU's" from zepto
group by name having count(sku_id) > 1 order by count(sku_id) desc;	#------ List the duplicate product names and how many time they occuring in table.

-- Data Cleaning : find product price =0, delete that row, convert paise to rupees, 
-- Product price = 0
select * from zepto where mrp=0 or discountedSellingPrice =0;	#------ for cleaning purpose, we should delete the row where price="0". For sku_id = 3603 backup. 
-- 1. Do "Start Transaction", perform deletion, ROLLBACK; & then COMMIT;
-- 2. Manual insertion "INSERT INTO zepto (sku_id, category, name, mrp, discountPercent, availableQuantity,discountedSellingPrice, weightInGms, outOfStock, quantity) VALUES ('3603', 'Home & Cleaning', 'Cherry Blossom Liquid Shoe Polish Neutral', 0.00, 0.00, 1, 0.00, 75, 0, 75);" 

delete from zepto where mrp=0;	#Unable to delete/update - error code 1175. SQL_SAFE_UPDATES is ON. for accidental deletion/updation.
-- 1. Manually turn off(SET SQL_SAFE_UPDATES = 0;), perform deletion & turn on (SET SQL_SAFE_UPDATES = 1;) Eg : SET SQL_SAFE_UPDATES = 0; delete from zepto where mrp=0; SET SQL_SAFE_UPDATES = 1;

-- Convert paise to rupees
select mrp, discountedSellingPrice from zepto;	#the values in MRP & discountedSellingPrice shpws incorrect - Its should like "25.00" & "21.00" Not like "2500.00" & "2100.00"
# Do the same for Deletion - Turn off & On the SQL_SAFE_UPDATES 
-- SET SQL_SAFE_UPDATES = 0;
Update zepto
set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;
select mrp, discountedSellingPrice from zepto;	-- After conversion, Values as expected : "25.00" & "21.00" 
-- SET SQL_SAFE_UPDATES = 1;

# Zepto - Business Insights (10 Queries)

-- Ql. Find the top 10 best-value products based on the discount percentage.
select distinct name, mrp, discountPercent 
from zepto									# Useful for which products to heavily promote
order by discountPercent desc 
limit 10;

-- Q2.What are the Products with High MRP but Out of Stock(In stock)
select distinct name , mrp , outOfStock
from zepto									# Useful for : Customers are buying these products frequently, so ReStock them ASAP.
where outOfStock=1		# If outOfStock = 1(True) --> Product is NOT AVAILABLE & If outOfStock = 0(False) --> Product IS AVAILABLE (In Stock)
and mrp>300
order by mrp desc;
-- For Stock Count visibility
select 
sum(outOfStock = 1) AS Non_Available_Stock_Count,		# 0 = false(In Stock) & 1 = True(Out of Stock) --> Result : 0 (3274 avail) & 1 (453 not avail)
sum(outOfStock = 0) AS Available_Stock_Count
from zepto;

-- Q3.Calculate Estimated Revenue for each category
select category, sum(mrp * availableQuantity) as Total_Revenue
from zepto											# Useful for : Which category is more profitable & which need more attentions?
-- WHERE outOfStock = 0
group by category
order by Total_Revenue desc; 

-- Q4. Find all products where MRP is greater than Rs.500 and discount is less than 10%.
select distinct name, mrp, discountPercent from zepto
where mrp > 500						# Useful for : Output products are Not Premium products so less than 10% discount, but their popular & selling well already.
and discountPercent < 10			-- If its Premium & growing products, business will think about the discounts.
order by mrp desc,discountPercent desc ;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category, 
round(avg(discountPercent),2) as avg_discount from zepto
group by category						# Useful for : Marketing Team : which product category Price cuts are happening & Optimize based on this.
order by avg_discount desc
limit 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name , weightInGms, discountedSellingPrice,
round(discountedSellingPrice / weightInGms, 4) as price_per_gram 
from zepto
where weightInGms >= 100								# Useful for business in "Internal Pricing strategies"
order by price_per_gram;								-- Helpful to customers for comparing products & find the "value for money"

-- Q7.Group the products into categories like Low, Medium, Bulk by weightingms.
select distinct name, weightInGms,
case
when  weightInGms < 1000 then 'low'
when  weightInGms < 5000 then 'Medium'
else 'bulk'								# Useful for business this in segmentation is "Packaging, Delivery planing, bulk order strategies"
end as weight_category					
from zepto
order by weight_category;

-- Q8.What is the Total Inventory Weight Per Category
select category, 
sum(weightInGms * availableQuantity) as Total_weight
from zepto								# Useful for Warehouse planning, identity bulky product categories
where outOfStock = 0					
group by category
order by Total_weight;

-- Q9.Find the 5 Categories making losses
select category,
sum((discountedSellingPrice - mrp) * availableQuantity) as total_profit_loss
from zepto								# Useful for business : Identify loss making category - review discount strategy
group by category
order by total_profit_loss asc
limit 5;

-- Q10. Find the most expensive product in each category.
with ProductRank as (
select name, category, discountedSellingPrice,
row_number() over (partition by category order by discountedSellingPrice desc) as rank_best
from zepto)								# Useful for business : to identify premium products per category(Marketing / promotion).
select * from ProductRank
where rank_best = 1;
