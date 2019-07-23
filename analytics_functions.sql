-- compute the percentage of total cash traffic that occurs by hour in the inbound direction for each plaza on a given day.
-- we need two pieces of information: the number of cash, inbound cars per hour for each plaza and total number of cars, inbound, for each plaza in that day.

select plaza, hr,
	vehiclescash::float / sum(vehiclescash) over (partition by plaza)
from cls.mta
where mtadt = 'date' and direction = 'I';

-- function () over (partition by __
--		     order by __
--		     rows between __ and __)

-- calculate the percentage of revenue that each transaction represents for each userid
select user_id, dt, amt, amt::float / sum(amt) over (partition by userid) as pct
from cls.transaction

-- percentage likelihood that a person who has made X purchases makes another one

select 
	transnum
	, sum(case when transnum = totaltrans then 1 else 0 end) :: float / count(1) as pct --??
from
(select row_number(userid) over (partition by userid) as transnum
	, count(1) over (partition by userid) as totaltrans
) as innerq
group by 1;


