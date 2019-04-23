 /*
Create a schema named dataext 
Create a table dataext.time_table

field state :'C' -> created 'D' -> deleted

Usage

test=# create table t1 (id integer,field text);
CREATE TABLE
test=# select relid::regclass,* from dataext.time_table;
 relid | relid | command_tag  |          create_time          | state | delete_time 
-------+-------+--------------+-------------------------------+-------+-------------
 t1    | 16430 | CREATE TABLE | 2019-04-23 21:15:51.411294+02 | C     | 


test=# drop table t1;
DROP TABLE
test=# select relid::regclass,* from dataext.time_table;
 relid | relid | command_tag  |          create_time          | state |          delete_time          
-------+-------+--------------+-------------------------------+-------+-------------------------------
 16430 | 16430 | CREATE TABLE | 2019-04-23 21:15:51.411294+02 | D     | 2019-04-23 21:16:13.820549+02

test=# 
 
 */
 
 DROP EVENT TRIGGER IF EXISTS on_drop_table;
 DROP EVENT TRIGGER IF EXISTS on_create_table;
 DROP SCHEMA IF EXISTS dataext cascade;

-- create schema dataext
create schema dataext;

-- create timetable

CREATE UNLOGGED TABLE dataext.time_table
(
  relid oid NOT NULL,
  command_tag text,
  create_time timestamp with time zone DEFAULT now(),
	state char(1) check (state in ('C','D')) default 'C',
	delete_time timestamp with time zone,
  CONSTRAINT time_table_pkey PRIMARY KEY (relid)
)
WITH (
  OIDS=FALSE
);

-- save time creation tables
CREATE OR REPLACE FUNCTION on_create_table_func()
RETURNS event_trigger AS $$
DECLARE
	r record;
BEGIN
	for r in select * from pg_event_trigger_ddl_commands() loop
	    if r.object_type ='table' then 
	      insert into dataext.time_table ( relid,command_tag)values (r.objid,r.command_tag);
	    end if;
	end loop;
END
$$
LANGUAGE plpgsql;

--DROP EVENT TRIGGER on_create_table;
CREATE EVENT TRIGGER on_create_table ON ddl_command_end WHEN TAG IN ('CREATE TABLE','CREATE TABLE AS') EXECUTE PROCEDURE on_create_table_func(); 

CREATE OR REPLACE FUNCTION on_drop_table_func() RETURNS event_trigger AS $$
DECLARE
	r record;
BEGIN
	for r in select * from pg_event_trigger_dropped_objects () loop
	   if r.object_type='table' then
		 		update dataext.time_table set state ='D',delete_time=now() where relid= r.objid;
	   end if;
	end loop;
END
$$
LANGUAGE plpgsql;

-- DROP EVENT TRIGGER on_drop_table;
CREATE EVENT TRIGGER on_drop_table ON sql_drop WHEN TAG IN ('DROP TABLE') EXECUTE PROCEDURE on_drop_table_func();

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
