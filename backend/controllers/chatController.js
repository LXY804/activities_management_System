// controllers/chatController.js
const { Op, fn, col, literal, QueryTypes } = require('sequelize')
const { success, error } = require('../utils/response')
const { callDeepseek } = require('../utils/deepseekClient')
const sequelize = require('../config/database')
// 从 models/index.js 导入，关联关系已在其中定义
const { Message, Activity, UserActivityApply, RecUserTopn, ActivityType } = require('../models')

// ---------- 工具函数：意图识别 ----------

async function detectIntent(userMessage) {
  const messages = [
    {
      role: 'system',
      content: `
你是意图识别助手，只根据用户的问题判断要调用哪一种能力。
只能从下面列表中选择一个 intent，并返回 JSON，不要输出其他文字。

可选 intent:
- "HOT_ACTIVITIES": 用户想知道报名人数最多/最热门的活动（如"热门活动"、"报名最多的活动"）
- "VOLUNTEER_LIST": 用户想了解志愿服务/义工相关活动（如"志愿活动"、"义工活动"）
- "MY_REGISTERED": 用户想查看自己已经报名的活动（如"我报名的活动"、"我的活动"）
- "RECOMMEND_FOR_ME": 用户想获得个性化推荐（如"推荐活动"、"给我推荐"、"有什么活动推荐"、"我想参加活动"、"不知道选什么活动"、"近期有什么活动"、"最近有什么好活动"等）
- "NONE": 以上都不符合，普通聊天或仅用历史对话回答

注意：
- 如果用户询问推荐、想参加活动、不知道选什么等，都选择 "RECOMMEND_FOR_ME"
- "RECOMMEND_FOR_ME" 需要 userId 才能基于历史记录推荐，所以 needUserId 设为 true

返回格式示例（注意必须是合法 JSON）:
{"intent":"HOT_ACTIVITIES","needUserId":false}
{"intent":"RECOMMEND_FOR_ME","needUserId":true}
{"intent":"NONE","needUserId":false}
`,
    },
    { role: 'user', content: userMessage },
  ]

  const raw = await callDeepseek(messages)

  try {
    const start = raw.indexOf('{')
    const end = raw.lastIndexOf('}')
    if (start === -1 || end === -1) return { intent: 'NONE', needUserId: false }
    const jsonStr = raw.slice(start, end + 1)
    const parsed = JSON.parse(jsonStr)
    return {
      intent: parsed.intent || 'NONE',
      needUserId: !!parsed.needUserId,
    }
  } catch (e) {
    console.error('解析意图 JSON 失败:', e)
    return { intent: 'NONE', needUserId: false }
  }
}

// ---------- 工具函数：构造数据文本，给大模型看 ----------

// 报名人数最多的活动 Top5
async function buildHotActivitiesText() {
  const topList = await UserActivityApply.findAll({
    attributes: [
      'activityId',
      [fn('COUNT', col('UserActivityApply.activity_id')), 'cnt'],
    ],
    where: {
      applyStatus: { [Op.in]: [0, 1] }, // 待审核/已通过
    },
    include: [
      {
        model: Activity,
        as: 'activity',
        attributes: ['activityName', 'startTime', 'location'],
      },
    ],
    group: ['UserActivityApply.activity_id', 'activity.activity_id'],
    order: [literal('cnt DESC')],
    limit: 5,
    raw: true,
  })

  if (!topList.length) return '数据库中暂时没有活动报名数据。'

  return (
    '当前报名人数最多的活动（按报名人数排序）：\n' +
    topList
      .map((r, i) => {
        const name = r['activity.activityName'] || '未命名活动'
        const cnt = r.cnt
        const time = r['activity.startTime'] || '时间待定'
        const loc = r['activity.location'] || '地点待定'
        return `${i + 1}. ${name}（${cnt} 人报名），开始时间：${time}，地点：${loc}`
      })
      .join('\n')
  )
}

