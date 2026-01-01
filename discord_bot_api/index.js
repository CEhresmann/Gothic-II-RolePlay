/**
 * @file HTTP API server for interaction between the Discord bot and the game server.
 * @author Timofey
 * @version 1.0.0
 *
 * @requires dotenv
 * @requires express
 * @requires mysql2/promise
 * @requires cors
 */

require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = process.env.API_PORT || 3000;
const API_KEY = process.env.API_KEY;

// Middleware
app.use(cors());
app.use(express.json());

/**
 * Middleware to check the API key.
 * @param {express.Request} req - The Express request object.
 * @param {express.Response} res - The Express response object.
 * @param {express.NextFunction} next - The next middleware function.
 */
const checkApiKey = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    if (!apiKey || apiKey !== API_KEY) {
        return res.status(401).json({ error: 'Invalid API key' });
    }
    next();
};

/**
 * MySQL connection pool.
 * @type {mysql.Pool}
 */
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

pool.getConnection()
    .then(connection => {
        console.log('[DB] Connected to MySQL database');
        connection.release();
    })
    .catch(err => {
        console.error('[DB] Failed to connect to MySQL:', err);
        process.exit(1);
    });

/**
 * @route POST /discord/verify
 * @group Discord - Operations for Discord integration
 * @param {string} auth_code.body.required - The authorization code.
 * @returns {object} 200 - An object with session information.
 * @returns {Error}  400 - Invalid request
 * @returns {Error}  500 - Internal server error
 */
app.post('/discord/verify', checkApiKey, async (req, res) => {
    try {
        const { auth_code } = req.body;

        if (!auth_code || typeof auth_code !== 'string') {
            return res.status(400).json({ 
                valid: false, 
                error: 'INVALID_REQUEST',
                message: 'auth_code is required' 
            });
        }

        const [sessions] = await pool.execute(
            'SELECT * FROM discord_auth_sessions WHERE auth_code = ?',
            [auth_code]
        );

        if (sessions.length === 0) {
            return res.json({ 
                valid: false, 
                error: 'INVALID_CODE' 
            });
        }

        const session = sessions[0];
        const currentTime = Date.now();

        if (session.expires_at < currentTime) {
            await pool.execute(
                'DELETE FROM discord_auth_sessions WHERE id = ?',
                [session.id]
            );
            return res.json({ 
                valid: false, 
                error: 'CODE_EXPIRED' 
            });
        }

        return res.json({
            valid: true,
            player_id: session.player_id,
            expires_at: session.expires_at
        });

    } catch (error) {
        console.error('[API] Error in /discord/verify:', error);
        return res.status(500).json({ 
            valid: false, 
            error: 'INTERNAL_ERROR',
            message: error.message 
        });
    }
});

/**
 * @route POST /discord/link
 * @group Discord - Operations for Discord integration
 * @param {string} discord_id.body.required - The user's Discord ID.
 * @param {string} auth_code.body.required - The authorization code.
 * @returns {object} 200 - An object indicating success.
 * @returns {Error}  400 - Invalid request
 * @returns {Error}  500 - Internal server error
 */
app.post('/discord/link', checkApiKey, async (req, res) => {
    try {
        const { discord_id, auth_code } = req.body;

        if (!discord_id || typeof discord_id !== 'string') {
            return res.status(400).json({ 
                success: false, 
                error: 'INVALID_REQUEST',
                message: 'discord_id is required' 
            });
        }

        if (!auth_code || typeof auth_code !== 'string') {
            return res.status(400).json({ 
                success: false, 
                error: 'INVALID_REQUEST',
                message: 'auth_code is required' 
            });
        }

        const [sessions] = await pool.execute(
            'SELECT * FROM discord_auth_sessions WHERE auth_code = ?',
            [auth_code]
        );

        if (sessions.length === 0) {
            return res.json({ 
                success: false, 
                error: 'INVALID_CODE' 
            });
        }

        const session = sessions[0];
        const currentTime = Date.now();

        if (session.expires_at < currentTime) {
            await pool.execute(
                'DELETE FROM discord_auth_sessions WHERE id = ?',
                [session.id]
            );
            return res.json({ 
                success: false, 
                error: 'CODE_EXPIRED' 
            });
        }

        const [existingAccounts] = await pool.execute(
            'SELECT id FROM player_accounts WHERE discord_id = ? AND id != ?',
            [discord_id, session.player_id]
        );

        if (existingAccounts.length > 0) {
            return res.json({ 
                success: false, 
                error: 'DISCORD_ALREADY_LINKED',
                message: 'This Discord account is already linked to another game account' 
            });
        }

        await pool.execute(
            'UPDATE player_accounts SET discord_id = ? WHERE id = ?',
            [discord_id, session.player_id]
        );

        await pool.execute(
            'DELETE FROM discord_auth_sessions WHERE id = ?',
            [session.id]
        );

        console.log(`[API] Linked Discord ${discord_id} to player ${session.player_id}`);

        return res.json({
            success: true,
            player_id: session.player_id
        });

    } catch (error) {
        console.error('[API] Error in /discord/link:', error);
        return res.status(500).json({ 
            success: false, 
            error: 'INTERNAL_ERROR',
            message: error.message 
        });
    }
});

/**
 * @route GET /discord/status
 * @group Discord - Operations for Discord integration
 * @returns {object} 200 - API status information.
 */
app.get('/discord/status', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

app.use((err, req, res, next) => {
    console.error('[API] Unhandled error:', err);
    res.status(500).json({ 
        error: 'INTERNAL_ERROR',
        message: err.message 
    });
});

app.listen(PORT, () => {
    console.log(`[API] Server started on port ${PORT}`);
    console.log(`[API] API Key required in header: x-api-key`);
});

process.on('SIGTERM', async () => {
    console.log('[API] Shutting down...');
    await pool.end();
    process.exit(0);
});
