select last_name, first_name
from actor a
where (select count(*)
       from film_actor fa
                join film f on fa.film_id = f.film_id
                join film_category fc on f.film_id = fc.film_id
                join category c on fc.category_id = c.category_id
       where c.name = 'Horror'
         and fa.actor_id = a.actor_id)
          >
      (select count(*)
       from film_actor fa
                join film f on fa.film_id = f.film_id
                join film_category fc on f.film_id = fc.film_id
                join category c on fc.category_id = c.category_id
       where c.name = 'Action'
         and fa.actor_id = a.actor_id)