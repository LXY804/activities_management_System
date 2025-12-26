const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const GiftItem = sequelize.define('GiftItem', {
  giftId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'gift_id'
  },
  title: {
    type: DataTypes.STRING(120),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  coverImage: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'cover_image'
  },
  pointsCost: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'points_cost'
  },
  stock: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  deliveryType: {
    type: DataTypes.ENUM('online', 'offline', 'both'),
    defaultValue: 'offline',
    field: 'delivery_type'
  },
  status: {
    type: DataTypes.ENUM('pending', 'active', 'inactive', 'rejected', 'archived'),
    defaultValue: 'pending'
  },
  reviewNote: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'review_note'
  },
  createdBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'created_by'
  },
  approvedBy: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'approved_by'
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
  tableName: 'gift_items',
  timestamps: false
})

module.exports = GiftItem

