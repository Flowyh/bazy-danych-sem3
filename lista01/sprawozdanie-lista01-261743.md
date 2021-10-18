# Sprawozdanie [Lista01](https://cs.pwr.edu.pl/bojko/pdfy/db-lab1.pdf)
## Przedmiot: Bazy danych i systemy informacyjne
## Prowadzący: Mgr. Dominik Bojko
* Autor: Maciej Bazela
* Indeks: 261743
* Grupa: Śr. 7:30-9:00
* Kod grupy: K06-46a

## Rozwiązania zadań:
**Używany dialekt zapytań: MySQL**

**Zad 1.**
* Query:
```sql
select TABLE_NAME
from information_schema.columns
where TABLE_SCHEMA = 'sakila'
group by TABLE_NAME;
```
* Result:

|TABLE_NAME|
|----|
|actor|
|actor_info|
|address|
|category|
|city|
|...|
Total rows: 23

* Komentarz:
  Powyższa kwerenda jest równozaczna wywołaniu: 
  ```sql 
  show tables
  ```
  Wolałem jednak wykorzystać mysql metadata serwerowe zapisane w information_schema (z powodów czysto ćwiczeniowych).

**Zad 2**

* Query:
```sql
select title
from film
where length > 120;
```
* Result:

|title|
|----|
|AFRICAN EGG|
|AGENT TRUMAN|
|ALAMO VIDEOTAPE|
|ALASKA PHANTOM|
|ALI FOREVER|
|...|
Total rows: 457

**Zad 3**

* Query:
```sql
select title, l.name as lang
from film
         join language l on film.language_id = l.language_id
where description like '%Documentary%';
```
* Result:

|title|lang|
|----|----|
|AFFAIR PREJUDICE|English|
|AFRICAN EGG|English|
|ARSENIC INDEPENDENCE|English|
|BALLROOM MOCKINGBIRD|English|
|BEVERLY OUTLAW|English|
|...|...|
Total rows: 101

* Komenatrz:
Niektóre aliasy dodałem, żeby wyniki były po prostu czytelniejsze (tu: as lang).

**Zad 4**

* Query:
```sql
select title
from film
         join film_category c on film.film_id = c.film_id
         join category c2 on c.category_id = c2.category_id
where c2.name = 'Documentary'
  and not (description like '%Documentary%');
```
* Result:

|title|
|----|
|ACADEMY DINOSAUR|
|ADAPTATION HOLES|
|ARMY FLINTSTONES|
|BEACH HEARTBREAKERS|
|BED HIGHBALL|
|...|
Total rows: 63

**Zad 5**

* Query:
```sql
select first_name, last_name
from actor
         join film_actor fa on actor.actor_id = fa.actor_id
         join film f on fa.film_id = f.film_id
where f.special_features like '%Deleted Scenes%'
group by fa.actor_id;
```
* Result:

|first_name|last_name|
|----|----|
|PENELOPE|GUINESS|
|CHRISTIAN|GABLE|
|LUCILLE|TRACY|
|SANDRA|PECK|
|JOHNNY|CAGE|
|...|...|
Total rows: 200

**Zad 6**

* Query:
```sql
select rating, count(film_id) as 'Count'
from film
group by rating;
```
* Result:

|rating|Count|
|----|----|
|PG|194|
|G|178|
|NC-17|210|
|PG-13|223|
|R|195|

Total rows: 5

**Zad 7**

* Query:
```sql
select title
from film
         join inventory i on film.film_id = i.film_id
         join rental r on i.inventory_id = r.inventory_id
where r.rental_date between '2005-05-25 00:00:00' and '2005-05-30 23:59:59'
group by film.film_id, title
order by title;
```
* Result:

|title|
|----|
|ACADEMY DINOSAUR|
|AFFAIR PREJUDICE|
|AFRICAN EGG|
|AGENT TRUMAN|
|AIRPORT POLLOCK|
|...|
Total rows: 624

**Zad 8**

* Query:
```sql
select title
from film
where rating like 'R'
order by length desc
limit 5;
```
* Result:

|title|
|----|
|SWEET BROTHERHOOD|
|SOLDIERS EVOLUTION|
|HOME PITY|
|SMOOCHY CONTROL|
|SATURN NAME|
Total rows: 5

