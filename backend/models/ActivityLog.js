const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const ActivityLog = sequelize.define('ActivityLog', {
  logId: {
    type: DataTypes.INTEGER,
    field: 'log_id',
    autoIncrement: true,
    primaryKey: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'user_id'
  },
  username: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  action: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  method: {
    type: DataTypes.STRING(10),
    allowNull: false
  },
  route: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  statusCode: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'status_code'
  },
  success: {
    type: DataTypes.TINYINT,
    allowNull: false,
    defaultValue: 1
  },
  durationMs: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'duration_ms'
  },
  ipAddress: {
    type: DataTypes.STRING(64),
    allowNull: true,
    field: 'ip_address'
  },
  userAgent: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'user_agent'
  },
  requestPayload: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'request_payload'
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'created_at'
  }
}, {
  tableName: 'activity_logs',
  timestamps: false
})

module.exports = ActivityLog
