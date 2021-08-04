-- Identify invalid indexes that were created during index rebuild
SELECT
    c.relname as index_name,
    pg_size_pretty(pg_relation_size(c.oid))
FROM
    pg_index i
    JOIN pg_class c ON i.indexrelid = c.oid
WHERE
    -- New index built using REINDEX CONCURRENTLY
    c.relname LIKE  '%_ccnew'
    -- In INVALID state
    AND NOT indisvalid
