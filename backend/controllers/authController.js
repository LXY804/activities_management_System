const { User, College } = require('../models')
const bcrypt = require('bcrypt')
const { generateToken } = require('../utils/jwt')
const { success, error } = require('../utils/response')

const SALT_ROUNDS = 10

exports.login = async (req, res) => {
  try {
    const { username, password, role } = req.body

    if (!username || !password) {
      return error(res, '用户名和密码不能为空', 400)
    }

    const user = await User.findOne({
      where: { username },
      attributes: ['userId', 'username', 'password', 'role', 'email', 'phone', 'collegeId']
    })

    // 用户不存在
    if (!user) {
      return error(res, '该用户暂未注册', 401)
    }
    
    // 角色验证
    if (role && user.role !== role) {
      return error(res, '身份验证失败，请选择正确的身份', 403)
    }

    // 密码校验（优先校验哈希；兼容旧的明文密码，验证通过后自动升级为哈希）
    let isMatch = false
    try {
      isMatch = await bcrypt.compare(password, user.password)
    } catch (e) {
      isMatch = false
    }

    // 兼容旧数据：如果数据库里是明文且与输入相同，则视为通过，并自动升级为哈希
    if (!isMatch && password === user.password) {
      isMatch = true
      try {
        const newHash = await bcrypt.hash(password, SALT_ROUNDS)
        await user.update({ password: newHash })
      } catch (e) {
        // 升级失败不影响本次登录
        console.warn('明文密码升级为哈希时出错:', e)
      }
    }

    if (!isMatch) {
      return error(res, '账号或密码错误', 401)
    }

    const token = generateToken({
      userId: user.userId,
      username: user.username,
      role: user.role
    })

    success(
      res,
      {
        token,
        userId: user.userId,
        username: user.username,
        role: user.role
      },
      '登录成功'
    )
  } catch (err) {
    console.error('登录错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.register = async (req, res) => {
  try {
    const { username, phone, password, role, email, collegeId } = req.body
    console.log('注册请求体:', req.body)

    if (!username || !password) {
      return error(res, '请填写用户名和密码', 400)
    }

    if (password.length < 6) {
      return error(res, '密码长度不少于6位', 400)
    }

    // 检查用户名是否存在
    const existing = await User.findOne({
      where: { username }
    })

    if (existing) {
      return error(res, '用户名已存在', 400)
    }

    const allowedRoles = ['student', 'organizer', 'admin']
    const userRole = allowedRoles.includes(role) ? role : 'student'

    // 哈希密码
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS)

    // 创建用户
    const user = await User.create({
      username,
      phone,
      email: email || null,
      collegeId: collegeId || null,
      password: hashedPassword,
      role: userRole
    })

    const token = generateToken({
      userId: user.userId,
      username: user.username,
      role: user.role
    })

    success(
      res,
      {
        token,
        userId: user.userId,
        username: user.username,
        role: user.role
      },
      '注册成功',
      201
    )
  } catch (err) {
    console.error('注册错误:', err)
    error(res, '服务器错误', 500)
  }
}

exports.registerByQuery = (req, res) => {
  req.body = {
    username: req.query.username,
    phone: req.query.phone,
    password: req.query.password,
    role: req.query.role,
    email: req.query.email,
    collegeId: req.query.collegeId
  }
  return exports.register(req, res)
}

exports.getCurrentUser = async (req, res) => {
  try {
    const userId = req.user.id

    const user = await User.findByPk(userId, {
      attributes: [
        'userId',
        ['user_id', 'id'],
        'username',
        'role',
        'email',
        'phone',
        'collegeId',
        ['college_id', 'college_id'],
        'studentId',
        ['student_id', 'student_id'],
        'realName',
        ['real_name', 'real_name'],
        'gender',
        'idType',
        ['id_type', 'id_type'],
        'idNumber',
        ['id_number', 'id_number'],
        'className',
        ['class_name', 'class_name'],
        'image'
      ],
      include: [{
        model: College,
        as: 'college',
        attributes: ['collegeName'],
        required: false
      }]
    })

    if (!user) {
      return error(res, '用户不存在', 404)
    }

    // 格式化返回数据
    const userData = {
      id: user.userId,
      username: user.username,
      role: user.role,
      email: user.email,
      phone: user.phone,
      college_id: user.collegeId,
      student_id: user.studentId,
      real_name: user.realName,
      gender: user.gender,
      id_type: user.idType,
      id_number: user.idNumber,
      class_name: user.className,
      image: user.image,
      college_name: user.college?.collegeName || null
    }

    // 检查用户信息完善度
    const missingFields = []
    if (!user.studentId) missingFields.push('学号')
    if (!user.realName) missingFields.push('真实姓名')
    if (!user.collegeId) missingFields.push('学院')

    // 添加信息完善状态
    userData.profileCompleted = missingFields.length === 0
    userData.missingFields = missingFields

    success(res, userData)
  } catch (err) {
    console.error('获取用户信息错误:', err)
    error(res, '服务器错误', 500)
  }
}




