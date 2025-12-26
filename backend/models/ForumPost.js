const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const ForumPost = sequelize.define('ForumPost', {
  postId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'post_id'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  imageUrl: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'image_url'
  },
  categoryId: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    field: 'category_id'
  },
  status: {
    type: DataTypes.TINYINT,
    defaultValue: 0
  },
  adminCheck: {
    type: DataTypes.TINYINT,
    allowNull: true,
    field: 'admin_check'
  },
  checkRemark: {
    type: DataTypes.STRING(500),
    allowNull: true,
    field: 'check_remark'
  },
  checkedBy: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'checked_by'
  },
  checkedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'checked_at'
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
  tableName: 'forum_posts',
  timestamps: false
})

module.exports = ForumPost

