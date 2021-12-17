# 1) W tabeli Ludzie utwórz indeks złozony na kolumnach plec oraz imie, natomiast
# 2) w Pracownicy utwórz index na kolumnie pensja.
# 2.5) Przyjrzyj sie poleceniom SHOW INDEX oraz EXPLAIN SELECT
# 3) Za pomoca odpowiednich kwerend
# SQL wyciagnij z bazy dane dotyczace:
# 3.1) • wszystkich kobiet, których imie zaczyna sie na ’A’
# 3.2) • wszystkich kobiet,
# 3.3) • wszystkich osób, których imie zaczyna sie na ’K’,
# 3.4) • wszystkich osób zarabiajacych ponizej 2000,
# 3.5) • wszystkich informatyków płci meskiej, zarabiajacych powyzej 10000.
# 4) Nastepnie odpowiedz na pytania:
# 4.1) • Jakie mamy obecnie in deksy załozone dla obu tabel?
# 4.2) • W przypadku których zapytan optymalizator uzyje indeksu/indeksów?

# drop index nameGenderIx on Ludzie;
create index nameGenderIx using btree on Ludzie (imie, plec);
# 1
# drop index salaryIx on Pracownicy;
create index salaryIx using btree on Pracownicy (pensja); # 2

# 3.1
explain select *
from Ludzie
where plec = 'K'
  and imie like 'A%';

# 3.2
explain select *
from Ludzie
where plec = 'K';

# 3.3
explain select *
from Ludzie
where imie like 'K%';

# 3.4
explain select *
from Ludzie l
         join Pracownicy p on l.ID = p.ID
where p.pensja < 2000;

# 3.5
explain select *
from Ludzie l
         join Pracownicy p on l.ID = p.ID
         join Zawody z on p.zawod_id = z.zawod_id
where z.nazwa = 'informatyk'
  and l.plec = 'M'
  and p.pensja > 10000;

# 4.1
show index from Ludzie; # 2.5
# 4.2
show index from Pracownicy; # 2.5