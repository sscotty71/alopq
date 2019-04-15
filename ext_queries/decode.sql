--- decode.sql
CREATE OR REPLACE FUNCTION public.decode(anyelement, VARIADIC anyarray)
 RETURNS anyelement
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
 N_PARAMS int;
BEGIN
    N_PARAMS := array_length($2,1);
    FOR i IN 1..(N_PARAMS/2) LOOP
        CASE
            WHEN $1=$2[(i*2)-1] THEN
                RETURN $2[i*2];
            ELSE
                NULL;
        END CASE;
    END LOOP;
    IF MOD(N_PARAMS,2)=1 THEN
        RETURN $2[N_PARAMS];
    ELSE
        RETURN NULL;
    END IF;
END;
$function$