create view temp_11 as
select f1.actor_id first_actor, f2.actor_id second_actor, count(*) matching_films
from film_actor f1
         join film_actor f2 on f1.actor_id < f2.actor_id and f1.film_id = f2.film_id
group by f1.actor_id, f2.actor_id
having count(*) > 1
order by first_actor, second_actor;

select concat(a1.first_name, ' ', a1.last_name) as Actor1, concat(a2.first_name, ' ', a2.last_name) as Actor2
from actor a1
         join temp_11 t on a1.actor_id = t.first_actor
         join actor a2 on t.second_actor = a2.actor_id;

select f1.actor_id first_actor, f2.actor_id second_actor, count(*) matching_films
from film_actor f1
         join film_actor f2 on f1.actor_id < f2.actor_id and f1.film_id = f2.film_id
group by f1.actor_id, f2.actor_id
having count(*) > 1
order by f1.actor_id, f2.actor_id;

