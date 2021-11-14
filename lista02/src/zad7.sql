-- Zad 7.
-- Napisz funkcje która dla podanego ID matrycy, zwraca liczbe modeli aparatów z dana matryca. (2pkt)

create function liczbaModeliMatryca(mat int)
    returns varchar(30) deterministic
    return (select count(*)
            from Aparat a
            where a.matryca = mat
    );

select liczbaModeliMatryca(111);