select first_name, last_name
from customer c
         join rental r on c.customer_id = r.customer_id
group by first_name, last_name
having count(rental_id) >
       (select count(r.rental_id)
        from rental r
                 join customer c on r.customer_id = c.customer_id
        where c.email = 'PETER.MENARD@sakilacustomer.org');