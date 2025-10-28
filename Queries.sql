# Business problems:
-- ======================= 

-- Walmart Business Problems
-- 1. Analyze Payment Methods and Sales

-- Question: What are the different payment methods, and how many transactions and items were sold with each method?

-- Purpose: This helps understand customer preferences for payment methods, aiding in payment optimization strategies.
```sq
  select payment_method,count(*),sum(quantity) as total from walmart group by payment_method order by total desc;
```

-- 2. Identify the Highest-Rated Category in Each Branch

-- Question: Which category received the highest average rating in each branch?

-- Purpose: This allows Walmart to recognize and promote popular categories in specific branches, enhancing customer satisfaction and branch-specific marketing.
select branch,category, avg(rating) as total_average, rank() over(partition by branch order by avg(rating) desc) from walmart group by branch,category;

-- 3. Determine the Busiest Day for Each Branch

-- Question: What is the busiest day of the week for each branch based on transaction volume?

-- Purpose: This insight helps in optimizing staffing and inventory management to accommodate peak days.
select branch,dayname(str_to_date(date,'%d/%m/%y')) as day_name ,count(*) as total_transaction from walmart group by branch,day_name order by branch,total_transaction desc;

-- 4. Calculate Total Quantity Sold by Payment Method

-- Question: How many items were sold through each payment method?

-- Purpose: This helps Walmart track sales volume by payment type, providing insights into customer purchasing habits.

select payment_method,count(*)as total_payments,sum(quantity) from walmart group by payment_method order by total_payments desc;
-- 5. Analyze Category Ratings by City

-- Question: What are the average, minimum, and maximum ratings for each category in each city?

-- Purpose: This data can guide city-level promotions, allowing Walmart to address regional preferences and improve customer experiences.
select city,category,min(rating)as minimum,max(rating)as maximum ,avg(rating)as average from walmart group by city,category;


-- 6. Calculate Total Profit by Category

-- Question: What is the total profit for each category, ranked from highest to lowest?

-- Purpose: Identifying high-profit categories helps focus efforts on expanding these products or managing pricing strategies effectively.
select category ,sum(total)as total_revenue,sum(total*profit_margin) as total_profit from walmart group by category;


-- 7. Determine the Most Common Payment Method per Branch

-- Question: What is the most frequently used payment method in each branch?

-- Purpose: This information aids in understanding branch-specific payment preferences, potentially allowing branches to streamline their payment processing systems.

create view payment as select branch,payment_method,count(*)as total ,rank() over(partition by branch order by count(*) desc) as `rank` from walmart group by branch,payment_method ;
show tables;
select * from payment where `rank` =1;
-- 8. Analyze Sales Shifts Throughout the Day

-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

-- Purpose: This insight helps in managing staff shifts and stock replenishment schedules, especially during high-sales periods.

select branch, case when hour(str_to_date(time,'%H:%i:%s')) between 5 and 11 then 'Morning' when hour(str_to_date(time,'%H:%i:%s')) between 12 and 16 then 'Afternoon' when hour(str_to_date(time,'%H:%i:%s')) between 17 and 20 then 'Evening' else 'Night' end as day_time ,count(*) from walmart group by branch,day_time  order by branch,count(*)desc;  



-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year

-- Question: Which branches experienced the largest decrease in revenue compared to the previous year?

-- Purpose: Detecting branches with declining revenue is crucial for understanding possible local issues and creating strategies to boost sales or mitigate losses.

select *,year(str_to_date(date,'%d/%m/%y'))as year_value from walmart;

create view revenue_2022 as select branch,sum(total) as revenue from walmart where year(str_to_date(date,'%d/%m/%y'))=2022 group by branch order by branch;
create view revenue_2023 as select branch,sum(total) as revenue from walmart where year(str_to_date(date,'%d/%m/%y'))=2023 group by branch order by branch;
select ls.branch,ls.revenue as last_year_revenue ,cr.revenue as current_year_revenue,round((ls.revenue-cr.revenue)/ls.revenue*100,2) as ratio from revenue_2022 as ls join revenue_2023 as cr on ls.branch=cr.branch where ls.revenue > cr.revenue order by ratio desc limit 5;

