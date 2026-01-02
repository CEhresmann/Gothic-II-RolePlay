const { DataTypes } = require('sequelize');
const sequelize = require('../database');

const PlayerAccount = sequelize.define('PlayerAccount', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    discord_id: {
        type: DataTypes.STRING,
        allowNull: true
    }
    // Add other fields from your player_accounts table here
}, {
    tableName: 'player_accounts',
    timestamps: false
});

module.exports = PlayerAccount;
