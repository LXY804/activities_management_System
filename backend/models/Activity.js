const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Activity = sequelize.define(
  'Activity',
  {
    activityId: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, field: 'activity_id' },
    activityName: { type: DataTypes.STRING, field: 'activity_name' },
    activityCode: { type: DataTypes.STRING, field: 'activity_code' },
    typeId: { type: DataTypes.INTEGER, field: 'type_id' },
    startTime: { type: DataTypes.DATE, field: 'start_time' },
    endTime: { type: DataTypes.DATE, field: 'end_time' },
    capacity: { type: DataTypes.INTEGER, field: 'capacity' },
  },
  {
    tableName: 'activities',
    timestamps: false,
  }
)

module.exports = Activity

