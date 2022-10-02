--I have solved the below questions and updated the solution in git hib. 
--The source link is -- https://8weeksqlchallenge.com/case-study-1/

----Problem Statement
--Danny wants to use the data to answer a few simple questions about his customers, 
--especially about their visiting patterns, how much money they’ve spent and also 
--which menu items are their favourite. Having this deeper connection with his 
--customers will help him deliver a better and more personalised experience for his loyal customers.

--He plans on using these insights to help him decide whether he should expand the existing customer
-- loyalty program - additionally he needs help to generate some basic datasets so his team can easily 
--inspect the data without needing to use SQL.

--Danny has provided you with a sample of his overall customer data due to privacy issues 
--- but he hopes that these examples are enough for you to write fully functioning SQL queries 
--to help him answer his questions!

--Danny has shared with you 3 key datasets for this case study:

--sales
--menu
--members


CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  select * from sales
  select * from menu
  select * from members
  
 /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select customer_id, sum(price) as total_amount
from menu a
join sales b on a.product_id=b.product_id
group by customer_id
order by customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(order_date) as no_of_days
from menu a
join sales b on a.product_id=b.product_id
group by customer_id
order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

with cte as (
             select  order_date,customer_id,a.product_id,
             rank() over(partition by customer_id order by order_date)
             from menu a
             join sales b on a.product_id=b.product_id
             order by order_date
            )
select distinct product_name, customer_id 
from cte
join menu on menu.product_id=cte.product_id
where rank = 1
order by customer_id

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  
with cte as (
             select customer_id,b.product_id, count(b.product_id) as no_of_times
            ,rank() over(partition by customer_id order by b.product_id desc)
            from menu a
            join sales b on a.product_id=b.product_id
            group by customer_id,b.product_id
            order by customer_id)
select  product_name, customer_id 
from cte 
join menu on menu.product_id=cte.product_id
where rank = 1
order by customer_id

-- 5. Which item was the most popular for each customer?

with cte as (
             select customer_id,b.product_id, count(b.product_id) as no_of_times
            ,rank() over(partition by customer_id order by b.product_id desc)
            from menu a
            join sales b on a.product_id=b.product_id
            group by customer_id,b.product_id
            order by customer_id)
select  product_name, customer_id 
from cte 
join menu on menu.product_id=cte.product_id
where rank = 1
order by customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
  
with cte as (
             select  order_date,customer_id,a.product_id,
             rank() over(partition by customer_id order by order_date)
             from menu a
             join sales b on a.product_id=b.product_id
             where order_date >= '2021-01-07'
             order by order_date
            )
select distinct product_name, cte.customer_id 
from cte
join menu on menu.product_id=cte.product_id
join members on members.customer_id=cte.customer_id
where rank = 1
order by cte.customer_id;

-- 7. Which item was purchased just before the customer became a member?

with cte as (
             select  order_date,customer_id,a.product_id,
             rank() over(partition by customer_id order by order_date desc)
             from menu a
             join sales b on a.product_id=b.product_id
             where order_date < '2021-01-07'
             order by customer_id,order_date desc
            )
select distinct product_name, cte.customer_id 
from cte
join menu on menu.product_id=cte.product_id
join members on members.customer_id=cte.customer_id
where rank = 1
order by cte.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?

with cte as (
             select  customer_id,count(b.product_id) as total_item,sum(a.price) as amount_spent
             from menu a
             join sales b on a.product_id=b.product_id
             where order_date < '2021-01-07'
             group by customer_id 
             order by customer_id
            )
select cte.customer_id,cte.total_item,cte.amount_spent
from cte
join members on members.customer_id=cte.customer_id
order by cte.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
  
  with cte as (
                select b.customer_id , count(b.product_id) as total_sushi, sum(a.price) as total_price
                from menu a 
                join sales b on a.product_id=b.product_id
                where product_name = 'sushi'
                group by b.customer_id
      )
 select * , total_price*2*10 as points   
 from cte
 order by cte.customer_id;
  
  
-- 10. In the first week after a customer joins the program 
--(including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January? 

select customer_id , sum(points) as total_earned_points
from (
     with cte as (
             select  order_date,customer_id,a.product_id
             from menu a
             join sales b on a.product_id=b.product_id
             where order_date >= '2021-01-07'
             order by order_date
            ),
     count_data as (
                select b.customer_id , count(b.product_id) as total_sushi, sum(a.price) as total_price
                from menu a 
                join sales b on a.product_id=b.product_id
                group by b.customer_id
                 )
select distinct product_name, cte.customer_id ,order_date, count_data.total_price*2*10 as points  
from cte
join count_data on count_data.customer_id=cte.customer_id
join menu on menu.product_id=cte.product_id
join members on members.customer_id=cte.customer_id
where order_date < '2021-01-31'
order by cte.customer_id
    ) x
group by customer_id,points    
order by customer_id;

---- Extra problems 
--Join All The Things

  select * from sales
  select * from menu
  select * from members
  
  select x.customer_id,x.order_date,x.product_name,x.price, coalesce(x.member ,'N') as member
  from (
  select a.customer_id,a.order_date,b.product_name,b.price,
  case  when c.join_date > a.order_date then 'N'
       when c.join_date <= a.order_date then 'Y'
  end as member     
  from sales a
  join menu b on a.product_id=b.product_id
  left join members c on a.customer_id=c.customer_id
  order by a.customer_id, a.order_date
  ) x
  
  -- Ranking for members 
  
  SELECT q.customer_id,q.order_date,q.product_name,q.price,q.member
  ,case when q.value is not null then dense_rank() over(partition by q.customer_id order by q.value)
           end as ranking  
  from (
        with cte as (
        select y.customer_id,y.order_date,y.product_name,y.price, coalesce(y.member ,'N') as member
        from (
                select a.customer_id,a.order_date,b.product_name,b.price,
                case  when c.join_date > a.order_date then 'N'
                      when c.join_date <= a.order_date then 'Y'
                end as member     
                from sales a
                join menu b on a.product_id=b.product_id
                left join members c on a.customer_id=c.customer_id
                order by a.customer_id, a.order_date
             ) y
                     )
 select *,
   case when cte.member='Y' THEN cte.order_date
       END AS VALUE
 from cte
 order by cte.customer_id, cte.order_date
      )q
 order by q.customer_id,q.order_date;
    