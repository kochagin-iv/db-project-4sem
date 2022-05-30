--откат бд player к изначальному значению
DELETE player_history_rating WHERE iter_no > 10;
do $$
DECLARE 
begin
	for pl_id in 1..10 loop
		UPDATE player set rating = get_last_rating_from_history(pl_id, 0) WHERE player_id = pl_id; 
	end loop;
end; $$;
SELECT * from player;
