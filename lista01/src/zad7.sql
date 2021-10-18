select title
from film
         join inventory i on film.film_id = i.film_id
         join rental r on i.inventory_id = r.inventory_id
where r.rental_date between '2005-05-25 00:00:00' and '2005-05-30 23:59:59'
group by film.film_id, title
order by title;