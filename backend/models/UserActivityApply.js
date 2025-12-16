const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const UserActivityApply = sequelize.define(
  'UserActivityApply',
  {
    applyId: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, field: 'apply_id' },
    userId: { type: DataTypes.INTEGER, field: 'user_id' },
    activityId: { type: DataTypes.INTEGER, field: 'activity_id' },
    applyStatus: { type: DataTypes.TINYINT, field: 'apply_status' },
    appliedAt: { type: DataTypes.DATE, field: 'applied_at' },
  },
  {
    tableName: 'user_activity_apply',
    timestamps: false,
  }
)

module.exports = UserActivityApply

