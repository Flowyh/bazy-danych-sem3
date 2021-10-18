update film
set film.language_id = (select language_id from language where name = 'Mandarin')
where film.title = 'WON DARES';

update film f
    join film_actor fa on f.film_id = fa.film_id
    join actor a on fa.actor_id = a.actor_id
SET f.language_id = (SELECT language_id from language where name = 'German')
where first_name = 'NICK'
  and last_name = 'WAHLBERG';

update language join (select l.language_id, count(f.film_id) as films_count
                      from language l
                               left join film f on l.language_id = f.language_id
                      group by l.language_id) as lic on language.language_id = lic.language_id
set films_no = lic.films_count