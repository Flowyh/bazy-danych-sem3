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