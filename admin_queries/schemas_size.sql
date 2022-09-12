---schemas size

select n.nspname,sum(c.relpages::int8*8192),pg_size_pretty(sum(c.relpages::int8*8192))
from pg_class c
inner join pg_namespace n on c.relnamespace = n.oid
group by n.nspname
order by 2 desc;
