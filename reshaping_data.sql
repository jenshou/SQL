-- Calculating the average revenue per user is a common application for reshaping data
-- Companies often have transactional data, or data that contains info on what users purchased over time. It is important to convert this info into a form that represents the per-user revenue generated.

-- The idea is to build a cohort-based estimate of the amount of money that a user generates

-- Calculate the avg amount spent by each customer:

select
	sum(amt) / count(distinct userid) as amtPerUser
from trans;

-- Avg amount per customer for each country:

select 
	locale, sum(amt) / count(distinct userid) as amtPerUser
from trans
group by 1;

-- When the same userid has different locale information, we could asign a single locale to each user in preferrable ways.

--use the latest one(first one by time):
select new_locale
	, sum(amt) / count(distinct lhs.userid) as amtPerUser
from

-- First create a distinct (userid, dt) pair, each user only has one dt
	(select min(dt) as dt, userid
	from trans 
	group by 2) as lhs
join 

-- Full join on userid and dt from the original table.
-- we have "new locale" from here because all the userid&dt has the modified locale after the inner join
	(select userid, locale as new_locale, dt
	from trans) as rhs
using(dt, userid)
-- Finally left join the userid, dt and new locale to the original table, this gives us all the information but with modified locale.
left join
	trans
using(userid)
group by 1;	

