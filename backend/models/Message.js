const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Message = sequelize.define(
  'Message',
  {
    id: { type: DataTypes.BIGINT, primaryKey: true, autoIncrement: true },
    sessionId: { type: DataTypes.STRING(100), allowNull: false, field: 'session_id' },
    sender: { type: DataTypes.STRING(50), allowNull: false },
    content: { type: DataTypes.TEXT, allowNull: false },
    createdAt: { type: DataTypes.DATE, field: 'created_at' },
  },
  {
    tableName: 'messages',
    timestamps: false, // 表里只有 created_at
    underscored: false,
  }
)

module.exports = Message

