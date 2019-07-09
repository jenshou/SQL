-- connecting to any database: use ODBC and JDBC APIs

-- connecting to PstgreSQL: use psycogp2
-- need to provide host, dbname, user and password information

conn_string = "host=`%s` user=`%s` password=`%s`" % (host, dbname, user, password)
Sconn = psycopg2.connect(conn_string)
Scur = Sconn.cursor()

cmds = ["""create table cls.cars(

year int
, enddate date
, countyname varchar(20)

);"""]

for x in cmds:
    try:
	Scur.execute(x)
	Sconn.commit()
    except psycogp2.ProgrammingError:
	print("""Caution Failed: `%s`""" %x)
	Sconn.rollback()

