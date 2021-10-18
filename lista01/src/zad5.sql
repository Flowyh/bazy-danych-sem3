select first_name, last_name
from actor
         join film_actor fa on actor.actor_id = fa.actor_id
         join film f on fa.film_id = f.film_id
where f.special_features like '%Deleted Scenes%'
group by fa.actor_id;