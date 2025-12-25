const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const News = sequelize.define('News', {
  newsId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'news_id'
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
  publisherId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'publisher_id'
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
  tableName: 'news',
  timestamps: false
})

module.exports = News

