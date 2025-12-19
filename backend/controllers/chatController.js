// controllers/chatController.js
const { Op, fn, col, literal } = require('sequelize')
const sequelize = require('../config/database')
const { success, error } = require('../utils/response')
const { callDeepseek } = require('../utils/deepseekClient')
const Message = require('../models/Message')
const Activity = require('../models/Activity')
const UserActivityApply = require('../models/UserActivityApply')

// 关联：报名 -> 活动
UserActivityApply.belongsTo(Activity, { foreignKey: 'activity_id', as: 'activity' })

// ---------- 工具函数：意图识别 ----------

async function detectIntent(userMessage) {
  const messages = [
    {
      role: 'system',
      content: `
你是意图识别助手，只根据用户的问题判断要调用哪一种能力。
只能从下面列表中选择一个 intent，并返回 JSON，不要输出其他文字。

可选 intent:
- "HOT_ACTIVITIES": 用户想知道报名人数最多/最热门的活动
- "VOLUNTEER_LIST": 用户想了解志愿服务/义工相关活动
- "MY_REGISTERED": 用户想查看自己已经报名的活动
- "RECOMMEND_FOR_ME": 用户想基于历史报名获得个性化推荐
- "NONE": 以上都不符合，普通聊天或仅用历史对话回答

返回格式示例（注意必须是合法 JSON）:
{"intent":"HOT_ACTIVITIES","needUserId":false}
{"intent":"RECOMMEND_FOR_ME","needUserId":true}
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

// 基于历史报名类型的推荐
async function buildRecommendText(userId) {
  // 先统计用户最常报名的类型
  const favRecords = await UserActivityApply.findAll({
    attributes: ['activityId'],
    where: {
      userId,
      applyStatus: { [Op.in]: [0, 1] },
    },
    include: [
      { model: Activity, as: 'activity', attributes: ['typeId'] },
    ],
    raw: true,
  })

  if (!favRecords.length) {
    return '你目前还没有报名记录，我暂时无法基于历史给你推荐，可以先告诉我你感兴趣的活动类型。'
  }

  const typeCount = {}
  favRecords.forEach(r => {
    const t = r['activity.typeId']
    if (!t) return
    typeCount[t] = (typeCount[t] || 0) + 1
  })
  const favTypeEntry = Object.entries(typeCount).sort((a, b) => b[1] - a[1])[0]
  if (!favTypeEntry) {
    return '暂时没法确定你偏好的活动类型，可以先告诉我你感兴趣的方向。'
  }
  const favTypeId = favTypeEntry[0]

  // 再找同类型、且用户未报名的活动
  const alreadyActivityIds = favRecords.map(r => r.activityId).filter(Boolean)

  const recList = await Activity.findAll({
    where: {
      typeId: favTypeId,
      ...(alreadyActivityIds.length
        ? { activityId: { [Op.notIn]: alreadyActivityIds } }
        : {}),
    },
    order: [['startTime', 'ASC']],
    limit: 5,
    attributes: ['activityName', 'startTime', 'location'],
    raw: true,
  })

  if (!recList.length) {
    return '目前没有更多同类型的活动可以推荐，你可以尝试其他类型的活动。'
  }

  return (
    '基于你历史报名最常参加的活动类型，为你推荐：\n' +
    recList
      .map((r, i) => {
        const time = r.startTime || '时间待定'
        const loc = r.location || '地点待定'
        return `${i + 1}. ${r.activityName}，开始时间：${time}，地点：${loc}`
      })
      .join('\n')
  )
}

// ---------- 主聊天接口 ----------

exports.chatAsk = async (req, res) => {
  try {
    const { sessionId, userMessage, userId } = req.body
    if (!sessionId || !userMessage) {
      return error(res, 'sessionId 和 userMessage 必须提供', 400)
    }

    // 1) 保存用户消息
    await Message.create({ sessionId, sender: 'user', content: userMessage })

    // 2) 历史消息
    const history = await Message.findAll({
      where: { sessionId },
      order: [['createdAt', 'DESC']],
      limit: 10,
      attributes: ['sender', 'content'],
    })

    // 3) 意图识别
    const { intent, needUserId } = await detectIntent(userMessage)
    console.log('detect intent:', { intent, needUserId })

    let dataText = ''

    // 4) 根据意图查数据库
    if (intent === 'HOT_ACTIVITIES') {
      dataText = await buildHotActivitiesText()
    } else if (intent === 'VOLUNTEER_LIST') {
      dataText = await buildVolunteerText()
    } else if (intent === 'MY_REGISTERED') {
      if (!userId) {
        dataText = '（系统提示：该问题和“我已报名的活动”相关，但当前请求未提供 userId。）'
      } else {
        dataText = await buildMyRegisteredText(userId)
      }
    } else if (intent === 'RECOMMEND_FOR_ME') {
      if (!userId) {
        dataText = '（系统提示：要做个性化推荐，需要提供 userId 才能基于历史报名记录推荐。）'
      } else {
        dataText = await buildRecommendText(userId)
      }
    }

    // 5) 组装最终上下文
    const messages = [
      {
        role: 'system',
        content:
          '你是校园活动管理系统的智能助手。回答时要结合提供的数据（如果有），用简体中文，尽量具体、有条理。',
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
    messages.push({ role: 'user', content: userMessage })

    // 6) 调用 DeepSeek 生成回答
    const botReply = await callDeepseek(messages)

    // 7) 保存机器人回复
    await Message.create({ sessionId, sender: 'bot', content: botReply })

    success(res, { reply: botReply }, 'success')
  } catch (err) {
    console.error('聊天接口错误:', err)
    error(res, err.message || '聊天服务出错', 500)
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