const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const ActivityType = sequelize.define('ActivityType', {
  typeId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'type_id'
  },
  typeName: {
    type: DataTypes.STRING(50),
    allowNull: false,
    field: 'type_name'
  },
  description: {
    type: DataTypes.STRING(200),
    allowNull: true
  }
}, {
  tableName: 'activity_types',
  timestamps: false
})

module.exports = ActivityType