// 志愿服务类活动（名称包含“志愿/义工”）
async function buildVolunteerText() {
  const volunteers = await Activity.findAll({
    where: {
      activityName: {
        [Op.like]: '%志愿%',
      },
    },
    order: [['startTime', 'ASC']],
    limit: 5,
    attributes: ['activityName', 'startTime', 'location'],
    raw: true,
  })

  if (!volunteers.length) return '当前没有查到包含“志愿”的活动，你可以稍后再来看看。'

  return (
    '近期和“志愿/义工”相关的活动：\n' +
    volunteers
      .map((v, i) => {
        const time = v.startTime || '时间待定'
        const loc = v.location || '地点待定'
        return `${i + 1}. ${v.activityName}，开始时间：${time}，地点：${loc}`
      })
      .join('\n')
  )
}

// 某用户已报名的活动
async function buildMyRegisteredText(userId) {
  const list = await UserActivityApply.findAll({
    where: {
      userId,
      applyStatus: { [Op.in]: [0, 1] }, // 待审核/已通过
    },
    include: [
      {
        model: Activity,
        as: 'activity',
        attributes: ['activityName', 'startTime', 'location'],
      },
    ],
    order: [['appliedAt', 'DESC']],
    limit: 10,
    raw: true,
  })

  if (!list.length) return '你暂时还没有报名任何活动。'

  return (
    '你已经报名的活动：\n' +
    list
      .map((r, i) => {
        const name = r['activity.activityName'] || '未命名活动'
        const time = r['activity.startTime'] || '时间待定'
        const loc = r['activity.location'] || '地点待定'
        const status = r.applyStatus === 1 ? '已通过' : r.applyStatus === 0 ? '待审核' : '其他状态'
        return `${i + 1}. ${name}（${status}），开始时间：${time}，地点：${loc}`
      })
      .join('\n')
  )
}

