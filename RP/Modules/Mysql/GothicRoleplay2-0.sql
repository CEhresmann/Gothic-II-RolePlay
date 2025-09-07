

CREATE TABLE `Database_Health` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `player_accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL,
  `class_id` int(11) NOT NULL DEFAULT 0,
  `fraction_id` int(11) NOT NULL DEFAULT 0,
  `walk_style` varchar(32) DEFAULT 'HUMANS',
  `strength` int(11) NOT NULL DEFAULT 10,
  `dexterity` int(11) NOT NULL DEFAULT 10,
  `hp_max` int(11) NOT NULL DEFAULT 100,
  `mana_max` int(11) NOT NULL DEFAULT 0,
  `magic_level` int(11) NOT NULL DEFAULT 0,
  `description` text DEFAULT '',
  `body_model` varchar(64) DEFAULT '',
  `body_texture` int(11) DEFAULT 0,
  `head_model` varchar(64) DEFAULT '',
  `head_texture` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `item_instance` varchar(64) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `player_positions` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `pos_x` float NOT NULL DEFAULT 0,
  `pos_y` float NOT NULL DEFAULT 0,
  `pos_z` float NOT NULL DEFAULT 0,
  `angle` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `player_skills` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `weapon_0` int(11) NOT NULL DEFAULT 0,
  `weapon_1` int(11) NOT NULL DEFAULT 0,
  `weapon_2` int(11) NOT NULL DEFAULT 0,
  `weapon_3` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

