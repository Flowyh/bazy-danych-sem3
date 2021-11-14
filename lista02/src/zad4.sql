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