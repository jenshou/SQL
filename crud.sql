-- create table
create table sma.tablename(
var1 int,
var2 varchar(1))

-- insert value in
insert into sma.tablename values (1, 'James'), (2, 'Wendy');

--update existing value
update sma.tablename
set var1 = var1 + 1 where var2 = 'Wendy';

-- new creation
insert into sma.tablename values (5, 'Julia');

-- Transactions
-- units of works to be treated as a single entity within a database.

begin;

update sma.tablename set var1 = var1 + 5 where var2 = 'Julia';

commit;
