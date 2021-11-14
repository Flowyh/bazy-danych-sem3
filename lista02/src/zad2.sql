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