**Zad 9**

* Query:
```sql
select first_name, last_name
from customer c1
         join (select distinct c2.customer_id
               from customer c2
                        join rental r on r.customer_id = c2.customer_id
                        join payment p on c2.customer_id = p.customer_id
               where r.staff_id <> p.staff_id) temp on c1.customer_id = temp.customer_id;
```
* Result:

|first_name|last_name|
|----|----|
|MARY|SMITH|
|PATRICIA|JOHNSON|
|LINDA|WILLIAMS|
|BARBARA|JONES|
|ELIZABETH|BROWN|
|...|...|

Total rows: 599

* Komentarz:
```sql
select distinct c2.customer_id
               from customer c2
                        join rental r on r.customer_id = c2.customer_id
                        join payment p on c2.customer_id = p.customer_id
               where r.staff_id <> p.staff_id
```
W tym podzapytaniu wybieramy id klienta, który został obsłużony przez dwóch różnych pracowników podczas wynajmowania filmu oraz zapłaty za wynajem (założyłem, że chodziło o właśnie o porównywanie tabelek rental i payment; dla 2x rental i 2x payment wyniki są takie same).
```sql
               where r.staff_id <> p.staff_id
```
To wyrażenie oznacza że pierwsze id nie równa się (<> - NOT EQUAL) drugiemu.
Na samym końcu wybieramy po prostu imię i nazwisko klienta, którego id znajduje się w tej naszym podzapytaniu.


**Zad 10**

* Query:
```sql
select first_name, last_name
from customer c
         join rental r on c.customer_id = r.customer_id
group by first_name, last_name
having count(rental_id) >
       (select count(r.rental_id)
        from rental r
                 join customer c on r.customer_id = c.customer_id
        where c.email = 'PETER.MENARD@sakilacustomer.org');
```
* Result:

|first_name|last_name|
|----|----|
|MARY|SMITH|
|PATRICIA|JOHNSON|
|LINDA|WILLIAMS|
|ELIZABETH|BROWN|
|JENNIFER|DAVIS|
|...|...|
Total rows: 435

* Komentarz:
```sql
having count(rental_id) >
       (select count(r.rental_id)
        from rental r
                 join customer c on r.customer_id = c.customer_id
        where c.email = 'PETER.MENARD@sakilacustomer.org');
```
Możemy użyć takiego porównania, ponieważ nasze podzapytanie zwraca tylko 1 wynik, liczbę, która może być traktowana jako coś w rodzaju zmiennej.

**Zad 11**

* Query:
```sql
select f1.actor_id first_actor, f2.actor_id second_actor, count(*) matching_films
from film_actor f1
         join film_actor f2 on f1.actor_id < f2.actor_id and f1.film_id = f2.film_id
group by f1.actor_id, f2.actor_id
having count(*) > 1
order by f1.actor_id, f2.actor_id;
```
* Result:

|first_actor|second_actor|matching_films|
|----|----|----|
|1|4|4|
|1|6|2|
|1|10|2|
|1|20|3|
|1|24|2|
|...|...|...|

Total rows: 3483

* Komentarz:
```sql
select f1.actor_id first_actor, f2.actor_id second_actor, [...]
from film_actor f1
         join film_actor f2 on f1.actor_id < f2.actor_id and f1.film_id = f2.film_id
```
Wybieramy dwa różne wiersze z tabely film_actor, badamy te, których id filmów są takie same i wybieramy pary id aktorów rosnąco (równoznacznie można wybrać je malejąco). Pozwala to nam na wybranie unikalnych par (X, Y), ponieważ wyrzucamy w ten sposób z puli duplikaty typu (Y, X). Gdybyśmy użyli operatora <> otrzymalibyśmy w wyniku zarówno pary (X, Y) jak i (Y, X).

**Zad 12**

* Query:
```sql
select distinct last_name, first_name
from actor a
         join film_actor t on a.actor_id = t.actor_id
where a.actor_id not in
      (select actor_id
       from film_actor fa
                join film f on fa.film_id = f.film_id
       where f.title like 'B%')
order by last_name, first_name;
```
* Result:

|last_name|first_name|
|----|----|
|AKROYD|DEBBIE|
|BACALL|RUSSELL|
|BERGEN|VIVIEN|
|BERGMAN|LIZA|
|BOLGER|VAL|
|...|...|
Total rows: 36

* Komentarz:
```sql
where a.actor_id not in
      (select actor_id
       from film_actor fa
                join film f on fa.film_id = f.film_id
       where f.title like 'B%')
```
Wybieramy takie id aktorów, które nie znajdują się w podzapytaniu, które zwraca wszystkie id aktorów, którzy grali w filmach zaczynających się na B. Równozacznie można by było użyć tutaj left/right join.


**Zad 13**

* Query:
```sql
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
```
* Result:

|last_name|first_name|
|----|----|
|GUINESS|PENELOPE|
|BERRY|KARL|
|BERGEN|VIVIEN|
|VOIGHT|HELEN|
|MCQUEEN|JULIA|
|...|...|
Total rows: 61

* Komentarz:
Tworzymy dwa pod zapytania, w jednym zliczamy w ilu horrorach grał aktor, w drugim w ilu filmach akcji. Tak jak w zadaniu 10 tworzymy dwie zmienne, które możemy ze sobą porównać.

**Zad 14**

* Query:
```sql
select c.last_name, c.first_name
from customer c
         join payment p on c.customer_id = p.customer_id
group by c.customer_id
having avg(p.amount) >
       (select avg(amount)
        from payment
        where payment_date between '2005-07-07 00:00:00' and '2005-07-07 23:59:59')
```
* Result:

|last_name|first_name|
|----|----|
|JOHNSON|PATRICIA|
|WILLIAMS|LINDA|
|MILLER|MARIA|
|ANDERSON|LISA|
|JACKSON|KAREN|
|...|...|
Total rows: 288

**Zad 15**

* Query:
```sql
alter table language
    add films_no int default 0;

update language join (select l.language_id, count(f.film_id) as films_count
                      from language l
                               left join film f on l.language_id = f.language_id
                      group by l.language_id) as lic on language.language_id = lic.language_id
set films_no = lic.films_count
```
* Result:
6 rows affected.

|language_id|name|last_update|films_no|
|:----|:----|:----|:----|
|1|English|2021-10-18 14:58:16|1000|
|2|Italian|2021-10-15 21:03:34|0|
|3|Japanese|2021-10-15 21:03:34|0|
|4|Mandarin|2021-10-15 21:06:24|0|
|5|French|2021-10-15 21:03:34|0|
|6|German|2021-10-18 14:58:16|0|


* Komentarz:
```sql
alter table language
    add films_no int default 0;
```
Dodajemy nową kolumnę, o domyślnej wartości wiersza 0, do tabeli language.

```sql
update language join (select l.language_id, count(f.film_id) as films_count
                      from language l
                               left join film f on l.language_id = f.language_id
                      group by l.language_id) as lic on language.language_id = lic.language_id
set films_no = lic.films_count
```
Nadpisujemy utworzoną kolumnę zliczonymi filmami w danym języku. Ta część będzie wywoływana także w zadaniu 16.

**Zad 16**

* Query:
```sql
update film
set film.language_id = (select language_id from language where name = 'Mandarin')
where film.title = 'WON DARES';

update film f
    join film_actor fa on f.film_id = fa.film_id
    join actor a on fa.actor_id = a.actor_id
SET f.language_id = (SELECT language_id from language where name = 'German')
where first_name = 'NICK'
  and last_name = 'WAHLBERG';
```
* Result:
1 row affected.
25 rows affected.

Po update z zad 15:
|language_id|name|last_update|films_no|
|:----|:----|:----|:----|
|1|English|2021-10-18 14:58:16|974|
|2|Italian|2021-10-15 21:03:34|0|
|3|Japanese|2021-10-15 21:03:34|0|
|4|Mandarin|2021-10-15 21:06:24|1|
|5|French|2021-10-15 21:03:34|0|
|6|German|2021-10-18 14:58:16|25|

**Zad 17**
* Query:
```sql
alter table film
    drop column release_year;
```
* Result:
completed in ... ms