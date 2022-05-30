-- узначем последнее значение рейтинга из таблицы изменений рейтинга и прибавляем к нему изменение, 
-- полученное запоследний матч
CREATE OR REPLACE FUNCTION get_last_rating_from_history(player_idd integer, delta real) RETURNS real as $$
		WITH last_ AS(
			SELECT * FROM player_history_rating WHERE player_id = player_idd
			ORDER BY iter_no
			LIMIT 1
		)
		SELECT (SELECT new_rating FROM last_) + delta;
$$ LANGUAGE SQL;

-- считаем как изменится рейтинг в зависимости от рейтингов игроков и набранных сетов
CREATE OR REPLACE FUNCTION calculate_delta(player_win_id integer, 
								player_lose_id integer, 
								win_sets integer,
							    lose_sets integer) RETURNS real LANGUAGE plpgsql as $$
	DECLARE 
		D real;
	BEGIN
	IF (SELECT rating from PLAYER WHERE player_id = player_win_id)
					  -
		(SELECT rating from PLAYER WHERE player_id = player_lose_id) > 100 THEN
		RETURN 0;
	END IF;
	D := 0.8;
	IF win_sets - lose_sets = 2 THEN
    	D := 1;
	END IF;
	IF win_sets - lose_sets = 3 THEN
    	D := 1.2;
	END IF;
	RETURN (((100.0 - ((SELECT rating from PLAYER WHERE player_id = player_win_id)
					  -
					 (SELECT rating from PLAYER WHERE player_id = player_lose_id))) / 10.0)  * 0.3 * D);
	END $$;

do $$
DECLARE 
	home_sets integer;
	guest_sets integer;
	time_min integer;
	flag_home integer;
	home_id integer;
	guest_id integer;
	delta real;
begin
	for pl_id_win in 1..10 loop
		for pl_id_lose in 1..10 loop
			CONTINUE WHEN pl_id_win = pl_id_lose;
			home_sets := 3;
			guest_sets :=  floor(random()*(2-0+1))+0; -- from 0 to 2 sets
			time_min :=  floor(random()*(40-10+1))+10; -- from 10 to 40 minutes
			flag_home :=  floor(random()*(1-0+1))+0; -- from 0 to 1 flag
			home_id := pl_id_win;
			guest_id := pl_id_lose;
			if flag_home = 0 THEN
				home_id := pl_id_lose;
				guest_id := pl_id_win;
				home_sets := guest_sets;
				guest_sets := 3;
			END IF;
			INSERT INTO game_info (tournament_id, stage_id, team_home_id, team_guest_id, time_min) 
			VALUES (2, 1, home_id, guest_id, time_min);
			if flag_home = 1 THEN
				delta := calculate_delta(home_id, guest_id, home_sets, guest_sets);
				INSERT INTO game_home (game_id, team_home_id, taken_sets_home, rating_delta)
				VALUES ((SELECT max(game_id) from game_info), home_id, home_sets, delta);
				INSERT INTO player_history_rating (player_id, change_time, new_rating)
				VALUES (home_id, current_timestamp, get_last_rating_from_history(home_id, delta));
				UPDATE player SET 
					rating = get_last_rating_from_history(home_id, 0.0) 
					WHERE player_id = home_id;
				--
				delta := -delta;
				INSERT INTO game_guest (game_id, team_guest_id, taken_sets_guest, rating_delta)
				VALUES ((select max(game_id) from game_info), guest_id, guest_sets, delta);
				INSERT INTO player_history_rating (player_id, change_time, new_rating)
				VALUES (guest_id, current_timestamp, get_last_rating_from_history(guest_id, delta));
				UPDATE player SET 
					rating = get_last_rating_from_history(guest_id, 0.0) 
					WHERE player_id = guest_id;
			ELSE
				delta := calculate_delta(guest_id, home_id, guest_sets, home_sets);
				delta := -delta;
				INSERT INTO game_home (game_id, team_home_id, taken_sets_home, rating_delta)
				VALUES ((select max(game_id) from game_info), home_id, home_sets, delta);
				INSERT INTO player_history_rating (player_id, change_time, new_rating)
				VALUES (home_id, current_timestamp, get_last_rating_from_history(home_id, delta));
				UPDATE player SET 
					rating = get_last_rating_from_history(home_id, 0.0) 
					WHERE player_id = home_id;
				--
				delta := -delta;
				INSERT INTO game_guest (game_id, team_guest_id, taken_sets_guest, rating_delta)
				VALUES ((select max(game_id) from game_info), guest_id, guest_sets, delta);
				INSERT INTO player_history_rating (player_id, change_time, new_rating)
				VALUES (guest_id, current_timestamp, get_last_rating_from_history(guest_id, delta));
				UPDATE player SET 
					rating = get_last_rating_from_history(guest_id, 0.0) 
					WHERE player_id = guest_id;
			END IF;
		end loop;
	end loop;	
end; $$;

SELECT * from player_history_rating;
