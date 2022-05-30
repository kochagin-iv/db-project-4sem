--Создаем сводную таблицу со всей информацией про игру
CREATE OR REPLACE VIEW get_all_info_games AS
SELECT game_info.game_id, 
	game_info.tournament_id, 
	game_info.team_guest_id,
	game_info.team_home_id,
	game_home.taken_sets_home,
	game_home.rating_delta as home_dlt,
	game_guest.taken_sets_guest,
	game_guest.rating_delta as guest_dlt
	from game_info 
	inner join game_home on 
	game_info.game_id = game_home.game_id 
	inner join game_guest on game_info.game_id = game_guest.game_id;

-- Создаем таблицу с прошлым и будущим рейтингом, за 1 игру до текущей и после следующей
CREATE OR REPLACE VIEW get_prev_next_rating AS
SELECT player_id, new_rating, LAG(new_rating) OVER(PARTITION BY player_id) as prev_rating,
LEAD(new_rating) OVER(PARTITION BY player_id) as next_rating FROM player_history_rating;

-- Создаем сводную таблицу с суммарным временем в минутах на турнир для каждого игрока
CREATE OR REPLACE VIEW get_info_time_games AS
WITH t AS (SELECT team_guest_id as team_id, SUM(time_min) as sum_minutes FROM game_info group by team_guest_id
UNION
SELECT team_home_id, SUM(time_min) as sum_minutes FROM game_info group by team_home_id)
SELECT team_id, SUM(sum_minutes) as sum_minutes FROM t group by team_id;

--Создаем сводную таблицу с изменением рейтинга каждого игроока за турнир
CREATE OR REPLACE VIEW get_delta_tournament AS
WITH table_info as (
	SELECT player_id, new_rating, LAG(new_rating) OVER(PARTITION BY player_id) as prev_rating,
	LEAD(new_rating) OVER(PARTITION BY player_id) as next_rating FROM player_history_rating
),
table_with_init_last_rating as (
SELECT player_id, FIRST_VALUE(new_rating) OVER(PARTITION BY player_id) as first_rating,
LAST_VALUE(new_rating) OVER(PARTITION BY player_id) as last_rating
from table_info)
SELECT player_id, avg(first_rating) as first_rating,
avg(last_rating) as last_rating,
avg(last_rating) - avg(first_rating) as dlt from table_with_init_last_rating GROUP BY player_id;

--Создаем сводную таблицу с числоом матчей поо счету 3:0, 3:1,...,0:3
CREATE OR REPLACE VIEW get_number_of_matches_per_sets AS
WITH info_table AS (
	SELECT 
	game_home.taken_sets_home,
	game_guest.taken_sets_guest
	from game_info 
	inner join game_home on 
	game_info.game_id = game_home.game_id 
	inner join game_guest on game_info.game_id = game_guest.game_id)
SELECT taken_sets_home, taken_sets_guest, COUNT(*) from info_table GROUP BY (taken_sets_home, taken_sets_guest);