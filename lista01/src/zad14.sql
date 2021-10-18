select c.last_name, c.first_name
from customer c
         join payment p on c.customer_id = p.customer_id
group by c.customer_id
having avg(p.amount) >
       (select avg(amount)
        from payment
        where payment_date between '2005-07-07 00:00:00' and '2005-07-07 23:59:59')