// 基于历史报名记录的智能推荐（整合多种推荐策略）
async function buildRecommendText(userId) {
  const now = new Date()
  
  // 策略1：优先使用推荐表 rec_user_topn（如果有离线推荐结果）
  let topnRecs = []
  try {
    topnRecs = await RecUserTopn.findAll({
      where: { userId },
      include: [
        {
          model: Activity,
          as: 'activity',
          attributes: ['activityId', 'activityName', 'startTime', 'endTime', 'location', 'typeId', 'Activity_description'],
          where: {
            endTime: { [Op.gt]: now } // 只推荐未结束的活动
          },
          required: false, // 使用 LEFT JOIN，避免活动不存在时查询失败
          include: [
            { model: ActivityType, as: 'type', attributes: ['typeName'], required: false }
          ]
        }
      ],
      order: [['score', 'DESC']],
      limit: 10
    })
  } catch (topnError) {
    console.error('[推荐] 查询推荐表失败:', topnError)
    // 继续使用其他策略
  }

  if (topnRecs.length > 0) {
    const recText = topnRecs
      .map((rec, i) => {
        const act = rec.activity
        const typeName = act?.type?.typeName || '未知类型'
        const startTime = act?.startTime ? new Date(act.startTime).toLocaleString('zh-CN') : '时间待定'
        const location = act?.location || '地点待定'
        const reason = rec.reason === 'cf' ? '协同过滤推荐' : rec.reason || '个性化推荐'
        return `${i + 1}. 【${typeName}】${act.activityName}\n   时间：${startTime}\n   地点：${location}\n   推荐理由：${reason}（推荐度：${(rec.score * 100).toFixed(1)}%）`
      })
      .join('\n\n')
    
    return `基于你的历史报名记录和活动偏好，为你推荐以下活动：\n\n${recText}\n\n这些推荐是基于你过去报名的活动类型、时间偏好等因素智能计算的。`
  }

  // 策略2：基于历史报名记录的多维度分析
  let historyRecords = []
  try {
    historyRecords = await UserActivityApply.findAll({
      where: {
        userId,
        applyStatus: { [Op.in]: [0, 1] }, // 待审核/已通过
      },
      include: [
        {
          model: Activity,
          as: 'activity',
          attributes: ['activityId', 'typeId', 'startTime', 'location', 'activityName'],
          required: false, // 使用 LEFT JOIN，避免活动被删除后查询失败
          include: [
            { model: ActivityType, as: 'type', attributes: ['typeName'], required: false }
          ]
        }
      ],
      order: [['appliedAt', 'DESC']],
      limit: 50
    })
    // 过滤掉活动已被删除的记录
    historyRecords = historyRecords.filter(record => record.activity !== null)
  } catch (historyError) {
    console.error('[推荐] 查询历史报名记录失败:', historyError)
    // 继续使用热门活动推荐
  }

  if (!historyRecords.length) {
    // 策略3：新用户推荐热门活动（使用原始SQL查询，因为需要聚合）
    const hotActivitiesSql = `
      SELECT 
        a.activity_id AS activityId,
        a.activity_name AS activityName,
        a.start_time AS startTime,
        a.end_time AS endTime,
        a.location,
        a.type_id AS typeId,
        a.Activity_description,
        at.type_name AS typeName,
        COUNT(uaa.apply_id) AS applyCount
      FROM activities a
      LEFT JOIN user_activity_apply uaa ON a.activity_id = uaa.activity_id 
        AND uaa.apply_status IN (0, 1)
      LEFT JOIN activity_types at ON a.type_id = at.type_id
      WHERE a.end_time > NOW()
      GROUP BY a.activity_id, a.activity_name, a.start_time, a.end_time, a.location, a.type_id, a.Activity_description, at.type_name
      ORDER BY applyCount DESC
      LIMIT 8
    `
    
    const hotActivitiesRaw = await sequelize.query(hotActivitiesSql, {
      type: QueryTypes.SELECT
    })
    
    // 转换为类似 Sequelize 模型的格式
    const hotActivities = hotActivitiesRaw.map(row => ({
      activityId: row.activityId,
      activityName: row.activityName,
      startTime: row.startTime,
      endTime: row.endTime,
      location: row.location,
      typeId: row.typeId,
      Activity_description: row.Activity_description,
      type: row.typeName ? { typeName: row.typeName } : null
    }))

    if (hotActivities.length > 0) {
      const hotText = hotActivities
        .map((act, i) => {
          const typeName = act.type?.typeName || '未知类型'
          const startTime = act.startTime ? new Date(act.startTime).toLocaleString('zh-CN') : '时间待定'
          const location = act.location || '地点待定'
          return `${i + 1}. 【${typeName}】${act.activityName}\n   时间：${startTime}\n   地点：${location}`
        })
        .join('\n\n')
      
      return `你目前还没有报名记录。为你推荐当前最热门的活动：\n\n${hotText}\n\n可以先尝试参加这些活动，系统会根据你的参与情况为你提供更精准的个性化推荐。`
    }

    return '你目前还没有报名记录，且当前没有可推荐的活动。可以先告诉我你感兴趣的活动类型，我会为你推荐相关活动。'
  }

  // 分析用户偏好
  const typeCount = {}
  const locationCount = {}
  const timePreferences = { weekday: 0, weekend: 0, morning: 0, afternoon: 0, evening: 0 }
  const alreadyActivityIds = []

  historyRecords.forEach(record => {
    const act = record.activity
    if (!act) return

    alreadyActivityIds.push(act.activityId)

    // 统计类型偏好
    if (act.typeId) {
      typeCount[act.typeId] = (typeCount[act.typeId] || 0) + 1
    }

    // 统计地点偏好
    if (act.location) {
      locationCount[act.location] = (locationCount[act.location] || 0) + 1
    }

    // 统计时间偏好
    if (act.startTime) {
      const startDate = new Date(act.startTime)
      const dayOfWeek = startDate.getDay()
      const hour = startDate.getHours()

      if (dayOfWeek === 0 || dayOfWeek === 6) {
        timePreferences.weekend++
      } else {
        timePreferences.weekday++
      }

      if (hour < 12) timePreferences.morning++
      else if (hour < 18) timePreferences.afternoon++
      else timePreferences.evening++
    }
  })

  // 获取最偏好的类型
  const topTypes = Object.entries(typeCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([typeId]) => Number(typeId))

  // 获取最偏好的地点
  const topLocations = Object.entries(locationCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([location]) => location)

  // 构建推荐查询条件
  const whereConditions = {
    endTime: { [Op.gt]: now },
    activityId: { [Op.notIn]: alreadyActivityIds }
  }

  // 优先推荐同类型活动
  if (topTypes.length > 0) {
    whereConditions.typeId = { [Op.in]: topTypes }
  }

  // 查找推荐活动
  let recList = await Activity.findAll({
    where: whereConditions,
    include: [
      { model: ActivityType, as: 'type', attributes: ['typeName'] }
    ],
    order: [['startTime', 'ASC']],
    limit: 10,
    attributes: ['activityId', 'activityName', 'startTime', 'endTime', 'location', 'typeId', 'Activity_description']
  })

  // 如果同类型活动不够，补充其他类型
  if (recList.length < 5 && topTypes.length > 0) {
    const additionalRecs = await Activity.findAll({
      where: {
        endTime: { [Op.gt]: now },
        activityId: { [Op.notIn]: [...alreadyActivityIds, ...recList.map(a => a.activityId)] },
        typeId: { [Op.notIn]: topTypes }
      },
      include: [
        { model: ActivityType, as: 'type', attributes: ['typeName'] }
      ],
      order: [['startTime', 'ASC']],
      limit: 5 - recList.length,
      attributes: ['activityId', 'activityName', 'startTime', 'endTime', 'location', 'typeId', 'Activity_description']
    })
    recList = [...recList, ...additionalRecs]
  }

  if (recList.length === 0) {
    return '目前没有更多符合你偏好的活动可以推荐，你可以尝试其他类型的活动。'
  }

  // 构建推荐文本
  const typeName = topTypes.length > 0 
    ? (await ActivityType.findByPk(topTypes[0]))?.typeName || '你常参加的类型'
    : '各类活动'

  const preferenceInfo = []
  if (topTypes.length > 0) {
    preferenceInfo.push(`你常参加"${typeName}"类型的活动`)
  }
  if (topLocations.length > 0) {
    preferenceInfo.push(`你常去"${topLocations[0]}"参加活动`)
  }
  if (timePreferences.weekend > timePreferences.weekday) {
    preferenceInfo.push('你更偏好周末参加活动')
  }

  const recText = recList
    .slice(0, 8)
    .map((act, i) => {
      const actTypeName = act.type?.typeName || '未知类型'
      const startTime = act.startTime ? new Date(act.startTime).toLocaleString('zh-CN') : '时间待定'
      const location = act.location || '地点待定'
      const matchReasons = []
      
      if (topTypes.includes(act.typeId)) {
        matchReasons.push('类型匹配')
      }
      if (topLocations.includes(act.location)) {
        matchReasons.push('地点匹配')
      }
      
      const reasonText = matchReasons.length > 0 ? `（${matchReasons.join('、')}）` : ''
      
      return `${i + 1}. 【${actTypeName}】${act.activityName}${reasonText}\n   时间：${startTime}\n   地点：${location}`
    })
    .join('\n\n')

  const preferenceText = preferenceInfo.length > 0 
    ? `根据你的历史报名记录分析：${preferenceInfo.join('；')}。\n\n`
    : ''

  return `基于你的历史报名记录，为你推荐以下活动：\n\n${preferenceText}${recText}\n\n这些推荐是基于你过去报名的活动类型、地点偏好等因素智能匹配的。`
}

