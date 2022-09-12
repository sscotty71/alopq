---- list toast tables 
SELECT oid::regclass,
       reltoastrelid::regclass,
       pg_relation_size(reltoastrelid) AS toast_size
FROM pg_class
WHERE relkind = 'r'
  AND reltoastrelid <> 0
ORDER BY 3 DESC;
