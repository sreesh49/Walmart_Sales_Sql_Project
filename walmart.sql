

---Business Problems

--Q1.Find different payment method and number of transactions ,number of quantity sold

select payment_method,count(*) as no_of_transactions,
sum(quantity) as number_of_quantity_sold
from walmart
group by payment_method

--Q2.Identify the highest rated category in each branch ,displaying the branch category and avg rating

select * from walmart

select * from
(
select branch,category,avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by branch,category
)
where rank=1

--Q3. Identify the busiest day for each branch based on the number of transactions.

select * from walmart

select * from
(
select branch,to_char(to_date(date,'DD/MM/YYY'),'day') as day_name,
count(*) as no_transactions,
rank() over(partition by branch order by count(*)) as rank
from walmart
group by branch,day_name
)
where rank=1


--Q4.Calculate the total quantity of items sold per payment method .List payment method and total quantity.


select * from walmart

select payment_method,sum(quantity) as total_quantity
from walmart
group by payment_method
order by total_quantity desc

--Q5.Determine the average,minimum and maximum rating of products for each city.
-----List the city,average_rating,min_rating and max_rating.



select city,category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by city,category


--Q6.Calculate the total profit for each category by considering total_profit as 
--(unit_price*quantity*profit_margin)
--List category and total_profit,ordered from highest to lowest profits.


select category,sum(total*profit_margin) as profit
from walmart
group by category 
order by profit desc

--Q7.Determine the most common payment method for each branch
--Display branch and the preferred payment method.


with cte as(
select branch,payment_method,
count(*) as total_count,
rank() over(partition by branch order by count(*))
from walmart
group by branch,payment_method
)
select * from cte where rank=1

--Q8.Categorize sales into 3 groups morning,afternoon,evening.
---Find out which of the shift and number of invoices

select * from walmart

select branch,
case
      when extract (hour from (time::time)) < 12 then 'Morning'
	  when extract (hour from (time::time)) between 12 and 17 then 'Afternoon'
	  else 'Evening'
	  end day_time,
	  count(*)
from walmart
group by branch,day_time
order by branch,count(*) desc


--Q9.Identify 5 branch with highest decrease ratio in 
---revenue compare to last year (current year 2023 and last year 2022)

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart;

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5