SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET NAMES utf8mb4 */;

-- =====================================================
-- player_accounts (root entity)
-- =====================================================

CREATE TABLE `player_accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(32) NOT NULL,
  `password` VARCHAR(255) NOT NULL,

  `class_id` INT NOT NULL DEFAULT 0,
  `fraction_id` INT NOT NULL DEFAULT 0,

  `walk_style` VARCHAR(32) DEFAULT 'HUMANS',

  `strength` INT NOT NULL DEFAULT 10,
  `dexterity` INT NOT NULL DEFAULT 10,

  `hp_max` INT NOT NULL DEFAULT 100,
  `mana_max` INT NOT NULL DEFAULT 0,
  `hp` INT NOT NULL DEFAULT 100,
  `mana` INT NOT NULL DEFAULT 30,

  `magic_level` INT NOT NULL DEFAULT 0,
  `learning_points` INT NOT NULL DEFAULT 0,

  `profession_hunter` INT NOT NULL DEFAULT 0,
  `profession_archer` INT NOT NULL DEFAULT 0,
  `profession_blacksmith` INT NOT NULL DEFAULT 0,
  `profession_armorer` INT NOT NULL DEFAULT 0,
  `profession_alchemist` INT NOT NULL DEFAULT 0,
  `profession_cook` INT NOT NULL DEFAULT 0,

  `description` TEXT,
  `body_model` VARCHAR(64),
  `body_texture` INT,
  `head_model` VARCHAR(64),
  `head_texture` INT,

  `fatness` FLOAT NOT NULL DEFAULT 0,
  `scale_x` FLOAT NOT NULL DEFAULT 1,
  `scale_y` FLOAT NOT NULL DEFAULT 1,
  `scale_z` FLOAT NOT NULL DEFAULT 1,

  `CK` TINYINT(1) NOT NULL DEFAULT 0,
  `discord_id` VARCHAR(20),

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_player_name` (`name`),
  UNIQUE KEY `uk_discord_id` (`discord_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- discord_auth_sessions (1:N)
-- =====================================================

CREATE TABLE `discord_auth_sessions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `player_id` INT NOT NULL,
  `auth_code` VARCHAR(8) NOT NULL,
  `expires_at` INT NOT NULL,

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_auth_code` (`auth_code`),
  KEY `idx_expires_at` (`expires_at`),

  CONSTRAINT `fk_auth_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- player_positions (1:1)
-- =====================================================

CREATE TABLE `player_positions` (
  `player_id` INT NOT NULL,
  `pos_x` FLOAT NOT NULL DEFAULT 0,
  `pos_y` FLOAT NOT NULL DEFAULT 0,
  `pos_z` FLOAT NOT NULL DEFAULT 0,
  `angle` FLOAT NOT NULL DEFAULT 0,

  PRIMARY KEY (`player_id`),
  CONSTRAINT `fk_position_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- player_skills (1:1)
-- =====================================================

CREATE TABLE `player_skills` (
  `player_id` INT NOT NULL,
  `weapon_0` INT NOT NULL DEFAULT 10,
  `weapon_1` INT NOT NULL DEFAULT 10,
  `weapon_2` INT NOT NULL DEFAULT 10,
  `weapon_3` INT NOT NULL DEFAULT 10,

  PRIMARY KEY (`player_id`),
  CONSTRAINT `fk_skills_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- player_items (1:N)
-- =====================================================

CREATE TABLE `player_items` (
  `player_id` INT NOT NULL,
  `item_instance` VARCHAR(64) NOT NULL,
  `amount` INT NOT NULL DEFAULT 1,
  `equipped` TINYINT(1) NOT NULL DEFAULT 0,

  PRIMARY KEY (`player_id`, `item_instance`),
  CONSTRAINT `fk_items_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- server_logs (N:1)
-- =====================================================

CREATE TABLE `server_logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `player_id` INT NULL,
  `message` TEXT NOT NULL,
  `type` VARCHAR(20),
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  KEY `idx_log_player` (`player_id`),

  CONSTRAINT `fk_logs_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

COMMIT;

-- =====================================================
-- admins_account 0:1
-- =====================================================

CREATE TABLE `admins_account` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `player_id` INT NULL,
  `uid` VARCHAR(255) NOT NULL,
  `rank` INT NOT NULL DEFAULT 0,

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_uid` (`uid`),
  UNIQUE KEY `uk_admin_player` (`player_id`),

  CONSTRAINT `fk_admin_player`
    FOREIGN KEY (`player_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- worldbuilder_vobs
-- =====================================================
CREATE TABLE `worldbuilder_vobs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,

  `x` FLOAT NOT NULL DEFAULT 0,
  `y` FLOAT NOT NULL DEFAULT 0,
  `z` FLOAT NOT NULL DEFAULT 0,

  `rotx` INT NOT NULL DEFAULT 0,
  `roty` INT NOT NULL DEFAULT 0,
  `rotz` INT NOT NULL DEFAULT 0,

  `is_static` TINYINT(1) NOT NULL DEFAULT 0,
  `vob_type` INT NOT NULL DEFAULT 0,
  `key_instance` VARCHAR(255),

  `created_by` INT NULL,

  PRIMARY KEY (`id`),
  KEY `idx_vob_creator` (`created_by`),

  CONSTRAINT `fk_vob_creator`
    FOREIGN KEY (`created_by`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
-- world_draws
-- =====================================================
CREATE TABLE `world_draws` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `text` VARCHAR(255) NOT NULL,

  `x` FLOAT NOT NULL DEFAULT 0,
  `y` FLOAT NOT NULL DEFAULT 0,
  `z` FLOAT NOT NULL DEFAULT 0,

  `distance` INT NOT NULL DEFAULT 800,

  `color_r` TINYINT UNSIGNED NOT NULL DEFAULT 255,
  `color_g` TINYINT UNSIGNED NOT NULL DEFAULT 255,
  `color_b` TINYINT UNSIGNED NOT NULL DEFAULT 255,
  `color_a` TINYINT UNSIGNED NOT NULL DEFAULT 255,

  `creator_id` INT NULL,

  PRIMARY KEY (`id`),
  KEY `idx_draw_creator` (`creator_id`),

  CONSTRAINT `fk_draw_creator`
    FOREIGN KEY (`creator_id`)
    REFERENCES `player_accounts` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================
--  Database_Health
-- =====================================================
CREATE TABLE `database_health` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `checked_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` TINYINT(1) NOT NULL DEFAULT 1,
  `note` VARCHAR(255),

  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
