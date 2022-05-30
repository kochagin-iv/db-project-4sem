--Посмотрим сколько суммарно минут кто из игроков играл на турнире 2
WITH t AS (SELECT team_guest_id as team_id, SUM(time_min) as sum_minutes FROM game_info group by team_guest_id
UNION
SELECT team_home_id, SUM(time_min) as sum_minutes FROM game_info group by team_home_id)
SELECT team_id, SUM(sum_minutes) as sum_minutes FROM t group by team_id;
--Добавим к этому сводную таблицу с ФИО игрока и его рейтингом
WITH info_table AS (
	WITH t AS (SELECT team_guest_id as team_id, SUM(time_min) as sum_minutes FROM game_info group by team_guest_id
		UNION
		SELECT team_home_id, SUM(time_min) as sum_minutes FROM game_info group by team_home_id
	)
	SELECT team_id, SUM(sum_minutes) as sum_minutes FROM t group by team_id
)
SELECT info_table.sum_minutes, player.player_nm, player.player_snm, player.rating from info_table INNER JOIN player on info_table.team_id = player.team_id;
--SELECT * from game_info;

-- Сводная таблица поможет нам получить все данные
WITH info_table AS (
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
	inner join game_guest on game_info.game_id = game_guest.game_id),
-- С помощью оконной функции получим среднее изменение рейтинга в зависимости от набранных сетов дома
part_table as (SELECT taken_sets_home, avg(home_dlt) OVER (PARTITION BY taken_sets_home) as avg_dlt
  FROM info_table)
SELECT taken_sets_home, avg(avg_dlt) FROM part_table GROUP BY taken_sets_home;
-- Сделаем то же самое для сетов в гостях
WITH info_table AS (
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
	inner join game_guest on game_info.game_id = game_guest.game_id),
part_table as (SELECT taken_sets_guest, avg(guest_dlt) OVER (PARTITION BY taken_sets_guest) as avg_dlt
  FROM info_table)
SELECT taken_sets_guest, avg(avg_dlt) FROM part_table GROUP BY taken_sets_guest;
--Теперь посмотрим на наибольшее и наименьшее значение изменения рейтинга в зависимости от набранных сетов, например, дома
--наибольшее
WITH info_table AS (
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
	inner join game_guest on game_info.game_id = game_guest.game_id),
part_table as (SELECT taken_sets_home, max(home_dlt) OVER (PARTITION BY taken_sets_home) as avg_dlt
  FROM info_table)
SELECT taken_sets_home, max(avg_dlt) FROM part_table GROUP BY taken_sets_home;
--наименьшее
WITH info_table AS (
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
	inner join game_guest on game_info.game_id = game_guest.game_id),
part_table as (SELECT taken_sets_home, min(home_dlt) OVER (PARTITION BY taken_sets_home) as avg_dlt
  FROM info_table)
SELECT taken_sets_home, min(avg_dlt) FROM part_table GROUP BY taken_sets_home;
--посмотрим на общее число матчей 3:0, 3:1, ...
WITH info_table AS (
	SELECT 
	game_home.taken_sets_home,
	game_guest.taken_sets_guest
	from game_info 
	inner join game_home on 
	game_info.game_id = game_home.game_id 
	inner join game_guest on game_info.game_id = game_guest.game_id)
SELECT taken_sets_home, taken_sets_guest, COUNT(*) from info_table GROUP BY (taken_sets_home, taken_sets_guest);
-- Посмотрим на историю изменения рейтинга по каждому игроку
SELECT player_id, new_rating, LAG(new_rating) OVER(PARTITION BY player_id) as prev_rating,
LEAD(new_rating) OVER(PARTITION BY player_id) as next_rating FROM player_history_rating;
--Теперь по такой таблице удобно посчитать как изменился суммарно рейтинг каждого игрока
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
