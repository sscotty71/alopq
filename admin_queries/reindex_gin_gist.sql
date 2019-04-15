-- No Blocking reindex for gin/gist index type 
-- Function that returns the list of sql commands to make a no blocking reindex for GIN/GIST index type

CREATE OR REPLACE FUNCTION public.rebuild_gin_gist()
  RETURNS SETOF text AS
$BODY$
DECLARE
r record;
sql text;
fields text;
fields_list text;
BEGIN
for r in SELECT
      U.usename                AS user_name,
      ns.nspname               AS schema_name,
      idx.indrelid :: REGCLASS AS table_name,
      i.relname                AS index_name,
      idx.indisunique          AS is_unique,
      idx.indisprimary         AS is_primary,
      am.amname                AS index_type,
      idx.indkey,
           ARRAY(
           SELECT pg_get_indexdef(idx.indexrelid, k + 1, TRUE)
           FROM
             generate_subscripts(idx.indkey, 1) AS k
           ORDER BY k
           ) AS index_keys,
      (idx.indexprs IS NOT NULL) OR (idx.indkey::int[] @> array[0]) AS is_functional,
      idx.indpred IS NOT NULL AS is_partial
    FROM pg_index AS idx
      JOIN pg_class AS i
        ON i.oid = idx.indexrelid
      JOIN pg_am AS am
        ON i.relam = am.oid
      JOIN pg_namespace AS NS ON i.relnamespace = NS.OID
      JOIN pg_user AS U ON i.relowner = U.usesysid
    WHERE NOT nspname LIKE 'pg%'
    and  am.amname in ('gin','gist')
    loop 
       fields := '';
       fields_list := '';
       for i in array_lower(r.index_keys, 1)..array_upper(r.index_keys, 1) loop
        if i < array_upper(r.index_keys, 1) then
             fields:=fields||r.index_keys[i]||',';
             fields_list:=fields_list||r.index_keys[i]||'_';
        else
             fields_list:=fields_list||r.index_keys[i];
             fields:=fields||r.index_keys[i];
        end if;
       end loop;
        sql:='create index concurrently '||left(fields_list||md5(now()::text),31)||' ';
        sql:=sql||'on '||r.table_name||' USING '||r.index_type || '('||fields;
        if r.index_type = 'gin' then
           sql:=sql||' gin_trgm_ops);';
        end if;
        if r.index_type = 'gist' then
            sql:=sql||' gist_trgm_ops);';
        end if;     
        return next sql;   
        sql:='drop index '||r.schema_name||'.'||r.index_name||';';
        return next sql;
    end loop;
return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;