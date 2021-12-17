# 1) Za pomoca konstrukcji PREPARE statement przygotuj zapytanie zwracajace liczbe
# kobiet, pracujacych w zawodzie o podanej przy EXECUTE nazwie.
set @zawod = 'informatyk';

prepare countWomen from
    'select count(plec) from Ludzie l
        join Pracownicy p on l.ID = p.ID
        join Zawody z on p.zawod_id = z.zawod_id
    where plec = \'K\' and z.nazwa = ?';

# Example
execute countWomen using @zawod;

deallocate prepare countWomen;