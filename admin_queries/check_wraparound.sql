-- check wrapaound postgresql >=  10.x : source https://www.cybertec-postgresql.com/en/autovacuum-wraparound-protection-in-postgresql/
SELECT
       oid::regclass::text AS table,
       age(relfrozenxid) AS xid_age, 
       mxid_age(relminmxid) AS mxid_age, 
       least( 
(SELECT setting::int
            FROM    pg_settings
            WHERE   name = 'autovacuum_freeze_max_age') - age(relfrozenxid), 
(SELECT setting::int
            FROM    pg_settings
            WHERE   name = 'autovacuum_multixact_freeze_max_age') - mxid_age(relminmxid)  
) AS tx_before_wraparound_vacuum,
pg_size_pretty(pg_total_relation_size(oid)) AS size,
pg_stat_get_last_autovacuum_time(oid) AS last_autovacuum
FROM    pg_class
WHERE   relfrozenxid != 0
AND oid > 16384
ORDER BY tx_before_wraparound_vacuum;

-- check wrapaound postgresql <  10.x
SELECT
       oid::regclass::text AS table,
       age(relfrozenxid) AS xid_age, 
       mxid_age(relminmxid) AS mxid_age, 
       least( 
(SELECT setting::int
            FROM    pg_settings
            WHERE   name = 'autovacuum_freeze_max_age') - age(relfrozenxid), 
(SELECT setting::int
            FROM    pg_settings
            WHERE   name = 'autovacuum_multixact_freeze_max_age') - mxid_age(relminmxid)  
) AS tx_before_wraparound_vacuum,
pg_size_pretty(pg_total_relation_size(oid)) AS size,
pg_stat_get_last_autovacuum_time(oid) AS last_autovacuum
FROM    pg_class
WHERE   relfrozenxid::text::int8 <> 0
AND oid > 16384
ORDER BY tx_before_wraparound_vacuum;

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

-- XID warning : returns the number of available xids for each database
SELECT datname
	,max(age(datfrozenxid))::int8 AS max_xid
FROM pg_database
group by 1


-- Vacuum freeze analyze verbose for all databases using 2 cores
vacuumdb -a -F -z -v -j 2