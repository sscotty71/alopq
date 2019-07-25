-- Autovacuum 
-- check for dead rows / vacuum / autovacuum
select schemaname,relname,n_dead_tup,n_live_tup, n_mod_since_analyze, n_tup_hot_upd,last_autovacuum,last_autoanalyze,autovacuum_count, autoanalyze_count  
from pg_stat_all_tables order by n_dead_tup desc;

--Last autovacuums
SELECT * FROM pg_stat_user_tables where last_autovacuum is not null order by last_autovacuum desc;