/**
 * @file Discord bot for player authorization via Discord.
 * @author Timofey
 * @version 1.0.0
 */

require('dotenv').config();
const { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes } = require('discord.js');
const axios = require('axios');

const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const API_URL = process.env.API_URL || 'http://localhost:3000';
const API_KEY = process.env.API_KEY;

if (!DISCORD_TOKEN) {
    console.error('[BOT] DISCORD_TOKEN is not set in .env file');
    process.exit(1);
}

if (!API_KEY) {
    console.error('[BOT] API_KEY is not set in .env file');
    process.exit(1);
}

/**
 * The Discord client instance.
 * @type {Client}
 */
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

/**
 * Slash command for authorization.
 * @type {SlashCommandBuilder}
 */
const authCommand = new SlashCommandBuilder()
    .setName('auth')
    .setDescription('Link your Discord account to your game account')
    .addStringOption(option =>
        option.setName('code')
            .setDescription('Authorization code from the game')
            .setRequired(true)
    );

const commands = [authCommand];

/**
 * Registers slash commands with Discord.
 * @async
 * @function registerCommands
 */
async function registerCommands() {
    try {
        const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
        
        console.log('[BOT] Registering slash commands...');
        
        // For quick testing, you can use Routes.applicationGuildCommands(clientId, guildId)
        const clientId = client.user.id;
        await rest.put(
            Routes.applicationCommands(clientId),
            { body: commands }
        );
        
        console.log('[BOT] Successfully registered slash commands');
    } catch (error) {
        console.error('[BOT] Error registering commands:', error);
    }
}

client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    if (interaction.commandName === 'auth') {
        const code = interaction.options.getString('code');
        const discordId = interaction.user.id;

        await interaction.deferReply({ ephemeral: true });

        try {
            const linkResponse = await axios.post(
                `${API_URL}/discord/link`,
                {
                    discord_id: discordId,
                    auth_code: code
                },
                {
                    headers: {
                        'x-api-key': API_KEY,
                        'Content-Type': 'application/json'
                    },
                    timeout: 5000
                }
            );

            if (linkResponse.data.success) {
                console.log(`[BOT] Successfully linked Discord ${discordId} to player ${linkResponse.data.player_id}`);
                await interaction.editReply({
                    content: `✅ **Success!** Your Discord account has been linked to your game account.\n\nYou can now close the authorization window in the game.`,
                    ephemeral: true
                });
            } else {
                let errorMessage = 'An error occurred while linking your account.';
                switch (linkResponse.data.error) {
                    case 'INVALID_CODE':
                        errorMessage = 'Invalid authorization code. Please check your input.';
                        break;
                    case 'CODE_EXPIRED':
                        errorMessage = 'The authorization code has expired. Please get a new one in the game.';
                        break;
                    case 'DISCORD_ALREADY_LINKED':
                        errorMessage = 'This Discord account is already linked to another game account.';
                        break;
                }
                await interaction.editReply({
                    content: `❌ ${errorMessage}`,
                    ephemeral: true
                });
            }

        } catch (error) {
            console.error('[BOT] Error processing auth command:', error);
            
            let errorMessage = 'An error occurred while processing your request. Please try again later.';
            
            if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
                errorMessage = 'Could not connect to the authorization server. Please contact an administrator.';
            } else if (error.response) {
                errorMessage = `Server error: ${error.response.statusText}. Please contact an administrator.`;
            }

            await interaction.editReply({
                content: `❌ ${errorMessage}`,
                ephemeral: true
            });
        }
    }
});

client.once('ready', async () => {
    console.log(`[BOT] Logged in as ${client.user.tag}`);
    console.log(`[BOT] Bot is ready!`);
    
    await registerCommands();
});

client.on('error', error => {
    console.error('[BOT] Discord client error:', error);
});

process.on('unhandledRejection', error => {
    console.error('[BOT] Unhandled promise rejection:', error);
});

client.login(DISCORD_TOKEN).catch(error => {
    console.error('[BOT] Failed to login:', error);
    process.exit(1);
});
