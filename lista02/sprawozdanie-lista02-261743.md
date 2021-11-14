# Sprawozdanie [Lista02](https://cs.pwr.edu.pl/bojko/pdfy/db-lab2.pdf)
## Przedmiot: Bazy danych i systemy informacyjne
## Prowadzący: Mgr Dominik Bojko
**Autor: Maciej Bazela**
**Indeks: 261743**
**Grupa: Śr. 7:30-9:00**
**Kod grupy: K06-46a**
**Używany dialekt zapytań: MySQL**

[Github Markdown](https://github.com/Flowyh/bazy-danych-sem3/blob/main/lista02/sprawozdanie-lista02-261743.md)

## Rozwiązania zadań:

**Zad 1.**

* Query:
  ```sql
  -- Zad 1. 
  -- 1) Utwórz baze danych db-aparaty. 
  -- 2) Utwórz uzytkownika o nazwie bedacej twoim numerem albumu. 
  -- Ustaw dla niego hasło, bedace konkatenacja twojego imienia i trzech ostatnich cyfr numeru albumu. 
  -- 3) Nadaj utworzonemu uzytkownikowi uprawnienia do selectowania, wstawiania i zmieniania danych w tabelach, jednak nie do
  -- tworzenia usuwania i modyfikowania tabel w bazie. (1pkt)

  -- mysql -u root p
  CREATE DATABASE db_aparaty; -- 1)
  CREATE USER '261743'@'localhost' IDENTIFIED BY 'maciej743'; -- 2)
  SELECT host, user FROM mysql.user; -- Show users
  GRANT SELECT, INSERT, UPDATE on db_aparaty.* TO '261743'@'localhost'; -- 3)
  SHOW GRANTS FOR '261743'@'localhost'; -- Show grants
  ```

**Zad 2**

* Query:
  ```sql
  -- Zad 2.
  -- 1) Utwórz tabele o schematach:
  -- Aparat (*model*: varchar(30), producent: int, matryca: int, obiektyw: int, typ: enum(’kompaktowy’, ’lustrzanka’, ’profesjonalny’, ’inny’))
  -- Matryca (*ID*: int, przekatna: decimal(4,2), rozdzielczosc: decimal(3,1) typ: varchar(10))
  -- Obiektyw (*ID*: int, model: varchar(30), minPrzeslona: float, maxPrzeslona: float)
  -- Producent (*ID*: int, nazwa: varchar(50), kraj: varchar(20))
  -- 2) Zadbaj o to, by podkreslone atrybuty były kluczami glownymi (*attribute*),
  -- 3) tam gdzie to mozliwe zastosuj automatyczna inkrementacje,
  -- 4) w przypadku tabeli Matryca zacznij od ID o wartosci 100.
  -- 5) W tabeli Aparat zadbaj by odpowiednie identyfikatory były kluczami obcymi.
  -- 6) Dodatkowo zadbaj, aby wprowadzane dane liczbowe niemiały wartosci ujemnych
  -- 7) a minPrzeslona < maxPrzeslona
  -- 8) Nazwa oraz kraj z siedziba glowna producenta moga byc puste w przypadku braku danych. (2pkt)

  create table if not exists Matryca -- 1)
  (
      ID            int unsigned  not null auto_increment,            -- 3)
      przekatna     decimal(4, 2) not null check (przekatna > 0),     -- 6)
      rozdzielczosc decimal(3, 1) not null check (rozdzielczosc > 0), -- 6)
      typ           varchar(10)   not null check (typ <> ''),
      primary key (ID)                                                -- 2)
  );

  alter table Matryca
      auto_increment = 100; -- 4)

  create table if not exists Producent -- 1)
  (
      ID    int unsigned not null auto_increment, -- 3)
      nazwa varchar(50),                          -- 8) may be null
      kraj  varchar(20),                          -- 8) may be null
      primary key (ID)                            -- 2)
  );

  create table if not exists Obiektyw -- 1)
  (
      ID           int unsigned not null auto_increment,           -- 3)
      model        varchar(30)  not null check (model <> ''),
      minPrzeslona float        not null check (minPrzeslona > 0), -- 6)
      maxPrzeslona float        not null check (maxPrzeslona > 0), -- 6)
      primary key (ID),                                            -- 2)
      constraint przeslona check (minPrzeslona < maxPrzeslona)     -- 7)
  );

  create table if not exists Aparat -- 1)
  (
      model     varchar(30) check (model <> ''),
      producent int unsigned                                               not null, -- 6)
      matryca   int unsigned                                               not null, -- 6)
      obiektyw  int unsigned                                               not null, -- 6)
      typ       enum ('kompaktowy', 'lustrzanka', 'profesjonalny', 'inny') not null check (typ <> ''),
      primary key (model),                                                           -- 2)
      foreign key (producent) references Producent (ID),                             -- 5)
      foreign key (matryca) references Matryca (ID),                                 -- 5)
      foreign key (obiektyw) references Obiektyw (ID)                                -- 5)
  );
  ```

**Zad 3**

* Query:
  ```sql
  -- Zad 3.
  -- Polacz sie z baza przy pomocy konta uzytkownika utworzonego w zadaniu 1.
  -- 1) Dodaj do kazdej z tabel po 15 rekordów
  -- 1.5) do tabeli Producenci koniecznie dodaj 5 pozycji z producentami, których kraj siedziby to Chiny.
  -- 2) Dodatkowo dla kazdej z tabeli spróbuj wprowadzic rekordy naruszajace ograniczenia z zadania 2. (1pkt)

  insert ignore into Producent(ID, nazwa, kraj) -- 1)
  values (1, 'John Xina Co.', 'Chiny'),                   -- 1.5)
        (2, 'Rock The Wok Johnson Inc.', 'Chiny'),       -- 1.5)
        (3, 'Winnie the Pooh', 'Chiny'),                 -- 1.5)
        (4, 'Tiananmen square''s nothingness', 'Chiny'), -- 1.5)
        (5, 'Egghead&Neckman Coalition', 'Chiny'),       -- 1.5)
        (6, 'Canon Inc.', 'Japonia'),
        (7, 'Casio', 'Japonia'),
        (8, 'Fujifilm Holdings Corporation', 'Japonia'),
        (9, 'Eastman Kodak Company', 'USA'),
        (10, 'Sony Co.', 'Japonia'),
        (11, 'Nikon Co.', 'Japonia'),
        (12, 'Leica Camera AG', 'Niemcy'),
        (13, 'Ricoh Company, Ltd.', 'Japonia'),
        (14, 'Pentax', 'Japonia'),
        (15, 'Samsung Group', 'Japonia'),
        (16, 'empty country', NULL),                     -- 2) should work
        (17, NULL, 'empty name'),                        -- 2) should work
        (18, NULL, NULL)
  -- (NULL, 'empty', 'id') -- 2) reruning this one will spam tuples into the table, so I'm commenting it out
  ;

  insert ignore into Matryca(ID, przekatna, rozdzielczosc, typ) -- 1)
  values (101, 2.54, 30.0, 'CMOS'),
        (102, 1.49, 15.5, 'CCD'),
        (103, 5.61, 12.5, 'CMOS'),
        (104, 6.09, 19.0, 'CCD'),
        (105, 4.21, 25.3, 'CMOS'),
        (106, 5.13, 11.7, 'BSI CMOS'),
        (107, 7.12, 24.6, 'CMOS'),
        (108, 3.38, 10.0, 'BSI CMOS'),
        (109, 2.54, 11.5, 'Foveon'),
        (110, 3.45, 21.7, 'CCD'),
        (111, 6.55, 28.5, 'CCD'),
        (112, 3.21, 16.1, 'CMOS'),
        (113, 3.51, 15.3, 'CCD'),
        (114, 8.11, 14.2, 'CCD'),
        (115, 2.48, 20.0, 'CMOS'),
        (116, NULL, 1.2, 'TEST'), -- 2) shouldn't work
        (117, 4.5, NULL, 'TEST'), -- 2) shouldn't work
        (118, 4.5, 1.2, NULL),    -- 2) shouldn't work
        (1111, -1, 1, 'test'),    -- 2) shouldn't work
        (1111, 1, -10.0, 'test')  -- 2) shouldn't work
  ;

  insert ignore into Obiektyw(id, model, minprzeslona, maxprzeslona) -- 1)
  values (1, 'G', 4.0, 22),
        (2, 'Sigma Art', 2.8, 32),
        (3, 'Sigma Art', 1.8, 22),
        (4, 'Zeiss Batis', 1.8, 18),
        (5, 'Firin', 2.0, 15.5),
        (6, 'Yongnuo YN', 1.4, 32),
        (7, 'Tamron', 3.5, 22),
        (8, 'GM', 2.8, 32),
        (9, 'FE', 2.0, 22),
        (10, 'ZA', 1.8, 32),
        (11, 'Viltrox', 4.0, 18),
        (12, 'Sony FE', 5.6, 22),
        (13, 'Samyang AF', 6.0, 32),
        (14, 'Samyang FE', 4.5, 16),
        (15, 'Sony GM', 1.4, 22),
        (16, 'TEST', 1.2, NULL),  -- 2) shouldn't work
        (17, 'TEST', NULL, 4.33), -- 2) shouldn't work
        (18, NULL, 1.2, 4.33),    -- 2) shouldn't work
        (19, 'TEST', 4.3, 1.2)    -- 2) shouldn't work
  ;

  insert ignore into Aparat(model, producent, matryca, obiektyw, typ) -- 1)
  values ('Wihajstser MK1', 2, 104, 5, 'kompaktowy'),
        ('Wihajstser MK2', 1, 103, 7, 'kompaktowy'),
        ('Wihajstser MK3', 6, 103, 2, 'lustrzanka'),
        ('Wihajstser MK4', 4, 106, 1, 'profesjonalny'),
        ('Wihajstser MK5', 7, 102, 2, 'kompaktowy'),
        ('Wihajstser MK6', 8, 101, 3, 'profesjonalny'),
        ('Wihajstser MK7', 9, 111, 15, 'lustrzanka'),
        ('Wihajstser MK8', 14, 112, 13, 'kompaktowy'),
        ('Wihajstser MK9', 4, 110, 9, 'inny'),
        ('Wihajstser MK10', 6, 107, 11, 'lustrzanka'),
        ('Wihajstser MK20', 2, 103, 8, 'inny'),
        ('Wihajstser MK30', 4, 108, 10, 'kompaktowy'),
        ('Wihajstser MK40', 11, 114, 12, 'lustrzanka'),
        ('Wihajstser MK50', 15, 115, 15, 'inny'),
        ('Wihajstser MK100', 11, 111, 11, 'profesjonalny'),
        (NULL, 1, 111, 1, 'kompaktowy'),      -- 2) shouldn't work
        ('TEST', NULL, 101, 1, 'kompaktowy'), -- 2) shouldn't work
        ('TEST', 1, NULL, 1, 'kompaktowy'),   -- 2) shouldn't work
        ('TEST', 1, 101, NULL, 'kompaktowy'), -- 2) shouldn't work
        ('TEST', 1, 101, 1, NULL),            -- 2) shouldn't work
        ('TEST', -1, 101, 1, 'kompaktowy'),   -- 2) shouldn't work
        ('TEST', 1, -110, 1, 'kompaktowy'),   -- 2) shouldn't work
        ('TEST', 1, 110, -1, 'kompaktowy')    -- 2) shouldn't work
  ;
  ```

**Zad 4**

* Query:
  ```sql
  -- Zad 4.
  -- 1) Napisz procedure, która na podstawie danych z tabel Matryca, Obiektyw oraz Producent wygeneruje 100 nowych modeli aparatów
  -- 2) (o losowych lub sekwencyjnych nazwach)
  -- 3) i uzupełni nimi tabele Aparat.
  -- 4) Czy zaden z modeli sie nie powtarza?
  -- 5) Czy procedura moze byc utworzona i wykonana przez uzytkownika z zadania 1? (2pkt)

  create table if not exists Adjectives -- 2)
  (
      id        int unsigned auto_increment,
      adjective varchar(15),
      primary key (id)
  );

  insert ignore into Adjectives(id, adjective) -- 2)
  values (1, 'Super '),
        (2, 'Giga '),
        (3, 'Swietna '),
        (4, 'Droga '),
        (5, 'Nowa '),
        (6, 'Elegancka '),
        (7, 'Finezyjna '),
        (8, 'Niezwykla '),
        (9, 'Magiczna '),
        (10, 'Piekna '),
        (11, 'Szybka '),
        (12, 'Przepiekna '),
        (13, 'Bogata '),
        (14, 'Turbo '),
        (15, 'Extra '),
        (16, 'Retro ')
  ;

  create table if not exists Nouns -- 2)
  (
      id   int unsigned auto_increment,
      noun varchar(15),
      primary key (id)
  );

  insert ignore into Nouns(id, noun) -- 2)
  values (1, 'machina'),
        (2, 'aparatura'),
        (3, 'ramka'),
        (4, 'maszyneria'),
        (5, 'maszynka'),
        (6, 'architektura'),
        (7, 'sztuka'),
        (8, 'pozycja'),
        (9, 'kompozycja'),
        (10, 'instalacja'),
        (11, 'formacja'),
        (12, 'forma'),
        (13, 'maszyna')
  ;

  create view Wszystkie_nazwy_modeli_aparatu as
  select a.adjective, n.noun
  from Adjectives a,
      Nouns n;

  create function random_model_name()
      returns varchar(30) deterministic
      return concat((select adjective
                    from Adjectives
                    order by rand()
                    limit 1), (select noun
                                from Nouns
                                order by rand()
                                limit 1));

  DELIMITER $$
  create procedure generateRandom100() -- 1)
  begin
      declare i int default 100;
      while i > 0
          do
              insert into Aparat(model, producent, matryca, obiektyw, typ) -- 3)
              values (concat(random_model_name(), i),
                      (select id from Producent order by RAND() limit 1),
                      (select id from Matryca order by RAND() limit 1),
                      (select id from Obiektyw order by RAND() limit 1),
                      (select elt(floor(rand() * 4) + 1, 'kompaktowy', 'lustrzanka', 'profesjonalny', 'inny')));
              set i = i - 1;
          end while;
  end $$

  call generateRandom100();

  -- 4) Powtarzaja sie w sensie matryce i obiektywy?
  select a1.Model, a2.Model
  from Aparat a1 -- 4)
          join Aparat a2
                on a1.matryca = a2.matryca and a1.obiektyw = a2.obiektyw and a1.typ = a2.typ and a1.Model < a2.Model;

  -- 5) Nie moze bo nie ma uprawnien!
  -- [2021-11-12 22:14:28] [42000][1044] Access denied for user '261743'@'%' to database 'db_aparaty'
  ```
* Komentarz:
  * (5) Procedura z tego zadania nie może być stworzona ani wywołana przez użytkownika z Zad. 1, ponieważ nie ma on uprawnień: ``` CREATE ROUTINE, EXECUTE```.
  * (4) Nazwy modeli się nie powtarzają, ponieważ każdy oznaczyłem na końcu iteratorem zmienianym podczas generacji.
  Jeśli chodzi o powtórzenia w sensie parametrów aparatu, wyżej podałem selecta, który podaje pary aparatów o takich samych typach, matrycach i obiektywach.
  
**Zad 5**

* Query:
  ```sql
  -- Zad 5.
  -- Napisz funkcje lub procedure, która dla podanego ID producenta, zwraca wyprodukowany przez niego model aparatu z najwieksza przekatna matrycy. (2pkt)

  create function modelNajwiekszaMatrycaProducenta(prod int)
      returns varchar(30) deterministic
      return (select a.Model
              from Aparat a
                      join Producent p on a.producent = p.ID
                      join Matryca m on a.matryca = m.ID
              where p.ID = prod
              order by m.przekatna desc
              limit 1
      );

  select modelNajwiekszaMatrycaProducenta(3);
  ```
* Result:
  |'modelNajwiekszaMatrycaProducenta(3)'|
  |---|
  |Bogata aparatura94|

**Zad 6**

* Query:
  ```sql
  -- Zad 6.
  -- 1) Napisz trigger, który pozwoli wstawic do tabeli Aparat model wyprodukowany przez dowolnego producenta,
  -- 2) a jesli takiego nie ma jeszcze w bazie danych, dodaje go do odpowiedniej tabeli. (2pkt)

  DELIMITER $$
  create trigger wstawNullProducenta -- 1)
      before insert
      on Aparat
      for each row
  begin
      if NEW.producent not in (select ID from Producent) then
          insert ignore into Producent(id, nazwa, kraj) values (NEW.producent, NULL, NULL); -- 2)
      end if;
  end $$

  insert into Aparat(model, producent, matryca, obiektyw, typ)
  values ('Nieznana aparatura', 420, 107, 4, 'inny');
  ```
* Komentarz:
  Teraz możemy wstawiać Aparaty o nieznanym wcześniej ID producenta.

**Zad 7**

* Query:
  ```sql
  -- Zad 7.
  -- Napisz funkcje która dla podanego ID matrycy, zwraca liczbe modeli aparatów z dana matryca. (2pkt)

  create function liczbaModeliMatryca(mat int)
      returns varchar(30) deterministic
      return (select count(*)
              from Aparat a
              where a.matryca = mat
      );

  select liczbaModeliMatryca(111);
  ```
* Result:
  |'liczbaModeliMatryca(111)'|
  |---|
  |8|


**Zad 8**

* Query:
  ```sql
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
  ```

**Zad 9**

* Query:
  ```sql
  -- Zad 9.
  -- 1) Stwórz widok zawierajacy
  -- model aparatu, nazwe producenta, przekatna i rozdzielczosc jego matrycy, minimalna oraz maksymymalna wartosc przesłony
  -- dla wszystkich aparatów typu lustrzanka
  -- wyprodukowanych przez producentów majacych siedzibe poza Chinami.
  -- 2) Czy zadanie moze wykonac uzytkownik z zadania 1? (2pkt)

  create view zad9 as -- 1)
  select a.model, p.nazwa, m.przekatna, m.rozdzielczosc, o.minPrzeslona, o.maxPrzeslona
  from Aparat a
          join Producent p on a.producent = p.ID
          join Matryca m on a.matryca = m.ID
          join Obiektyw o on a.obiektyw = o.ID
  where a.typ = 'lustrzanka'
    and p.kraj <> 'Chiny';
  ```
* Komentarz:
  * (2) Użytkownik z zad 1 nie może wykonać tego zapytania, ponieważ nie ma ```CREATE VIEW``` grant.

**Zad 10**

* Query:
  ```sql
  -- Zad 10. 
  -- 1) Stwórz widok zawierajacy nazwe i kraj producenta oraz model, dla wszystkich aparatów.
  -- Nastepnie usun z tabeli Aparat wszystkie modele producentów z Chin.
  -- 2) Czy cos zmieniło sie w widoku? (2pkt)

  create view zad10 as -- 1)
  select a.model, p.nazwa, p.kraj
  from Aparat a
          join Producent p on p.ID = a.producent;

  delete a
  from Aparat a
          inner join Producent p on p.ID = a.producent
  where p.kraj = 'Chiny';
  ```
* Komentarz:
  * (2) Widok zmieni się, ponieważ widoki nie są cachowane. Za każdym razem jak używamy zapytania SELECT na widoku będzie także wykonane zapytanie zapisane w widoku, więc po zmianie danych w tabeli widok także się zmieni.
  
**Zad 11**

* Query:
  ```sql
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
  ```
* Komentarz:
  * (4) Takie triggery nie mogą być utworzone przez użytkownika z Zad 1. ponieważ nie posiada odpowiednich uprawnień (```TRIGGER``` i możliwe, że też ```SUPER``` - nie jestem pewien).
  * (5) Triggery będą działać nawet podczas operacji wykonywanych przez użytkownika z Zad 1.