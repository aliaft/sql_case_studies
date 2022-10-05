/*******************************************************************************
Digital Music Store Analysis
This project will teach you how to analyze the Chinook playlist database by Udacity. 
You can examine the dataset with SQL and help the store understand its business growth by answering simple questions.

Dataset: Here is an image that describes the information contained in the database.

/*******************************************************************************
   Chinook Database - Version 1.4
   Script: Chinook_PostgreSql.sql
   Description: Creates and populates the Chinook database.
   DB Server: PostgreSql
   Author: Luis Rocha
   License: http://www.codeplex.com/ChinookDatabase/license
********************************************************************************/
select * from PlaylistTrack;
select * from Playlist;
select * from InvoiceLine;
select * from Invoice;
select * from Customer;
select * from Employee;
select * from Track;
select * from Album;
select * from Artist;
select * from MediaType;
select * from Genre;


-- SQL Project Idea: Below is a few sample questions you can attempt to practice on this database.

-- Q1. Which city corresponds to the best customers?

select distinct r.city,
       case when r.rnk=1 then 'Best Customers'
            else 'Normal Customers'
       end as Customer_type
from (  
       select q.city, q.spend,
       dense_rank() over(order by q.spend desc)as rnk
       from (       
             with cte as (
                          select a.city, (b.unitprice * b.quantity) as Total_spent
                          from Customer a 
                          join Invoice x on a.CustomerId=x.CustomerId
                          join InvoiceLine b on x.InvoiceId=b.InvoiceId
                          order by (b.unitprice * b.quantity) desc
                         )
             select cte.city,sum(cte.Total_spent) as spend
             from cte
             group by cte.city    
             )  q) r
order by r.city;

-- Q2.The highest number of invoices belongs to which country?

select billingcountry as Country
from (
      select billingcountry , count(1)
      from Invoice
      group by billingcountry
      order by count(1) desc) x
limit 1;

-- Q3. Name the best customer (customer who spent the most money).
    
select * 
from (
      with cte as (
                   select a.firstname,a.lastname,(b.unitprice * b.quantity) as unit_spent
                   from Customer a 
                   join Invoice x on a.CustomerId=x.CustomerId
                   join InvoiceLine b on x.InvoiceId=b.InvoiceId
                   order by (b.unitprice * b.quantity) desc
                   )
      select cte.firstname,cte.lastname,sum(cte.unit_spent) as total_spent
      from cte
      group by cte.firstname,cte.lastname
     )x
order by x.total_spent desc;

/* Q4. Suppose you want to host a rock concert in a city and want to know which location should host it.
       Query the dataset to find the city with the most rock-music listeners to answer this question. */
	   
with cte as (
             select a.city,count(c.GenreId) as Rock_listener
             from Customer a 
             join Invoice x on a.CustomerId=x.CustomerId
             join InvoiceLine b on x.InvoiceId=b.InvoiceId
             join Track c on b.TrackId=c.TrackId
             join Genre d on c.GenreId=d.GenreId
             where d.name = 'Rock'
             group by city
            )
select cte.city
from cte
order by cte.Rock_listener desc
limit 1

--Q5. If you want to know which artists the store should invite,find out who is the highest-paid and most-listened-to.

with cte as (   
             select a.name,sum(e.total),count(d.Quantity)
             from Artist a
             join Album b on a.ArtistId=b.ArtistId
             join Track c on b.AlbumId=c.AlbumId
             join InvoiceLine d on c.TrackId=d.TrackId
             join Invoice e on d.InvoiceId=e.InvoiceId
             group by a.name
            )
select cte.name ,cte.sum as Highest_paid,cte.count as Most_listened
from cte
order by cte.sum desc
limit 1;

--Q6. Are there any albums owned by multiple artist?

select albumid, count(1) from Album
group by albumid
having count(1) > 1;

-- Q7. Is there any invoice which is issued to a non existing customer?
    
select * from Invoice I
where not exists (select * from customer c
                  where c.customerid = I.customerid);
				  
--Q8. Is there any invoice line for a non existing invoice?

select a.* 
from InvoiceLine a
left outer join Invoice b on a.InvoiceId=b.InvoiceId;

-- Q9. Are there albums without a title?

select * from Album where title = ' ';

-- Q10. Find the artist who has contributed with the maximum no of songs.Display the artist name and the no of albums.

with cte as (
             select a.Name , count(b.AlbumId) as No_of_albums
             from Artist a
             join Album b on a.ArtistId=b.ArtistId
             group by a.Name
            ) 
select * 
from cte x
order by x.No_of_albums desc
limit 1;

--Q11. Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select a.firstname,a.lastname,a.email,a.country,d.name 
from Customer a 
join Invoice x on a.CustomerId=x.CustomerId
join InvoiceLine b on x.InvoiceId=b.InvoiceId
join Track c on b.TrackId=c.TrackId
join Genre d on c.GenreId=d.GenreId
where d.name in ('Rock','Jazz','Pop');

-- Q12. Find the employee who has supported the most no of customers.Display the employee name and designation.

with cte as (
             select a.lastname,a.firstname,a.title,count(supportrepid) as most_no_cust
             from Employee a
             join Customer b on a.EmployeeId=b.supportrepid
             group by a.lastname,a.firstname,a.title
            )
select * 
from cte 
order by cte.most_no_cust desc
limit 1;

-- Q13. Which city corresponds to the best customers?

with cte as (
             select a.city,sum(b.total) as ts
             from Customer a
             join Invoice b on a.CustomerId=b.CustomerId
             group by a.city
             )
select cte.city 
from cte
order by cte.ts desc
limit 1;

-- Q14. The highest number of invoices belongs to which country?

select billingcountry as Country
from (
      select billingcountry , count(1)
      from Invoice
      group by billingcountry
      order by count(1) desc) x
limit 1;

