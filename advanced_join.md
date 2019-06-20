# 1
# to verify that there is no missing data within MTC table
# in order to do that we can create a synthetic table which should have all values:

select * from
(select distinct mtadt from cls.mta) as lhs
cross join 
(select distinct hr from cls.mta) as rhs1
cross join
(select distinct plaza from cls.mta) as rhs2

# now we have every possible combinition of the three columns, we can then join this back against the original data to see if there are any missing values:

select lhs.mtadt, count(1)
	from
	(select distinct mtadt from cls.mta) as lhs
	cross join 
	(select distinct hr from cls.mta) as rhs1
	cross join
	(select distinct plaza from cls.mta) as rhs2
	left join
	cls.mta
	using(mtadt, hr, plaza)
where mta.mtadt is null
group by 1;

# For "outbound" plaza 1, on 2015-11-29, what percentage of the total EZ-pass traffic came each hour?

# We need to know a few things:
# (1) Hour
# (2) EZ pass traffic for each hour on that day
# (3) Total EZ pass traffic for that day with given criteria

# to break it down:
# first we want (3)

select sum(vehiclesez) as totalez, mtadt, plaza
from cls.mta
where mtadt = '2015-11-29' and direction = 'O' and plaza = 1
group by 2, 3;

# then we want the per-hour number:
select vehiclesez, mtadt, plaza, hr
from cls.mta
where mtadt = '2015-11-19' and direction = 'O' and plaza = 1

# now let's join the two tables :)

select 
	vehiclesez :: float / totalez as pct
	, hr
	, lhs.plaza
from
	(select 
		vehiclesez, plaza, hr
	from cls.mta
	where mtadt = '2015-11-19' and direction = 'O'
	and plaza = 1) as lhs
left join
	(select sum(vehiclesez) as totalez
		,plaza
	from cls.mta
	where mtadt = '2015-11-29' and direction = 'O'
	      and plaza = 1
	group by 2) as rhs
using(plaza)
order by hr asc;

# Let's try doing the same thing for multiple plazas and multiple days,
# we can remove things from the criteria and add things to JOIN:
# remember to cover cases whe totalez = 0 to avoid error
select case when totalez = 0 then null
	else vehiclesez :: float / totalez 
	end as pct
	, hr
	, lhs.plaza
from 
	(select vehiclesez, plaza, hr
	from cls.mta
	where direction = 'O') as lhs
left join
	(select sum(vehiclesez) as totalez
		, mtadt, plaza
	from cls.mta
	where direction = 'O'
	group by 2, 3) as rhs
using(plaza, mtadt)
order by hr asc;

# Let's create a running average for the last two hours(3 data points) on inbound traffic using the EZ pass for each plaza

# First try brutally matching them with time

select lhs.hr, lhs.mtadt, lhs.plaza, lhs.vehiclesez
       , sum(rhs.vehiclesez) :: float / count(rhs.vehiclesez) as running
from 
	(select vehiclesez, hr, mtadt, plaza
	from cls.mta
	where direction = 'I') as lhs
left join
	(select vehiclesez, hr, mtadt, plaza
	from cls.mta
	where direction = 'I') as rhs
on
	lhs.plaza = rhs.plaza
	and (   # condition 1: if the hour >= 2, just match based on the same date and when the right hand side hour is in the previous 2 hours
		(lhs.hr >= 2
		and
		lhs.mtadt = rhs.mtadt
		and
		rhs.hr >= lhs.hr - 2
		and
		rhs.hr <= lhs.hr)
	or (    # condition 2: if the hour is equal to 1 (1am), then match either the hour zero on the same day or hour 23 from yesterday
		lhs.hr = 1
		and (
				(lhs.mtadt - 1 = rhs.mtadt and rhs.hr = 23)))
	or(	# condition 3: if the hour is equal to 0 (0am), then match either the hour zero on the same day or hour 22 or 23 from yesterday
		lhs.hr = 0
		and(
			(lhs.mtadt - 1) = rhs.mtadt
			and rhs.hr in (22, 23))
			or(
			lhs.mtadt = rhs.mtadt
			and
			rhs.hr = 0)
		)
	   )
	   )
# the matching will result in a 3x larger dataset since each row in the lhs matches 3 in the rhs, to create average for those three we group by them into 1
group by 1, 2, 3, 4;

# or use timestamp and interval operator to handle the cross-day problem:

select lhs.mtatime, lhs.plaza, lhs.vehiclesez
	, sum(rhs.vehiclesez) :: float / count(rhs.vehiclesez) as running
from
	(select
		mtadt || ' ' || hr::varchar || ':00') ::timestamp as mtatime
		, plaza, vehiclesez
	from cls.mta
	where direction = 'I' and plaza = 1) as rhs
on
	lhs.plaza = rhs.plaza
	and rhs.mtatime >= lhs.mtatime - interval '2 hour'
	and rhs.mtatime <= lhs.mtatime
group by 1, 2, 3
order by 1;


