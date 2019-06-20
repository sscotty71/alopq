-- CREATE A FOREIGN DATA WRAPPER FOR POSTGRESQL DATA
CREATE FOREIGN DATA WRAPPER postgres_fdw HANDLER postgres_fdw_handler VALIDATOR postgres_fdw_validator;

-- Function that returns all the tables present in all the schemes of all the databases
-- 
-- Input parameters:
-- local_user : user with which I am connected to the database
-- remote_user : the user who connects to all the databases (usually remote_user = local_user)
-- password : password for the remote user
--
-- USAGE:
-- select * from list_all_tables('postgres','postgres','mypassword') order by 1,2,3
 
create or replace function list_all_tables(local_user text,remote_user text,remote_password text) returns table(dbname text,schemaname text,relname text) as
$$
DECLARE
ret text;
dbalias text;
dbname text;
BEGIN
   drop table if exists list_tables;
   create temp table list_tables (dbname text,schemaname text,tablename text) on commit drop;
   for dbalias,dbname in select datname||'_fw_lst',datname from pg_database where datname <>'postgres' and datistemplate ='f' loop
   EXECUTE FORMAT('CREATE SERVER IF NOT EXISTS %s  FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname ''%s'',fetch_size ''50000'',host ''127.0.0.1'',port ''5432'',use_remote_estimate ''true'')',dbalias,dbname);
   EXECUTE FORMAT ('CREATE USER MAPPING FOR %s SERVER %s OPTIONS (password ''%s'',user ''%s'')',local_user,dbalias,remote_password,remote_user);
   EXECUTE FORMAT('CREATE FOREIGN TABLE f_list_tables (relname text,relkind char,relnamespace oid) SERVER %s OPTIONS(schema_name ''pg_catalog'',table_name ''pg_class'')',dbalias);
   EXECUTE FORMAT('CREATE FOREIGN TABLE f_list_schemas (oid oid,nspname text) SERVER %s OPTIONS(schema_name ''pg_catalog'',table_name ''pg_namespace'')',dbalias);
   insert into list_tables select dbname,nspname,t.relname from f_list_tables t inner join f_list_schemas s on t.relnamespace = s.OID where t.relkind='r' and t.relname not ilike 'pg_%';
   EXECUTE FORMAT('DROP SERVER %s CASCADE ',dbalias);
  end loop;
  return query select lt.dbname,lt.schemaname,lt.tablename from list_tables lt;
END;
$$
language 'plpgsql'
