CREATE TABLE Equipment
(
	Equipment_id serial PRIMARY KEY,
	Type integer NOT NULL,
	Equipment_nm varchar(255) NOT NULL UNIQUE,
	Equipment_desc text NOT NULL UNIQUE
);

CREATE TABLE Stage
(
	Stage_id serial PRIMARY KEY,
	Stage_nm varchar(255) NOT NULL
);

CREATE TABLE Team
(
	Team_id serial PRIMARY KEY,
	Team_nm varchar(255) NOT NULL
);

CREATE TABLE Club
(
	Club_id serial PRIMARY KEY,
	Club_nm varchar(255) NOT NULL,
	Club_desc text
);

CREATE TABLE Tournament
(
	Tournament_id serial PRIMARY KEY,
	Club_id serial,
	FOREIGN KEY(Club_id) REFERENCES Club(Club_id),
	Type integer NOT NULL,
	Start_ddtm timestamp NOT NULL,
	Max_players integer NOT NULL,
	Players_cnt integer DEFAULT 0,
	Payment integer NOT NULL,
	Max_rating integer NOT NULL,
	Min_rating integer NOT NULL
);

CREATE TABLE Game_info
(
	Game_id serial PRIMARY KEY,
	Tournament_id serial,
	FOREIGN KEY(Tournament_id) REFERENCES Tournament(Tournament_id),
	Stage_id serial,
	FOREIGN KEY(Stage_id) REFERENCES Stage(Stage_id),
	Team_guest_id serial,
	FOREIGN KEY(Team_guest_id) REFERENCES Team(Team_id),
	Team_home_id serial,
	FOREIGN KEY(Team_home_id) REFERENCES Team(Team_id),
	Time_min integer NOT NULL
);



CREATE TABLE Player
(
	Player_id serial PRIMARY KEY,
	Team_id serial,
	FOREIGN KEY(Team_id) REFERENCES Team(Team_id),
	Equipment_id serial,
	FOREIGN KEY(Equipment_id) REFERENCES Equipment(Equipment_id),
	Player_nm varchar(255) NOT NULL,
	Player_snm varchar(255) NOT NULL,
	Rating float(1) DEFAULT 0.0
);

CREATE TABLE Game_guest
(
	Game_id serial PRIMARY KEY,
	Team_guest_id serial,
	FOREIGN KEY(Team_guest_id) REFERENCES Team(Team_id),
	Taken_sets_guest integer NOT NULL,
	Rating_delta float(1) NOT NULL
);

CREATE TABLE Game_home
(
	Game_id serial PRIMARY KEY,
	Team_home_id serial,
	FOREIGN KEY(Team_home_id) REFERENCES Team(Team_id),
	Taken_sets_home integer NOT NULL,
	Rating_delta float(1) NOT NULL
);

CREATE TABLE Player_history_rating
(
	Iter_no serial PRIMARY KEY,
	Player_id serial,
	FOREIGN KEY(Player_id) REFERENCES Player(Player_id),
	Change_time TIMESTAMP NOT NULL,
	New_rating float(1) NOT NULL
);

CREATE TABLE Player_history_equipment
(
	Iter_no serial PRIMARY KEY,
	Player_id serial,
	FOREIGN KEY(Player_id) REFERENCES Player(Player_id),
	Change_time TIMESTAMP NOT NULL,
	New_equipment_id serial,
	FOREIGN KEY(New_equipment_id) REFERENCES Equipment(Equipment_id)
);

CREATE TABLE Player_history_team
(
	Iter_no serial PRIMARY KEY,
	Player_id serial,
	FOREIGN KEY(Player_id) REFERENCES Player(Player_id),
	Change_time TIMESTAMP NOT NULL,
	New_team_id serial,
	FOREIGN KEY(New_team_id) REFERENCES Team(Team_id)
);