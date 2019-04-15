
--Database size
select pg_size_pretty(pg_database_size('dbname'));

--Schema Size
select
 pg_size_pretty(sum(pg_relation_size(V.tablename::regclass)))
from
 (
 select
  schemaname || '.' || relname as tablename
 from
  pg_stat_all_tables
 where
  schemaname = 'schemaname') V -- Insert schema name


  -- Table size
select pg_size_pretty(pg_relation_size('tablename'::regclass)); -- Insert table name


-- Inside tales 
SELECT
pg_size_pretty(pg_relation_size(c.oid, 'main')) AS heap_size, -- heap size
pg_size_pretty(pg_relation_size(c.oid, 'fsm')) AS fsm_size, -- free space map  size
pg_size_pretty(pg_relation_size(c.oid, 'vm')) AS vm_size, -- visibility map size
pg_size_pretty(pg_relation_size(c.reltoastrelid)) AS toast_table_size,
pg_size_pretty(pg_relation_size(i.indexrelid)) AS toast_index_size
FROM pg_class c
LEFT OUTER JOIN pg_index i ON c.reltoastrelid=i.indrelid
WHERE c.relname = 'tablename';
