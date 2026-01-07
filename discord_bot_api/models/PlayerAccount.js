import { DataTypes } from 'sequelize';
import sequelize from '../database.js';

const PlayerAccount = sequelize.define('PlayerAccount', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false
    },
    name: {
        type: DataTypes.STRING(32),
        allowNull: false,
        defaultValue: '',
        unique: true
    },
    password: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    class_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    fraction_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    walk_style: {
        type: DataTypes.STRING(32),
        defaultValue: 'HUMANS'
    },
    strength: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 10
    },
    dexterity: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 10
    },
    hp_max: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 100
    },
    mana_max: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    hp: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 100
    },
    mana: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 30
    },
    magic_level: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    learning_points: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_hunter: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_archer: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_blacksmith: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_armorer: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_alchemist: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    profession_cook: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    description: {
        type: DataTypes.TEXT,
        defaultValue: ''
    },
    body_model: {
        type: DataTypes.STRING(64),
        defaultValue: ''
    },
    body_texture: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    head_model: {
        type: DataTypes.STRING(64),
        defaultValue: ''
    },
    head_texture: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    fatness: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 0
    },
    scale_x: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 1
    },
    scale_y: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 1
    },
    scale_z: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 1
    },
    CK: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
    },
    discord_id: {
        type: DataTypes.STRING(20),
        allowNull: true,
        defaultValue: null
    }
}, {
    tableName: 'player_accounts',
    timestamps: false
});

export default PlayerAccount;


