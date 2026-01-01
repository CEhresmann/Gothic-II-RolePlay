-- SQL script for creating the discord_auth_sessions table
-- Execute in MySQL if the table has not been created yet

CREATE TABLE IF NOT EXISTS discord_auth_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    auth_code VARCHAR(8) NOT NULL,
    expires_at INT NOT NULL,
    INDEX idx_auth_code (auth_code),
    INDEX idx_player_id (player_id),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (player_id) REFERENCES player_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=cp1250 COLLATE=cp1250_polish_ci;

-- Check for the existence of the discord_id field in player_accounts
-- If the field already exists, the command will not be executed (safe)
ALTER TABLE player_accounts 
ADD COLUMN IF NOT EXISTS discord_id VARCHAR(20) NULL DEFAULT NULL AFTER CK;

-- Create an index for fast searching by discord_id
CREATE INDEX IF NOT EXISTS idx_discord_id ON player_accounts(discord_id);


