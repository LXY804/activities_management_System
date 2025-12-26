const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const RecUserTopn = sequelize.define('RecUserTopn', {
  userId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    field: 'user_id'
  },
  activityId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    field: 'activity_id'
  },
  score: {
    type: DataTypes.DOUBLE,
    allowNull: false
  },
  reason: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  updatedAt: {
    type: DataTypes.DATE,
    field: 'updated_at'
  }
}, {
  tableName: 'rec_user_topn',
  timestamps: false
})

module.exports = RecUserTopn

