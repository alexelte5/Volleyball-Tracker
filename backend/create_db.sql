CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    team_name TEXT NOT NULL,
    img_url TEXT
);

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    team_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    birth_date DATE,
    jersey_number INTEGER,
    position TEXT,
    profile_img TEXT,
    FOREIGN KEY (team_id) REFERENCES teams(id) -- Fremdschlüsselbeziehung zu "teams"
);

CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    match_day DATE NOT NULL,
    team_id1 INTEGER,
    team_id2 INTEGER,
    set_score1 INTEGER NOT NULL,
    set_score2 INTEGER NOT NULL,
    FOREIGN KEY (team_id1) REFERENCES teams(id), -- Fremdschlüsselbeziehung zu "teams"
    FOREIGN KEY (team_id2) REFERENCES teams(id)  -- Fremdschlüsselbeziehung zu "teams"
);

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    player_id INTEGER,
    match_id INTEGER,
    start_pos_x FLOAT NOT NULL,
    start_pos_y FLOAT NOT NULL,
    end_pos_x FLOAT NOT NULL,
    end_pos_y FLOAT NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(id), -- Fremdschlüsselbeziehung zu "players"
    FOREIGN KEY (match_id) REFERENCES matches(id)  -- Fremdschlüsselbeziehung zu "matches"
);

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    player_id INTEGER,
    match_id INTEGER,
    service_pp INTEGER,
    service_p INTEGER,
    service_n INTEGER,
    service_m INTEGER,
    attack_pp INTEGER,
    attack_p INTEGER,
    attack_n INTEGER,
    attack_m INTEGER,
    block_pp INTEGER,
    block_n INTEGER,
    block_m INTEGER,
    receive_p INTEGER,
    receive_n INTEGER,
    receive_m INTEGER,
    defense_p INTEGER,
    defense_n INTEGER,
    defense_m INTEGER,
    FOREIGN KEY (player_id) REFERENCES players(id), -- Fremdschlüsselbeziehung zu "players"
    FOREIGN KEY (match_id) REFERENCES matches(id)  -- Fremdschlüsselbeziehung zu "matches"
);

