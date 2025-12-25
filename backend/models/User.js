const { DataTypes } = require('sequelize')
const sequelize = require('../config/database')

const User = sequelize.define('User', {
  userId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    field: 'user_id'
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('student', 'organizer', 'admin'),
    defaultValue: 'student'
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  collegeId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'college_id'
  },
  createdAt: {
    type: DataTypes.DATE,
    field: 'created_at'
  },
  studentId: {
    type: DataTypes.STRING(50),
    allowNull: true,
    field: 'student_id'
  },
  realName: {
    type: DataTypes.STRING(50),
    allowNull: true,
    field: 'real_name'
  },
  gender: {
    type: DataTypes.ENUM('男', '女', '其他'),
    allowNull: true
  },
  idType: {
    type: DataTypes.STRING(20),
    allowNull: true,
    field: 'id_type'
  },
  idNumber: {
    type: DataTypes.STRING(50),
    allowNull: true,
    field: 'id_number'
  },
  className: {
    type: DataTypes.STRING(100),
    allowNull: true,
    field: 'class_name'
  },
  image: {
    type: DataTypes.STRING(200),
    allowNull: true
  }
}, {
  tableName: 'users',
  timestamps: false
})

module.exports = User

