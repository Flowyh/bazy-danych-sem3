#+1) Utwórz nowa baze danych o dowolnej nazwie a w niej tabele:
#+2)• Ludzie (PESEL: char(11), imie: varchar(30), nazwisko: varchar(30), data_urodzenia: date, plec: enum(’K’, ’M’))
#   • Zawody (zawod_id: int, nazwa: varchar(50), pensja_min: float, pensja_ max: float)
#   • Pracownicy (PESEL: char(11), zawod_id: int, pensja: float).
#+3) - Czy dobrym pomysłem jest stosowanie nr PESEL jako klucza? Jezeli uwazasz, ze nie, popraw to.
#+4) Zadbaj o prawidłowy format kolumny PESEL.
#+5) Dopilnuj, by nie mozna było wprowadzic tak ze ujemnych wartosci liczbowych do bazy
#+6) oraz aby pensja_min < pensja_max.
#+7) Do tabeli Ludzie wprowadz informacje na temat 5 osób niepełnoletnich oraz
# 45 osób pełnoletnich, ale majacych zarazem mniej niz 60 lat
# oraz 5 osób w wieku co najmniej 60 lat.
#+8) Tabele zawody uzupełnij zawodami - polityk, nauczyciel, lekarz, informatyk wraz z odpowiednimi widełkami pensji.
#+9) Nastepnie, z wykorzystaniem kursora na tabeli Ludzie, przypisz kazdej pełnoletniej osobie zawód
# (wraz z odpowiednia pensja) i uzupełnij tabele Pracownicy
# (Uwaga: zadbaj o to, aby zaden lekarz płci meskiej nie był starszy niz 65 lat a zaden
# lekarz płci zenskiej nie był starszy niz 60 lat).
# Napisz w sprawozdaniu raport z wykonanych czynnosci. (5pkt)

# create database db_ludzie; # 1

drop table if exists Pracownicy;
drop table if exists Ludzie;
drop table if exists Zawody;
drop table if exists random_men;
drop table if exists random_women;

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

# 7) Do tabeli Ludzie wprowadz informacje na temat 5 osób niepełnoletnich oraz
# 45 osób pełnoletnich, ale majacych zarazem mniej niz 60 lat
# oraz 5 osób w wieku co najmniej 60 lat.

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
            set birth_date = timestampadd(SECOND, floor(rand() * timestampdiff(SECOND, date_start, date_end)),
                                          date_start); # Random date from (date_end, date_start) rtange
            set random_numbers = right(unix_timestamp(), 3); # Random 3 numbers == last 3 timestamp numbers
            set first = (select first_name from random_men order by RAND() limit 1); # Random first name
            set last = (select last_name from random_men order by RAND() limit 1); # Random last name
            if ((it % 2) = 0) then
                set first = (select first_name from random_women order by RAND() limit 1); # Woman
                set last = (select last_name from random_women order by RAND() limit 1); # Woman
            end if;
            if year(birth_date) >= 2000 then # I should check for dates like >2100 etc, but I can't be bothered to do that, so I'm only going to use years from range 1900-2099
                set birth_numbers = concat(date_format(birth_date, '%y'), date_format(birth_date, '%m') + 20,
                                           date_format(birth_date, '%d'));
            else
                set birth_numbers = date_format(birth_date, '%y%m%d');
            end if;
            set pesel = concat(birth_numbers, random_numbers, (((2 * floor(rand() * 5 + 1) - (it % 2)))) % 10); # If woman: random even, if man: random odd.
            set pesel = concat(pesel, pesel_checksum(pesel));
            insert into Ludzie(PESEL, imie, nazwisko, data_urodzenia, plec)
            values (pesel, first, last, birth_date, gender);
            set it = it + 1;
        end while;
end !!

call generateData(1, 18, 5);
call generateData(19, 59, 45);
call generateData(60, 80, 5);

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