// ---------- 主聊天接口 ----------

exports.chatAsk = async (req, res) => {
  try {
    const { sessionId, userMessage, userId } = req.body
    if (!sessionId || !userMessage) {
      return error(res, 'sessionId 和 userMessage 必须提供', 400)
    }

    // 确保 userMessage 是字符串
    let messageContent = userMessage
    if (typeof userMessage !== 'string') {
      console.warn('[聊天] userMessage 不是字符串，类型:', typeof userMessage, '值:', userMessage)
      // 如果是对象，尝试转换为字符串
      if (userMessage && typeof userMessage === 'object') {
        messageContent = JSON.stringify(userMessage)
      } else {
        messageContent = String(userMessage || '')
      }
    }
    
    // 确保消息内容不为空
    messageContent = messageContent.trim()
    if (!messageContent) {
      return error(res, '消息内容不能为空', 400)
    }

    // 1) 保存用户消息
    await Message.create({ sessionId, sender: 'user', content: messageContent })

    // 2) 历史消息
    const history = await Message.findAll({
      where: { sessionId },
      order: [['createdAt', 'DESC']],
      limit: 10,
      attributes: ['sender', 'content'],
    })

    // 3) 意图识别（使用处理后的消息内容）
    const { intent, needUserId } = await detectIntent(messageContent)
    console.log('detect intent:', { intent, needUserId })

    let dataText = ''

    // 4) 根据意图查数据库
    try {
      if (intent === 'HOT_ACTIVITIES') {
        dataText = await buildHotActivitiesText()
      } else if (intent === 'VOLUNTEER_LIST') {
        dataText = await buildVolunteerText()
      } else if (intent === 'MY_REGISTERED') {
        if (!userId) {
          dataText = '（系统提示：该问题和"我已报名的活动"相关，但当前请求未提供 userId。）'
        } else {
          dataText = await buildMyRegisteredText(userId)
        }
      } else if (intent === 'RECOMMEND_FOR_ME') {
        if (!userId) {
          // 未登录用户，推荐热门活动
          console.log('[推荐] 用户未登录，使用热门活动推荐')
          try {
            const hotText = await buildHotActivitiesText()
            dataText = `（系统提示：由于无法获取用户的历史报名记录，无法进行个性化推荐。已提供当前热门活动列表。请自然地告诉用户这些是当前热门的活动，并建议用户登录后可以获得基于历史记录的个性化推荐。）\n\n当前热门活动列表：\n${hotText}`
          } catch (hotError) {
            console.error('[推荐] 获取热门活动失败:', hotError)
            dataText = '（系统提示：查询热门活动时遇到问题，请稍后再试。）'
          }
        } else {
          console.log('[推荐] 开始为用户推荐活动，userId:', userId)
          try {
            dataText = await buildRecommendText(userId)
            console.log('[推荐] 推荐结果长度:', dataText?.length || 0)
          } catch (recError) {
            console.error('[推荐] 个性化推荐失败:', recError)
            console.error('[推荐] 错误堆栈:', recError.stack)
            // 如果个性化推荐失败，尝试使用热门活动作为备选
            try {
              const hotText = await buildHotActivitiesText()
              dataText = `（系统提示：个性化推荐遇到问题，已提供当前热门活动列表。）\n\n当前热门活动列表：\n${hotText}`
            } catch (hotError) {
              console.error('[推荐] 备选热门活动也失败:', hotError)
              dataText = '（系统提示：查询推荐活动时遇到问题，请稍后再试或联系管理员。）'
            }
          }
        }
      }
    } catch (dbError) {
      console.error('[推荐] 数据库查询错误:', dbError)
      console.error('[推荐] 错误堆栈:', dbError.stack)
      // 如果数据库查询失败，至少返回一个友好的提示
      if (intent === 'RECOMMEND_FOR_ME') {
        dataText = '（系统提示：查询推荐活动时遇到问题，请稍后再试或联系管理员。）'
      } else {
        dataText = '（系统提示：查询数据时遇到问题，请稍后再试。）'
      }
    }

    // 5) 组装最终上下文
    // 获取当前时间信息（使用中国时区）
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    const hours = String(now.getHours()).padStart(2, '0')
    const minutes = String(now.getMinutes()).padStart(2, '0')
    const seconds = String(now.getSeconds()).padStart(2, '0')
    
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const weekday = weekdays[now.getDay()]
    
    const months = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月']
    const monthName = months[now.getMonth()]
    
    // 格式化的时间字符串
    const currentDateStr = `${year}年${month}月${day}日（${weekday}）`
    const currentTimeStr = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
    const currentDateTimeStr = `${year}年${monthName}${day}日 ${weekday} ${hours}:${minutes}`

    const messages = [
      {
        role: 'system',
        content:
          `你是校园活动管理系统的智能助手，名字叫做"小活"。你的核心能力是根据用户的历史报名记录智能推荐活动，同时也能回答其他问题。

【重要】当前实时时间信息（请务必使用此时间，不要使用训练数据中的时间）：
- 当前日期：${currentDateStr}
- 完整时间：${currentDateTimeStr}
- 标准格式：${currentTimeStr}
- 时区：中国标准时间（UTC+8）

⚠️ 时间回答规则：
1. 当用户询问"今天几月几号"、"现在几点了"、"今天是星期几"等时间问题时，必须使用上述当前时间信息回答。
2. 不要使用训练数据中的时间，必须使用上面提供的实时时间。
3. 回答时间问题时，格式示例："今天是 ${currentDateStr}，现在是 ${hours}:${minutes}。"

🎯 推荐功能说明：
1. **核心能力**：你拥有用户的历史报名记录数据库，能够基于用户的报名历史智能推荐活动。
2. **推荐策略**：
   - 如果提供了推荐数据，优先使用推荐数据回答（这些数据是基于用户历史报名记录、活动类型偏好、时间偏好等因素智能计算的）
   - 推荐数据包含活动名称、类型、时间、地点、推荐理由等信息
   - 推荐时会说明推荐理由（如"类型匹配"、"地点匹配"等）
3. **主动推荐**：
   - 当用户询问"有什么活动推荐"、"给我推荐一些活动"、"我想参加活动"等类似问题时，使用提供的推荐数据回答
   - 如果用户询问"近期有什么活动"、"最近有什么好活动"等，也可以结合推荐数据主动推荐
   - 如果用户没有明确要求推荐，但对话中提到了想参加活动、不知道选什么活动等，也可以主动推荐
4. **回答格式**：
   - 推荐活动时，要清晰地列出活动信息（名称、类型、时间、地点）
   - 说明推荐理由（如"基于你常参加XX类型的活动"）
   - 语气要友好、自然，像朋友推荐一样
   - 可以适当使用表情符号让回答更生动

💡 其他功能：
- 可以回答关于活动的问题（热门活动、志愿服务、已报名活动等）
- 可以回答时间、日期相关问题
- 可以正常聊天对话

回答时要结合提供的数据（如果有），用简体中文，尽量具体、有条理、友好自然。`,
      },
    ]

    if (dataText) {
      messages.push({
        role: 'assistant',
        content: `以下是从数据库查询到的相关数据，请结合这些数据回答用户：\n${dataText}`,
      })
    }

    history.reverse().forEach(m => {
      messages.push({
        role: m.sender === 'user' ? 'user' : 'assistant',
        content: m.content,
      })
    })
    messages.push({ role: 'user', content: messageContent })

    // 6) 调用 DeepSeek 生成回答
    console.log('[聊天] 准备调用 DeepSeek，消息数量:', messages.length)
    const botReply = await callDeepseek(messages)
    console.log('[聊天] DeepSeek 返回长度:', botReply?.length || 0)

    // 7) 保存机器人回复
    await Message.create({ sessionId, sender: 'bot', content: botReply })

    success(res, { reply: botReply }, 'success')
  } catch (err) {
    console.error('聊天接口错误:', err)
    console.error('错误堆栈:', err.stack)
    // 返回更详细的错误信息（仅用于调试，生产环境可以简化）
    const errorMessage = process.env.NODE_ENV === 'production' 
      ? '聊天服务出错，请稍后再试' 
      : err.message || '聊天服务出错'
    error(res, errorMessage, 500)
  }
}

// ---------- 历史接口保持不变 ----------

exports.getChatHistory = async (req, res) => {
  try {
    const { sessionId, limit = 20 } = req.query
    if (!sessionId) return error(res, 'sessionId 必须提供', 400)

    const messages = await Message.findAll({
      where: { sessionId },
      order: [['createdAt', 'ASC']],
      limit: Number(limit),
      attributes: ['id', 'sessionId', 'sender', 'content', 'createdAt'],
    })

    success(res, { messages }, 'success')
  } catch (err) {
    console.error('获取历史消息错误:', err)
    error(res, '获取历史消息失败', 500)
  }
}