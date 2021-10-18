alter table language
    add films_no int default 0;

update language join (select l.language_id, count(f.film_id) as films_count
                      from language l
                               left join film f on l.language_id = f.language_id
                      group by l.language_id) as lic on language.language_id = lic.language_id
set films_no = lic.films_count

