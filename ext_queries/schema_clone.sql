CREATE OR REPLACE FUNCTION import.clone_schema(
 source_schema text,
 dest_schema text)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$


DECLARE 
  objeto text;
  buffer text;
  sql text;
  r record;
BEGIN
    
 -- Creazione schema e tabelle
 
 EXECUTE 'CREATE SCHEMA ' || dest_schema ;
    FOR objeto IN
        SELECT TABLE_NAME::text FROM information_schema.TABLES WHERE table_schema = source_schema
    LOOP        
        buffer := dest_schema || '.' || objeto;
        EXECUTE 'CREATE TABLE ' || buffer || ' (LIKE ' || source_schema || '.' || objeto || ' INCLUDING CONSTRAINTS INCLUDING INDEXES INCLUDING DEFAULTS)';
        EXECUTE 'INSERT INTO ' || buffer || '(SELECT * FROM ' || source_schema || '.' || objeto || ')';
    END LOOP;

---- copia delle foreign key

for r in select V.relname,V.conname,pg_get_constraintdef(V.oid) as connstr
   from (
    select A.oid,conname,B.relname 
    from pg_constraint A 
    inner join pg_class B on A.conrelid=B.oid 
       inner join pg_namespace C on A.connamespace=C.oid     
    where A.contype = 'f'  
    and C.nspname=source_schema             
   ) V loop 
   buffer := replace(r.connstr,source_schema,dest_schema);
   sql:= 'ALTER TABLE '||dest_schema||'.'||r.relname||' ADD CONSTRAINT '||r.conname||' '||buffer;
  execute sql;
   
 end loop;  
 
END;

$BODY$;