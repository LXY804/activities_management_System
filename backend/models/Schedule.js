const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Schedule = sequelize.define('Schedule', {
  scheduleId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'schedule_id'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  title: {
    type: DataTypes.STRING(120),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  scheduleDate: {
    type: DataTypes.DATEONLY,
    allowNull: false,
    field: 'schedule_date'
  },
  startTime: {
    type: DataTypes.TIME,
    allowNull: true,
    field: 'start_time'
  },
  endTime: {
    type: DataTypes.TIME,
    allowNull: true,
    field: 'end_time'
  },
  status: {
    type: DataTypes.ENUM('pending', 'done'),
    defaultValue: 'pending'
  },
  createdAt: {
    type: DataTypes.DATE,
    field: 'created_at'
  },
  updatedAt: {
    type: DataTypes.DATE,
    field: 'updated_at'
  }
}, {
  tableName: 'user_schedules',
  timestamps: false
})

module.exports = Schedule

