UPDATE player set player_nm='Ilya' where player_id = 1;
UPDATE player set player_nm='Alex' where player_id = 8;
UPDATE player set player_nm='Alena' where player_id = 9;
UPDATE player set player_nm='Artur' where player_id = 2;
--Создаем представление с игроками, у которых оставлена только 1 буква имени
DROP VIEW IF EXISTS get_info_low_skill_players;
CREATE OR REPLACE VIEW get_info_low_skill_players AS
SELECT * from player WHERE rating < 500;

UPDATE get_info_low_skill_players set player_nm = substring(player_nm from 0 for 2) || '.';
SELECT * from get_info_low_skill_players;

DELETE from player where player_id = 1;
DELETE from player where player_id = 8;
DELETE from player where player_id = 9;
DELETE from player where player_id = 2;