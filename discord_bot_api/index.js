/**
 * @file HTTP API server for interaction between the Discord bot and the game server.
 * @author Timofey
 * @version 1.0.0
 *
 * @requires dotenv
 * @requires express
 * @requires sequelize
 * @requires cors
 */

import 'dotenv/config';
import express from 'express';
import crypto from 'crypto';
import cors from 'cors';
import { Op } from 'sequelize';
import sequelize from './database.js';
import DiscordAuthSession from './models/DiscordAuthSession.js';
import PlayerAccount from './models/PlayerAccount.js';

const ERROR_CODES = {
    INVALID_REQUEST: 'INVALID_REQUEST',
    INVALID_API_KEY: 'INVALID_API_KEY',
    INVALID_CODE: 'INVALID_CODE',
    CODE_EXPIRED: 'CODE_EXPIRED',
    DISCORD_ALREADY_LINKED: 'DISCORD_ALREADY_LINKED',
    INTERNAL_ERROR: 'INTERNAL_ERROR'
};

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
    if (!apiKey) {
        return res.status(401).json({ error: ERROR_CODES.INVALID_API_KEY });
    }

    try {
        const apiKeyBuffer = Buffer.from(apiKey, 'utf8');
        const expectedApiKeyBuffer = Buffer.from(API_KEY, 'utf8');
        if (crypto.timingSafeEqual(apiKeyBuffer, expectedApiKeyBuffer)) {
            next();
        } else {
            res.status(401).json({ error: ERROR_CODES.INVALID_API_KEY });
        }
    } catch (error) {
        res.status(401).json({ error: ERROR_CODES.INVALID_API_KEY });
    }
};

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
                error: ERROR_CODES.INVALID_REQUEST,
                message: 'auth_code is required' 
            });
        }

        const session = await DiscordAuthSession.findOne({ where: { auth_code } });

        if (!session) {
            return res.json({ 
                valid: false, 
                error: ERROR_CODES.INVALID_CODE
            });
        }

        const currentTime = Date.now();
        if (session.expires_at < currentTime) {
            return res.json({ 
                valid: false, 
                error: ERROR_CODES.CODE_EXPIRED
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
            error: ERROR_CODES.INTERNAL_ERROR
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
                error: ERROR_CODES.INVALID_REQUEST,
                message: 'discord_id is required' 
            });
        }

        if (!auth_code || typeof auth_code !== 'string') {
            return res.status(400).json({ 
                success: false, 
                error: ERROR_CODES.INVALID_REQUEST,
                message: 'auth_code is required' 
            });
        }

        const session = await DiscordAuthSession.findOne({ where: { auth_code } });

        if (!session) {
            return res.json({ 
                success: false, 
                error: ERROR_CODES.INVALID_CODE
            });
        }

        const currentTime = Date.now();
        if (session.expires_at < currentTime) {
            return res.json({ 
                success: false, 
                error: ERROR_CODES.CODE_EXPIRED
            });
        }

        const existingAccount = await PlayerAccount.findOne({ 
            where: { 
                discord_id,
                id: { [Op.ne]: session.player_id }
            } 
        });

        if (existingAccount) {
            return res.json({ 
                success: false, 
                error: ERROR_CODES.DISCORD_ALREADY_LINKED,
                message: 'This Discord account is already linked to another game account' 
            });
        }

        await PlayerAccount.update({ discord_id }, { where: { id: session.player_id } });
        await session.destroy();

        console.log(`[API] Linked Discord ${discord_id} to player ${session.player_id}`);

        return res.json({
            success: true,
            player_id: session.player_id
        });

    } catch (error) {
        console.error('[API] Error in /discord/link:', error);
        return res.status(500).json({ 
            success: false, 
            error: ERROR_CODES.INTERNAL_ERROR
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
        error: ERROR_CODES.INTERNAL_ERROR
    });
});

const startServer = async () => {
    try {
        console.log('[DB] Attempting to connect to MySQL...');
        await sequelize.authenticate();
        console.log('[DB] Connected to MySQL database via Sequelize');
        
        await sequelize.sync(); // Uncomment to auto-sync models with the database (creates tables)

        app.listen(PORT, () => {
            console.log(`[API] Server started on port ${PORT}`);
            console.log(`[API] API Key required in header: x-api-key`);
        });
    } catch (error) {
        console.error('[DB] Failed to connect to MySQL via Sequelize:', error);
        process.exit(1);
    }
};

startServer();

process.on('SIGTERM', async () => {
    console.log('[API] Shutting down...');
    await sequelize.close();
    process.exit(0);
});
