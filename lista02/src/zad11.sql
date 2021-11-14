-- Zad 11.
-- 1) Do tabeli Producent dodaj kolumne liczbaModeli i
-- 2) uzupełnij ja na podstawie danych z tabeli Aparat (zadbaj, aby w kolumnie tej nie było wartosci ´ null).
-- 3) Napisz nowe lub uzupełnij stare triggery,
-- tak by przy kazdej zmianie (dodanie nowego modelu, usuniecie modelu, zmiana producenta)
-- korygowac odpowiednia wartosc w nowej kolumnie.
-- 4) Czy taki trigger moze zostac utworzony przez uzytkownika z zadania 1?
-- 5) Czy bedzie działał podczas operacji na tabelach wykonywanych przez tego uzytkownika,
-- jesli trigger został stworzony przez roota? (2pkt)

alter table Producent
    add liczbaModeli int; -- 1)

update Producent p
set p.liczbaModeli = (select count(*) from Aparat a where a.producent = p.ID); -- 2)

-- 3)
create trigger updateLiczbaModeliDel
    after delete
    on Aparat
    for each row
    update Producent p
    set p.liczbaModeli = p.liczbaModeli - 1
    where p.ID = OLD.producent;

create trigger updateLiczbaModeliIns
    after insert
    on Aparat
    for each row
    update Producent p
    set p.liczbaModeli = p.liczbaModeli + 1
    where p.ID = NEW.producent;

create trigger updateLiczbaModeliUp
    after update
    on Aparat
    for each row
    if NEW.producent <> OLD.producent then
        update Producent p
        set p.liczbaModeli = p.liczbaModeli + 1
        where p.ID = NEW.producent;
        update Producent p
        set p.liczbaModeli = p.liczbaModeli - 1
        where p.ID = OLD.producent;
    end if;

delete
from Aparat
where model = 'Bogata aparatura30';
insert into Aparat(model, producent, matryca, obiektyw, typ) value ('Nowy', 17, 111, 11, 'inny');
update Aparat
set producent = 11
where model = 'Nowy';

insert into Aparat(model, producent, matryca, obiektyw, typ) value ('Nowy 2', 17, 111, 11, 'inny');
update Aparat
set producent = 11
where model = 'Nowy 2';