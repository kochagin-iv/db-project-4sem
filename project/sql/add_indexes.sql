-- Создадим индекс для быстрого поиска игроков и уникальности добавления новых
CREATE UNIQUE INDEX players_full_name_idx
ON player ((player_nm || ' ' || player_snm));

SELECT * FROM player where (player_nm || ' ' || player_snm) = 'Ilya Kochagin';

--Создадим индекс для сортировки игроков по рейтингу
CREATE INDEX players_sort_rating ON players (rating) ASC;

--Создадим индекс для поиска игроков по инвентарю
CREATE UNIQUE INDEX players_equipment
ON player (equipment_id);