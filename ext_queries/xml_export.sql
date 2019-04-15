-- export a single schema into a xml file
-- Usage: select export_schema_to_xml ('schema','file')

CREATE OR REPLACE FUNCTION export_schema_to_xml(
    p_schemaname text, --schema name
    p_path text -- absolute path file on the server with write permission for the postgres user
)
  RETURNS integer  AS
$BODY$
DECLARE
sql text;
r record;
w refcursor;
resultxml xml;
cn int4;

BEGIN
  drop table if exists t_1;
  drop table if exists t_1_xml;

  create temp table t_1_xml (out xml);
  create temp table t_1 as 
  select S.nspname as schemaname,C.relname,C.reltuples,
 case 
  when (C.reltuples/100000)::int4 = 0 THEN 1 
  else (C.reltuples/100000)::int4 
 end as n_loop
 from pg_namespace S 
 inner join pg_class C on (S.OID=C.relnamespace) 
 where S.nspname=p_schemaname and C.relkind='r' order by 3 desc;

for r in select * from t_1 loop
 raise notice 'Processing % ....',r.schemaname||'.'||r.relname;
 cn = 1;
 open w for execute 'select * from '||r.schemaname||'.'||r.relname; 
 loop
  if cn = 1 then 
   select cursor_to_xmlschema(w, true, false, '') into resultxml;
   insert into t_1_xml(out) values(resultxml);
   cn:=0;
  end if;
  select cursor_to_xml(w,1, true, true, '') into resultxml;
  insert into t_1_xml(out) values(resultxml);
  exit when resultxml::text = '';
        end loop;
        close w;

 sql := 'copy( select replace(replace(regexp_replace(out::text, E''[\\n\\r]+'', '' '', ''g'' ),''     '',''''),''   '','''') as out from t_1_xml) to'''|| p_path||'/'||r.relname||'.xml''';
 execute sql;
 truncate t_1_xml;
 raise notice '...Done';
end loop;
return 1;
END
$BODY$
  LANGUAGE plpgsql ;