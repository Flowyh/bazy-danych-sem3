select TABLE_NAME
from information_schema.columns
where TABLE_SCHEMA = 'sakila'
group by TABLE_NAME;