-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 23.88.65.9:3306
-- Generation Time: Wrz 19, 2025 at 02:24 PM
-- Wersja serwera: 11.4.5-MariaDB-deb12
-- Wersja PHP: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `db_112429`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `admins_account`
--

CREATE TABLE `admins_account` (
  `id` int(11) NOT NULL,
  `uid` varchar(255) NOT NULL DEFAULT '',
  `rank` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Database_Health`
--

CREATE TABLE `Database_Health` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `player_accounts`
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
  `description` text DEFAULT '',
  `body_model` varchar(64) DEFAULT '',
  `body_texture` int(11) DEFAULT 0,
  `head_model` varchar(64) DEFAULT '',
  `head_texture` int(11) DEFAULT 0,
  `fatness` float NOT NULL DEFAULT 0,
  `scale_x` float NOT NULL DEFAULT 1,
  `scale_y` float NOT NULL DEFAULT 1,
  `scale_z` float NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `player_items`
--

CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT -1,
  `item_instance` varchar(64) NOT NULL DEFAULT '',
  `amount` int(11) NOT NULL DEFAULT 1,
  `equipped` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `player_positions`
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
-- Struktura tabeli dla tabeli `player_skills`
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
-- Struktura tabeli dla tabeli `server_logs`
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
-- Struktura tabeli dla tabeli `worldbuilder_vobs`
--

CREATE TABLE `worldbuilder_vobs` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `rotx` int(11) DEFAULT NULL,
  `roty` int(11) DEFAULT NULL,
  `rotz` int(11) DEFAULT NULL,
  `isStatic` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `world_draws`
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
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `admins_account`
--
ALTER TABLE `admins_account`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uid` (`uid`);

--
-- Indeksy dla tabeli `Database_Health`
--
ALTER TABLE `Database_Health`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `player_accounts`
--
ALTER TABLE `player_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeksy dla tabeli `player_items`
--
ALTER TABLE `player_items`
  ADD PRIMARY KEY (`player_id`,`item_instance`);

--
-- Indeksy dla tabeli `player_positions`
--
ALTER TABLE `player_positions`
  ADD PRIMARY KEY (`player_id`);

--
-- Indeksy dla tabeli `player_skills`
--
ALTER TABLE `player_skills`
  ADD PRIMARY KEY (`player_id`);

--
-- Indeksy dla tabeli `server_logs`
--
ALTER TABLE `server_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `worldbuilder_vobs`
--
ALTER TABLE `worldbuilder_vobs`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `world_draws`
--
ALTER TABLE `world_draws`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `admins_account`
--
ALTER TABLE `admins_account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `Database_Health`
--
ALTER TABLE `Database_Health`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `player_accounts`
--
ALTER TABLE `player_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `server_logs`
--
ALTER TABLE `server_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `worldbuilder_vobs`
--
ALTER TABLE `worldbuilder_vobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `world_draws`
--
ALTER TABLE `world_draws`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
