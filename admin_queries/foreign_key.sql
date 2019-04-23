-- Lists all foreign keys of all tables

SELECT n.nspname,r.conrelid::regclass as tablename,conname as foreign_key,pg_catalog.pg_get_constraintdef(r.oid, true) as condef
FROM pg_catalog.pg_constraint r
inner join pg_class c on r.conrelid=c.oid
left join pg_namespace n ON n.oid = c.relnamespace 
WHERE r.contype = 'f' 
ORDER BY 1,2,3

-- Lists all foreign keys of a sigle table
SELECT n.nspname,r.conrelid::regclass as tablename,conname as foreign_key,pg_catalog.pg_get_constraintdef(r.oid, true) as condef
FROM pg_catalog.pg_constraint r
inner join pg_class c on r.conrelid=c.oid
left join pg_namespace n ON n.oid = c.relnamespace 
WHERE r.contype = 'f' 
AND r.conrelid = 'tablename'::regclass  -- put here the table name
ORDER BY 1,2,3