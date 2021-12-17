# 1) Zrób backup bazy danych tej listy. Usun baze danych, a nastepnie ja przywróc z backupu.
# 2) Do sprawozdania wrzuc krótki raport z wykonanych czynnosci.
# 3) Jaka jest róznica miedzy backupem pełnym a róznicowym? (4pkt)

# Tworzenie backupu:
# Uruchamiamy z poziomu docker CLI (bo mam mysql na dockerze):
# mysqldump -u root --password=... db_ludzie -R > db_ludzie_dump.sql
# lub print do konsoli:
# mysqldump -u root --password=... db_ludzie -R | cat

# Przywracanie backupu:
# cat db_ludzie_dump.sql | mysql -u root --password=... db_ludzie
# mysql -u root --password=... < db_ludzie_dump.sql