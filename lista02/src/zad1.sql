-- Zad 1. 
-- 1) Utwórz baze danych db-aparaty. 
-- 2) Utwórz uzytkownika o nazwie bedacej twoim numerem albumu. 
-- Ustaw dla niego hasło, bedace konkatenacja twojego imienia i trzech ostatnich cyfr numeru albumu. 
-- 3) Nadaj utworzonemu uzytkownikowi uprawnienia do selectowania, wstawiania i zmieniania danych w tabelach, jednak nie do
-- tworzenia usuwania i modyfikowania tabel w bazie. (1pkt)

-- mysql -u root p
CREATE DATABASE db_aparaty; -- 1)
CREATE USER '261743'@'localhost' IDENTIFIED BY 'maciej743'; -- 2)
SELECT host, user FROM mysql.user; -- Show users
GRANT SELECT, INSERT, UPDATE on db_aparaty.* TO '261743'@'localhost'; -- 3)
SHOW GRANTS FOR '261743'@'localhost'; -- Show grants