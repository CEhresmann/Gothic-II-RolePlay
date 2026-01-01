/**
 * Discord бот для авторизации игроков через Discord
 * 
 * Команды:
 * - /auth <код> - привязка Discord аккаунта к игровому аккаунту
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

// Создание клиента Discord
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

// Регистрация Slash Command
const authCommand = new SlashCommandBuilder()
    .setName('auth')
    .setDescription('Привяжи свой Discord аккаунт к игровому аккаунту')
    .addStringOption(option =>
        option.setName('code')
            .setDescription('Код авторизации из игры')
            .setRequired(true)
    );

const commands = [authCommand];

// Регистрация команд при запуске
async function registerCommands() {
    try {
        const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
        
        console.log('[BOT] Registering slash commands...');
        
        // Регистрируем команды глобально (может занять до 1 часа)
        // Для быстрого тестирования можно использовать Routes.applicationGuildCommands(clientId, guildId)
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

// Обработка взаимодействий (команд)
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    if (interaction.commandName === 'auth') {
        const code = interaction.options.getString('code');
        const discordId = interaction.user.id;

        // Отправляем ответ "думаю..." (Discord требует ответ в течение 3 секунд)
        await interaction.deferReply({ ephemeral: true });

        try {
            // Сначала проверяем код
            const verifyResponse = await axios.post(
                `${API_URL}/discord/verify`,
                { auth_code: code },
                {
                    headers: {
                        'x-api-key': API_KEY,
                        'Content-Type': 'application/json'
                    },
                    timeout: 5000
                }
            );

            if (!verifyResponse.data.valid) {
                let errorMessage = 'Неверный код авторизации или он истёк.';
                
                if (verifyResponse.data.error === 'CODE_EXPIRED') {
                    errorMessage = 'Код авторизации истёк. Получи новый код в игре.';
                } else if (verifyResponse.data.error === 'INVALID_CODE') {
                    errorMessage = 'Неверный код авторизации. Проверь правильность ввода.';
                }

                return await interaction.editReply({
                    content: `❌ ${errorMessage}`,
                    ephemeral: true
                });
            }

            // Код валиден, привязываем Discord ID
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

            if (!linkResponse.data.success) {
                let errorMessage = 'Ошибка при привязке аккаунта.';
                
                if (linkResponse.data.error === 'DISCORD_ALREADY_LINKED') {
                    errorMessage = 'Этот Discord аккаунт уже привязан к другому игровому аккаунту.';
                } else if (linkResponse.data.error === 'CODE_EXPIRED') {
                    errorMessage = 'Код авторизации истёк. Получи новый код в игре.';
                } else if (linkResponse.data.error === 'INVALID_CODE') {
                    errorMessage = 'Неверный код авторизации.';
                }

                return await interaction.editReply({
                    content: `❌ ${errorMessage}`,
                    ephemeral: true
                });
            }

            // Успешно привязано
            console.log(`[BOT] Successfully linked Discord ${discordId} to player ${linkResponse.data.player_id}`);
            
            await interaction.editReply({
                content: `✅ **Успешно!** Твой Discord аккаунт привязан к игровому аккаунту.\n\nТеперь ты можешь закрыть окно авторизации в игре.`,
                ephemeral: true
            });

        } catch (error) {
            console.error('[BOT] Error processing auth command:', error);
            
            let errorMessage = 'Произошла ошибка при проверке кода. Попробуй позже.';
            
            if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
                errorMessage = 'Не удалось подключиться к серверу авторизации. Обратись к администратору.';
            } else if (error.response) {
                // API вернул ошибку
                errorMessage = `Ошибка сервера: ${error.response.data.message || error.response.statusText}`;
            }

            await interaction.editReply({
                content: `❌ ${errorMessage}`,
                ephemeral: true
            });
        }
    }
});

// События бота
client.once('ready', async () => {
    console.log(`[BOT] Logged in as ${client.user.tag}`);
    console.log(`[BOT] Bot is ready!`);
    
    // Регистрируем команды после готовности
    await registerCommands();
});

client.on('error', error => {
    console.error('[BOT] Discord client error:', error);
});

// Обработка ошибок процесса
process.on('unhandledRejection', error => {
    console.error('[BOT] Unhandled promise rejection:', error);
});

// Запуск бота
client.login(DISCORD_TOKEN).catch(error => {
    console.error('[BOT] Failed to login:', error);
    process.exit(1);
});
