-- Check if replica is on line
--
select * from pg_stat_replication

-- Check last trasaction committed - to be executed on the replica server
--
select pg_last_xact_replay_timestamp();

-- Returns 0 if the replica server has been misaligned for more than 5 minutes- to be executed on the replica server
-- 
select pg_last_xact_replay_timestamp();
SELECT CASE WHEN (EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM pg_last_xact_replay_timestamp())) / 60::int4 > 5 THEN 0::INT4 ELSE 1::int4 END AS CHECK_REPLICA

