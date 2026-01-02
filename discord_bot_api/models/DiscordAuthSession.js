const { DataTypes } = require('sequelize');
const sequelize = require('../database');

const DiscordAuthSession = sequelize.define('DiscordAuthSession', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    auth_code: {
        type: DataTypes.STRING(10),
        allowNull: false
    },
    expires_at: {
        type: DataTypes.BIGINT,
        allowNull: false
    }
}, {
    tableName: 'discord_auth_sessions',
    timestamps: false
});

module.exports = DiscordAuthSession;
