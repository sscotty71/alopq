-- Check if replica is on line
--
select * from pg_stat_replication

-- Check last trasaction committed - to be executed on the replica server
--
select pg_last_xact_replay_timestamp();
