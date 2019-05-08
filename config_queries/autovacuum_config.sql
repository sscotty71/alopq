-- Change autovacuum_vacuum_scale_factor / autovacuum_vacuum_threshold on a specific table
-- change tablename with the table name 
-- example: set autovacuum every 5000 dead rows

ALTER TABLE tablename SET (autovacuum_vacuum_scale_factor= 0.0); 
ALTER TABLE tablename SET (autovacuum_vacuum_threshold = 5000);  