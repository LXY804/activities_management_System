const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const College = sequelize.define('College', {
  collegeId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'college_id'
  },
  collegeName: {
    type: DataTypes.STRING(100),
    allowNull: false,
    field: 'college_name'
  },
  collegeCode: {
    type: DataTypes.STRING(20),
    allowNull: false,
    unique: true,
    field: 'college_code'
  }
}, {
  tableName: 'colleges',
  timestamps: false
})

module.exports = College

