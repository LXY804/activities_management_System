const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const Announcement = sequelize.define('Announcement', {
  announcementId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'announcement_id'
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  publisherId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'publisher_id'
  },
  publisherType: {
    type: DataTypes.ENUM('admin', 'organizer'),
    defaultValue: 'admin',
    field: 'publisher_type'
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
  publishedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'published_at'
  }
}, {
  tableName: 'announcements',
  timestamps: false
})

module.exports = Announcement

