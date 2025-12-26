const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Comment = sequelize.define('Comment', {
  commentId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'comment_id'
  },
  activityId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'activity_id'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  rating: {
    type: DataTypes.TINYINT,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  createdAt: {
    type: DataTypes.DATE,
    field: 'created_at'
  }
}, {
  tableName: 'activity_comments',
  timestamps: false
})

module.exports = Comment

