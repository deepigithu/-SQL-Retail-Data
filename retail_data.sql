select * from customer

select * from prod_cat_info

select * from Transactions

--DATA PREPARATION AND UNDERSTANDING

--1Q
 
select COUNT(*)
from customer
union all
select COUNT(*)
from prod_cat_info
union all
select COUNT(*)
from Transactions

--2Q

select COUNT(Qty)as return_tran
from Transactions
where Qty < 0


--5Q

select prod_cat 
from prod_cat_info
where prod_subcat='DIY'

--3Q

select tran_date, CONVERT(varchar, tran_date, 23) as formatdate
from  Transactions 

--4Q

select
MIN(tran_date)as start_date,
MAX(tran_date)as end_date,
DATEDIFF(DAY, MAX(tran_date), MIN(tran_date)) as Days,
DATEDIFF(MONTH, MAX(tran_date), MIN(tran_date)) as Months,
DATEDIFF(YEAR, MAX(tran_date), MIN(tran_date)) as Years
from Transactions


--DATA ANALYSIS

--1Q

select top 1 Store_type , COUNT(transaction_id) as count 
from Transactions
group by Store_type
order by count(transaction_id) desc


--2Q

select Gender,
COUNT(case when Gender='M' then 1 end)as Male,
COUNT(case when Gender='F' then 1 end)as Female
from Customer
group by Gender


--3Q

select  top 1 city_code,COUNT(customer_Id)as ID
from Customer
group by city_code
order by ID desc

--4Q

select COUNT(prod_subcat)as totalps
from prod_cat_info
where prod_cat='Books'

--5Q

select MAX(Qty)as maxqty 
from Transactions



--9Q
--Firstly joining the table i.e transaction,customer and product info table 
--applying condition for gender and category using subquery 
--finding aggreagtes and then grouping

select prod_subcat as subcat, gender,SUM(total_amt)as total_revenue
from Transactions t left join Customer c on t.cust_id=c.customer_Id
                    left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                    and t.prod_subcat_code=p.prod_sub_cat_code
where Gender like 'M'and prod_cat in(
                                      select prod_cat from prod_cat_info
                                      where prod_cat like 'Electronics'
                                    )									  
group by prod_subcat,Gender

--6Q
--Firstly joining the table i.e transaction and product info table
--applying condition for category
--then finding aggregates

select t.Store_type, SUM(total_amt)as net_revenue 
from Transactions t
                  left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                  and t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in('Electronic','Books')
group by Store_type

--7Q
--applying subquery firstly joining the table i.e transaction and customer table
--applying condition and grouping 

select COUNT(customer_id)as cust_count
from customer 
where customer_id in(
                       select cust_id 
					   from Transactions t
                                          left join customer c on t.cust_id=c.customer_Id
                       where total_amt not like '-%'
                       group by cust_id
                       having COUNT(transaction_id) > 10
                    )


--8Q
--Firstly joining table i.e transaction and product table
--then applying condition

select SUM(total_amt)as combined_amt 
from Transactions t
                   left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                   and t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in('Electronic','Clothing') and Store_type='Flagship Store'


--10Q
--joining the two table
--finding sales,returns and profit
--and grouping

select top 5 prod_subcat ,
[Subcategory] = p.prod_subcat,
[Sales]=ROUND(SUM(Cast(Case when Qty > 0 then Qty else 0 end as float)),2) ,
[Returns]=ROUND(SUM(Cast(Case when Qty < 0 then Qty else 0 end as float)),2) ,
ROUND(SUM(Cast( Case when Qty < 0 then Qty else 0 end as float)),2)*100/ROUND(SUM(Cast(Case when Qty > 0 then Qty else 0 end as float)),2)[Return%],
100 + ROUND(SUM(Cast(Case when Qty < 0 then Qty else 0 end as float)),2)*100/ROUND(SUM(Cast(Case when Qty > 0 then Qty else 0 end as float)),2) [Sales%]
from  Transactions t inner join prod_cat_info p on t.prod_subcat_code=p.prod_sub_cat_code
                                                and t.prod_cat_code=p.prod_cat_code
group by p.prod_subcat
             
--11Q
--convertion of date by where clause 
--then grouping

select cust_Id, SUM(total_amt)as revenue
from Transactions
where cust_id in(
                 select customer_id from customer
                 where DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) between 25 and 35)
                       and CONVERT(DATE,tran_date,103) between DATEADD(DAY,-30,(select MAX(CONVERT(DATE,tran_date,103)) from Transactions))
                       and (select MAX(convert(DATE,tran_date,103)) from Transactions
			   )
group by cust_id

			  

--12Q
--same as previous but joining the two table i.e transaction and product table
--applying condition

select top 1 prod_cat, SUM(total_amt)
from Transactions t
                    left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                    and t.prod_subcat_code=p.prod_sub_cat_code
where total_amt < 0 and
                   CONVERT(DATE,tran_date,103) between DATEADD(MONTH,-3,(select MAX(CONVERT(DATE,tran_date,103)) from Transactions))
                   and (select MAX(CONVERT(DATE,tran_date,103)) from Transactions)
group by prod_cat



--13Q
--here grouping by store type and using having clause to satisy condition

select Store_type, SUM(total_amt) as sales , SUM(Qty)as total_qty
from Transactions
group by Store_type
having SUM(total_amt) >= all(select SUM(total_amt) from Transactions group by Store_type)
               and SUM(Qty) >= all(select SUM(Qty) from Transactions group by Store_type)

--14Q
--joining the two table i.e transaction and product table
--and then grouping abd using have clause

select prod_cat, AVG(total_amt)as avg_amt
from Transactions t
                    left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                    and t.prod_subcat_code=p.prod_sub_cat_code
group by prod_cat
having AVG(total_amt) > (select AVG(total_amt) from Transactions)

--15Q
--joining two tables i.e transaction and product table
--using subquery

select prod_cat,prod_subcat, AVG(total_amt)as avg_rev, SUM(total_amt)as revenue
from Transactions t
                    left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                    and t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in(
                   select top 5 prod_cat
                   from Transactions t
                                      left join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
                                      and t.prod_subcat_code=p.prod_sub_cat_code
                   group by prod_cat
                   order by SUM(Qty) desc
                 )
group by prod_cat,prod_subcat














 
