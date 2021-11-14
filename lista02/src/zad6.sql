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