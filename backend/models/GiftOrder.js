const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const GiftOrder = sequelize.define('GiftOrder', {
  orderId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'order_id'
  },
  giftId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'gift_id'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  },
  totalPoints: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'total_points'
  },
  status: {
    type: DataTypes.ENUM('pending', 'processing', 'shipped', 'received', 'cancelled'),
    defaultValue: 'pending'
  },
  contactName: {
    type: DataTypes.STRING(80),
    allowNull: true,
    field: 'contact_name'
  },
  contactPhone: {
    type: DataTypes.STRING(30),
    allowNull: true,
    field: 'contact_phone'
  },
  deliveryMethod: {
    type: DataTypes.ENUM('online', 'offline'),
    defaultValue: 'offline',
    field: 'delivery_method'
  },
  pickupLocation: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'pickup_location'
  },
  note: {
    type: DataTypes.STRING(255),
    allowNull: true
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
  tableName: 'gift_orders',
  timestamps: false
})

module.exports = GiftOrder

