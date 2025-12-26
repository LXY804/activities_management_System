const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const AnnouncementConfirmation = sequelize.define('AnnouncementConfirmation', {
  confirmationId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'confirmation_id'
  },
  announcementId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'announcement_id'
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  confirmedAt: {
    type: DataTypes.DATE,
    field: 'confirmed_at'
  }
}, {
  tableName: 'announcement_confirmations',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['announcement_id', 'user_id']
    }
  ]
})

module.exports = AnnouncementConfirmation

