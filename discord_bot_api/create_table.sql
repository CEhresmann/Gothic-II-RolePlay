--
-- SQL script for initializing the database structure.
-- This script creates all necessary tables for the game server and Discord authentication.
--

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `g2o_rp`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins_account`
--

CREATE TABLE `admins_account` (
  `id` int(11) NOT NULL,
  `uid` varchar(255) NOT NULL DEFAULT '',
  `rank` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Database_Health`
--

CREATE TABLE `Database_Health` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_accounts`
--

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
  `hp` int(255) NOT NULL DEFAULT 100,
  `mana` int(255) NOT NULL DEFAULT 30,
  `magic_level` int(11) NOT NULL DEFAULT 0,
  `learning_points` int(255) NOT NULL DEFAULT 0,
  `profession_hunter` int(11) NOT NULL DEFAULT 0,
  `profession_archer` int(11) NOT NULL DEFAULT 0,
  `profession_blacksmith` int(11) NOT NULL DEFAULT 0,
  `profession_armorer` int(11) NOT NULL DEFAULT 0,
  `profession_alchemist` int(11) NOT NULL DEFAULT 0,
  `profession_cook` int(11) NOT NULL DEFAULT 0,
  `description` text DEFAULT '',
  `body_model` varchar(64) DEFAULT '',
  `body_texture` int(11) DEFAULT 0,
  `head_model` varchar(64) DEFAULT '',
  `head_texture` int(11) DEFAULT 0,
  `fatness` float NOT NULL DEFAULT 0,
  `scale_x` float NOT NULL DEFAULT 1,
  `scale_y` float NOT NULL DEFAULT 1,
  `scale_z` float NOT NULL DEFAULT 1,
  `CK` int(1) NOT NULL DEFAULT 0,
  `discord_id` VARCHAR(20) NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `discord_auth_sessions`
--

CREATE TABLE IF NOT EXISTS `discord_auth_sessions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `auth_code` VARCHAR(8) NOT NULL,
    `expires_at` INT NOT NULL,
    INDEX `idx_auth_code` (`auth_code`),
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_expires_at` (`expires_at`),
    FOREIGN KEY (`player_id`) REFERENCES `player_accounts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_items`
--

CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `item_instance` varchar(64) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL DEFAULT 1,
  `equipped` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_positions`
--

CREATE TABLE `player_positions` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `pos_x` float NOT NULL DEFAULT 0,
  `pos_y` float NOT NULL DEFAULT 0,
  `pos_z` float NOT NULL DEFAULT 0,
  `angle` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_skills`
--

CREATE TABLE `player_skills` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `weapon_0` int(11) NOT NULL DEFAULT 10,
  `weapon_1` int(11) NOT NULL DEFAULT 10,
  `weapon_2` int(11) NOT NULL DEFAULT 10,
  `weapon_3` int(11) NOT NULL DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `server_logs`
--

CREATE TABLE `server_logs` (
  `id` int(11) NOT NULL,
  `player_name` varchar(255) NOT NULL DEFAULT '',
  `player_uid` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL DEFAULT '',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `type` varchar(20) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `worldbuilder_vobs`
--

CREATE TABLE `worldbuilder_vobs` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT '',
  `x` float DEFAULT 0,
  `y` float DEFAULT 0,
  `z` float DEFAULT 0,
  `rotx` int(11) DEFAULT 0,
  `roty` int(11) DEFAULT 0,
  `rotz` int(11) DEFAULT 0,
  `isStatic` tinyint(1) DEFAULT 0,
  `vobType` int(11) DEFAULT 0,
  `keyInstance` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `world_draws`
--

CREATE TABLE `world_draws` (
  `id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL DEFAULT '',
  `x` float NOT NULL DEFAULT 0,
  `y` float NOT NULL DEFAULT 0,
  `z` float NOT NULL DEFAULT 0,
  `distance` int(11) NOT NULL DEFAULT 800,
  `color_r` int(11) NOT NULL DEFAULT 255,
  `color_g` int(11) NOT NULL DEFAULT 255,
  `color_b` int(11) NOT NULL DEFAULT 255,
  `color_a` int(11) NOT NULL DEFAULT 255,
  `creator_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins_account`
--
ALTER TABLE `admins_account`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uid` (`uid`);

--
-- Indexes for table `Database_Health`
--
ALTER TABLE `Database_Health`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `player_accounts`
--
ALTER TABLE `player_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD INDEX `idx_discord_id` (`discord_id`);

--
-- Indexes for table `player_items`
--
ALTER TABLE `player_items`
  ADD PRIMARY KEY (`player_id`,`item_instance`);

--
-- Indexes for table `player_positions`
--
ALTER TABLE `player_positions`
  ADD PRIMARY KEY (`player_id`);

--
-- Indexes for table `player_skills`
--
ALTER TABLE `player_skills`
  ADD PRIMARY KEY (`player_id`);

--
-- Indexes for table `server_logs`
--
ALTER TABLE `server_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `worldbuilder_vobs`
--
ALTER TABLE `worldbuilder_vobs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `world_draws`
--
ALTER TABLE `world_draws`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins_account`
--
ALTER TABLE `admins_account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Database_Health`
--
ALTER TABLE `Database_Health`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_accounts`
--
ALTER TABLE `player_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `server_logs`
--
ALTER TABLE `server_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `worldbuilder_vobs`
--
ALTER TABLE `worldbuilder_vobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `world_draws`
--
ALTER TABLE `world_draws`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
