select distinct last_name, first_name
from actor a
         join film_actor t on a.actor_id = t.actor_id
where a.actor_id not in
      (select actor_id
       from film_actor fa
                join film f on fa.film_id = f.film_id
       where f.title like 'B%')
order by last_name, first_name;