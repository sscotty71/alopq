-- This query needs the pgstattuple extension installed

SELECT pg_size_pretty(table_len) AS table_len
	,pg_size_pretty(tuple_len) as tuple_len
	,pg_size_pretty(table_len-tuple_len) as not_used
	,pg_size_pretty(free_space) AS free_space
	,pg_size_pretty(dead_tuple_len) as dead_tuple_len
	,tuple_count
	,dead_tuple_count
	,tuple_percent
	,dead_tuple_percent
	,free_percent
FROM pgstattuple('tablename');-- put here the table name
