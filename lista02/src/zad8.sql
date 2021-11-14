-- Zad 8.
-- Napisz trigger usuwajacy z tabeli Matryca matryce, dla której usuniety został ostatni aparat ja wykorzystujacy.

create trigger usunMatrycaAparat
    after delete
    on Aparat
    for each row
    delete
    from Matryca m
    where m.ID = OLD.matryca
      and m.ID not in (select matryca from Aparat group by matryca);
delete
from Aparat
where matryca = 102;
