-- PostgreSQL >= 10.x
select * from pg_ls_waldir();
-- Search for basebackup
select * from pg_ls_waldir() where name ilike '%backup%';

-- Postgresql <= 9.6.x
SELECT * from pg_ls_dir('pg_xlog');

-- Search for basebackup
SELECT * from pg_ls_dir('pg_xlog') where pg_ls_dir ilike '%backup%';
