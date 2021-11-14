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