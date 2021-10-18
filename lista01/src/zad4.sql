select title
from film
         join film_category c on film.film_id = c.film_id
         join category c2 on c.category_id = c2.category_id
where c2.name = 'Documentary'
  and not (description like '%Documentary%');