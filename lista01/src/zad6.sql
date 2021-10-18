select rating, count(film_id) as 'Count'
from film
group by rating;