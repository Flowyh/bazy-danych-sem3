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