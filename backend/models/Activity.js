const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Activity = sequelize.define('Activity', {
  activityId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'activity_id'
  },
  activityName: {
    type: DataTypes.STRING(100),
    allowNull: false,
    field: 'activity_name'
  },
  activityCode: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    field: 'activity_code'
  },
  activityDescription: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'Activity_description'
  },
  typeId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'type_id'
  },
  startTime: {
    type: DataTypes.DATE,
    allowNull: false,
    field: 'start_time'
  },
  endTime: {
    type: DataTypes.DATE,
    allowNull: false,
    field: 'end_time'
  },
  location: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  targetCollegeId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'target_college_id'
  },
  capacity: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  organizerId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'organizer_id'
  },
  coverImage: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'cover_image'
  },
  createdAt: {
    type: DataTypes.DATE,
    field: 'created_at'
  }
}, {
  tableName: 'activities',
  timestamps: false
})

module.exports = Activity

