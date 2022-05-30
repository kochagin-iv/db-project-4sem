do $$
begin
	for pl_id in 1..10 loop
		INSERT INTO player_history_rating (player_id, change_time, new_rating) 
		VALUES (pl_id, current_timestamp, (SELECT rating FROM player WHERE player_id = pl_id));
	end loop;	
end; $$;


SELECT * FROM player_history_rating