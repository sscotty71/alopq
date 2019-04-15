-- Here some query useful to check the entire cluster.

-- Check if the cluster is in recovery mode : returns 1 if the system is in recovery mode
SELECT CASE WHEN pg_is_in_recovery() IS true THEN '1'::INT ELSE '0'::INT END AS is_in_recovery;


-- Check sizes 
SELECT pg_size_pretty(sum(relation_bytes)) AS tables_size
	,--Table Sizes
	pg_size_pretty(sum(index_bytes)) AS indexes_size
	,--Index Sizes
	pg_size_pretty(sum(toast_bytes)) AS toasts_size -- Toast Sizes (binary objects)
FROM (
	SELECT c.oid
		,nspname AS table_schema
		,relname AS TABLE_NAME
		,coalesce(pg_total_relation_size(c.oid) - pg_total_relation_size(reltoastrelid), 0) AS relation_bytes
		,coalesce(pg_indexes_size(c.oid), 0) AS index_bytes
		,coalesce(pg_total_relation_size(reltoastrelid), 0) AS toast_bytes
	FROM pg_class c
	LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
	WHERE relkind = 'r'
	) a;

-- Wal sizes : PostgreSQL >= 10.x
SELECT distinct pg_size_pretty((count(*) over() * 16 * 1024 * 1024)::int8) as wal_total_size from pg_ls_dir('pg_wal');

-- Wal sizes : PostgreSQL <= 9.6.x
SELECT distinct pg_size_pretty((count(*) over() * 16 * 1024 * 1024)::int8) as wal_total_size from pg_ls_dir('pg_xlog');

--Indexes not used
SELECT count(*) as not_used_indexes from pg_catalog.pg_stat_user_indexes where idx_scan=0;

-- XID warning : returns the number of available xids.
SELECT autovacuum_freeze_max_age - max_xid AS available_xid
FROM (
	SELECT '1'::TEXT AS id
		,setting::int8 AS autovacuum_freeze_max_age
	FROM pg_settings
	WHERE name = 'autovacuum_freeze_max_age'
	) V1
INNER JOIN (
	SELECT '1'::TEXT AS id
		,max(age(datfrozenxid))::int8 AS max_xid
	FROM pg_database
	) V2 using (id);

-- Vacuum counts
SELECT sum(vacuum_count) AS vacuum_count
	,sum(autovacuum_count) AS autovacuum_count
	,sum(analyze_count) AS analyze_count
	,sum(autoanalyze_count) AS autoanalyze_count
FROM pg_stat_all_tables;

--Cluster Stats

SELECT sum(numbackends) AS numbackends
	,sum(xact_commit) AS xact_commit
	,sum(xact_rollback) AS xact_rollback
	,pg_size_pretty(sum(blks_read * 8192)::int8) AS bytes_read
	,pg_size_pretty(sum(blks_hit * 8192)::int8) AS bytes_hit
	,sum(tup_returned) AS tup_returned
	,sum(tup_fetched) AS tup_fetched
	,sum(tup_inserted) AS tup_inserted
	,sum(tup_updated) AS tup_updated
	,sum(tup_deleted) AS tup_deleted
	,sum(conflicts) AS conflicts
	,sum(temp_files) AS temp_files
	,pg_size_pretty(sum(temp_bytes)::int8) AS temp_bytes
	,sum(deadlocks) AS deadlocks
	,sum(blk_read_time * 8192) AS blk_read_time
	,sum(blk_write_time * 8192) AS blk_write_time
	,(sum(xact_rollback) * 100) / (sum(xact_commit) + sum(xact_rollback)) AS perc_rollback
	,sum(blks_hit) * 100 / sum(blks_hit + blks_read) AS hit_ratio
	,(sum(tup_fetched) * 100) / sum(tup_returned) AS returned_ratio
FROM pg_stat_database;
