const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const OrganizerActivityCreation = sequelize.define('OrganizerActivityCreation', {
  creationId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'creation_id'
  },
  organizerId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'organizer_id'
  },
  activityId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'activity_id'
  },
  createdAt: {
    type: DataTypes.DATE,
    field: 'created_at'
  },
  adminCheck: {
    type: DataTypes.TINYINT,
    defaultValue: 0,
    field: 'admin_check'
  },
  checkRemark: {
    type: DataTypes.STRING(200),
    allowNull: true,
    field: 'check_remark'
  }
}, {
  tableName: 'organizer_activity_creation',
  timestamps: false
})

module.exports = OrganizerActivityCreation

