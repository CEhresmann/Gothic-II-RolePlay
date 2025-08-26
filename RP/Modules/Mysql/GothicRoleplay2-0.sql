
CREATE TABLE player_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE,
    password VARCHAR(32) NOT NULL,
    class_id INT NOT NULL DEFAULT 0,
    fraction_id INT NOT NULL DEFAULT 0,
    walk_style VARCHAR(32) NOT NULL,
    strength INT NOT NULL DEFAULT 10,
    dexterity INT NOT NULL DEFAULT 10,
    hp_max INT NOT NULL DEFAULT 100,
    mana_max INT NOT NULL DEFAULT 0,
    magic_level INT NOT NULL DEFAULT 0,
    description TEXT,
    body_model VARCHAR(64),
    body_texture INT DEFAULT 0,
    head_model VARCHAR(64),
    head_texture INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=cp1250 COLLATE=cp1250_polish_ci;


CREATE TABLE player_positions (
    player_id INT PRIMARY KEY,
    pos_x FLOAT NOT NULL DEFAULT 0,
    pos_y FLOAT NOT NULL DEFAULT 0,
    pos_z FLOAT NOT NULL DEFAULT 0,
    angle FLOAT NOT NULL DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES player_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=cp1250 COLLATE=cp1250_polish_ci;


CREATE TABLE player_skills (
    player_id INT PRIMARY KEY,
    weapon_0 INT NOT NULL DEFAULT 0,
    weapon_1 INT NOT NULL DEFAULT 0,
    weapon_2 INT NOT NULL DEFAULT 0,
    weapon_3 INT NOT NULL DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES player_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=cp1250 COLLATE=cp1250_polish_ci;


CREATE TABLE player_items (
    player_id INT NOT NULL,
    item_instance VARCHAR(64) NOT NULL,
    amount INT NOT NULL DEFAULT 1,
    PRIMARY KEY (player_id, item_instance),
    FOREIGN KEY (player_id) REFERENCES player_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=cp1250 COLLATE=cp1250_polish_ci;
