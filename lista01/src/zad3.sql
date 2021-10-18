select title, l.name
from film
         join language l on film.language_id = l.language_id
where description like '%Documentary%';