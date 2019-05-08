 -- Keeps track of the creation date of a table. 
 -- Usage: select * from  dataext.time_table;

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