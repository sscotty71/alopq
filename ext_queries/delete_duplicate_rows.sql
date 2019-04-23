-- Delete duplicate rows 
DELETE FROM tablename WHERE ctid NOT IN
(SELECT max(ctid) FROM tablename GROUP BY tablename.*) ;