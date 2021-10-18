select first_name, last_name
from customer c1
         join (select distinct c2.customer_id
               from customer c2
                        join rental r on r.customer_id = c2.customer_id
                        join payment p on c2.customer_id = p.customer_id
               where r.staff_id <> p.staff_id) temp on c1.customer_id = temp.customer_id;

select distinct first_name, last_name
from customer c
         join rental r1 on r1.customer_id = c.customer_id
         join rental r2 on r2.customer_id = c.customer_id
where r1.staff_id <> r2.staff_id;

select distinct first_name, last_name
from customer c
         join payment p1 on p1.customer_id = c.customer_id
         join payment p2 on p2.customer_id = c.customer_id
where p1.staff_id <> p2.staff_id;
