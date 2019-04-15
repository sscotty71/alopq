--- Function row estimator link from https://www.cybertec-postgresql.com/en/count-made-fast/
---

CREATE FUNCTION row_estimator(query text) RETURNS bigint
   LANGUAGE plpgsql AS
$$DECLARE
   plan jsonb;
BEGIN
   EXECUTE 'EXPLAIN (FORMAT JSON) ' || query INTO plan;
 
   RETURN (plan->0->'Plan'->>'Plan Rows')::bigint;
END;$$;
