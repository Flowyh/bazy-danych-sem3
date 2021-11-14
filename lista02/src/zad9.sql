-- Zad 9.
-- 1) Stwórz widok zawierajacy
-- model aparatu, nazwe producenta, przekatna i rozdzielczosc jego matrycy, minimalna oraz maksymymalna wartosc przesłony
-- dla wszystkich aparatów typu lustrzanka
-- wyprodukowanych przez producentów majacych siedzibe poza Chinami.
-- 2) Czy zadanie moze wykonac uzytkownik z zadania 1? (2pkt)
-- Nie
-- [2021-11-12 22:49:13] [42000][1142] CREATE VIEW command denied to user '261743'@'172.17.0.1' for table 'zad9'

create view zad9 as -- 1)
select a.model, p.nazwa, m.przekatna, m.rozdzielczosc, o.minPrzeslona, o.maxPrzeslona
from Aparat a
         join Producent p on a.producent = p.ID
         join Matryca m on a.matryca = m.ID
         join Obiektyw o on a.obiektyw = o.ID
where a.typ = 'lustrzanka'
  and p.kraj <> 'Chiny';