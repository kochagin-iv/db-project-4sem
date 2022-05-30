--Создаем триггер на изменение инвентаря для игрока
CREATE OR REPLACE FUNCTION log_last_equipment_changes()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF NEW.equipment_id <> OLD.equipment_id THEN
		 INSERT INTO player_history_equipment(player_id, change_time, new_equipment_id)
		 VALUES(OLD.player_id, now(), OLD.equipment_id);
	END IF;
	RETURN NEW;
END;
$$;
CREATE TRIGGER last_equipment_changes
  BEFORE UPDATE
  ON player
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_equipment_changes();
  
--Создаем триггер на изменение команды для игрока
CREATE OR REPLACE FUNCTION log_last_team_changes()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF NEW.team_id <> OLD.team_id THEN
		 INSERT INTO player_history_team(player_id, change_time, new_team_id)
		 VALUES(OLD.player_id, now(), OLD.team_id);
	END IF;
	RETURN NEW;
END;
$$;
CREATE TRIGGER last_team_changes
  BEFORE UPDATE
  ON player
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_team_changes();
--INSERT INTO player(team_id, equipment_id, player_nm, player_snm, rating) VALUES 
--(1, 1, 'TEST', 'TEST', 300);
--SELECT * FROM player;
--UPDATE player SET equipment_id=3, team_id=3;
--SELECT * FROM player_history_team;
