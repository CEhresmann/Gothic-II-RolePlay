import { DataTypes } from 'sequelize';
import sequelize from '../database.js';
import PlayerAccount from './PlayerAccount.js';

const DiscordAuthSession = sequelize.define('DiscordAuthSession', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: PlayerAccount,
            key: 'id'
        }
    },
    auth_code: {
        type: DataTypes.STRING(8),
        allowNull: false
    },
    expires_at: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
}, {
    tableName: 'discord_auth_sessions',
    timestamps: false,
    indexes: [
        {
            name: 'idx_auth_code',
            fields: ['auth_code']
        },
        {
            name: 'idx_player_id',
            fields: ['player_id']
        },
        {
            name: 'idx_expires_at',
            fields: ['expires_at']
        }
    ]
});

DiscordAuthSession.belongsTo(PlayerAccount, { foreignKey: 'player_id' });
PlayerAccount.hasMany(DiscordAuthSession, { foreignKey: 'player_id' });

export default DiscordAuthSession;

