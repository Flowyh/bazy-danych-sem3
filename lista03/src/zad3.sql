# 1) Napisz procedure, która jako parametr wejsciowy przyjmuje nazwe zawodu,
# 2) a nastepnie daje wszystkim wykonujacym ten zawód 5% podwyzki
# 3) przy zachowaniu ograniczen wynikajacych z widełek płacowych w tabeli zawody.
# 4) Operacja powinna wykonac sie transakcyjnie, tzn. albo wszyscy pracownicy danego zawodu dostaja
# podwyzke albo, przy przekroczeniu widełek przez przynajmniej jedna osobe, nikt.


drop procedure if exists raise;

delimiter @@
create procedure raise(in nazwa_zawodu varchar(50))
begin
    start transaction;
    update Pracownicy p
        join Zawody z on p.zawod_id = z.zawod_id
    set pensja = pensja * 1.05
    where z.nazwa = nazwa_zawodu;

    select @max_salary := max(p.pensja)
    from Pracownicy p
             join Zawody z on z.zawod_id = p.zawod_id
    where z.nazwa = nazwa_zawodu;
    select @limit := z.pensja_max
    from Zawody z
    where z.nazwa = nazwa_zawodu;

    if @max_salary > @limit then
        rollback;
    else
        commit;
    end if;
end @@

call raise('informatyk'); # should fail
call raise('lekarz'); # should work
