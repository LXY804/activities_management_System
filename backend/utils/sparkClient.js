const crypto = require('crypto')      // Node.js加密模块，用于生成签名
const WebSocket = require('ws')       // WebSocket客户端库
const dayjs = require('dayjs')        // 日期处理库（轻量级替代moment.js）
const utc = require('dayjs/plugin/utc') // UTC 插件

dayjs.extend(utc) // 启用 UTC 支持

function getAuthUrl() {
  // 对应星火 X1.5 WebSocket：wss://spark-api.xf-yun.com/v1/x1
  const host = process.env.SPARK_HOST || 'spark-api.xf-yun.com'
  const path = process.env.SPARK_PATH || '/v1/x1'

  // 生成符合RFC 1123格式的UTC时间字符串，如："Tue, 15 Oct 2024 08:30:00 GMT"
  const date = dayjs().utc().format('ddd, DD MMM YYYY HH:mm:ss [GMT]')

  // 构建待签名的原始字符串，包含host、date和请求行
  const signatureOrigin = `host: ${host}\ndate: ${date}\nGET ${path} HTTP/1.1`

  // 使用HMAC-SHA256算法生成签名
  const signatureSha = crypto
    .createHmac('sha256', process.env.SPARK_API_SECRET)  // 创建HMAC实例，使用API密钥作为密钥
    .update(signatureOrigin)                             // 传入待签名字符串
    .digest('base64')                                    // 生成base64编码的签名

  // 构建认证原始字符串，包含API密钥信息
  const authorizationOrigin =
    `api_key="${process.env.SPARK_API_KEY}",algorithm="hmac-sha256",headers="host date request-line",signature="${signatureSha}"`

  // 将认证字符串进行base64编码
  const authorization = Buffer.from(authorizationOrigin).toString('base64')

  // 返回完整的WebSocket URL，包含认证参数
  return `wss://${host}${path}?authorization=${authorization}&date=${encodeURIComponent(date)}&host=${host}`
}

  //主调用函数
  async function callSpark(messages) {
    return new Promise((resolve, reject) => {  // 返回Promise，便于异步调用
      const url = getAuthUrl()                  // 获取带认证的WebSocket URL
      const ws = new WebSocket(url)             // 创建WebSocket连接实例
      let finalText = ''                        // 用于累积最终回复文本
      
      // 设置30秒超时定时器，防止请求卡死
      const timeout = setTimeout(() => {
        reject(new Error('Spark request timeout'))  // 超时则拒绝Promise
        ws.close()                                  // 关闭WebSocket连接
      }, 30000)

      ws.on('open', () => {  // WebSocket连接成功时触发
        // 构建请求载荷（payload）
        const payload = {
          header: { 
            app_id: process.env.SPARK_APP_ID  // 应用ID，从环境变量读取
          },
          parameter: {
            chat: {
              // X1.5 正式版 domain= spark-x （来自官方文档）
              domain: process.env.SPARK_MODEL || 'spark-x',
              temperature: 0.7,  // 温度参数，控制随机性（0-1，越高越随机）
            },
          },
          payload: {
            message: {
              // 转换消息格式，星火API需要的格式
              text: messages.map(m => ({
                role: m.role,      // 角色：'user'（用户）| 'assistant'（助手）| 'system'（系统）
                content: m.content, // 消息内容
              })),
            },
          },
        }
        ws.send(JSON.stringify(payload))  // 发送JSON格式的请求
      })

      ws.on('message', (data) => {  // 收到服务器消息时触发
        const res = JSON.parse(data.toString())  // 解析JSON响应
        
        // 检查响应头中的错误码
        if (res.header.code !== 0) {
          clearTimeout(timeout)  // 清除超时定时器
          // 返回详细的错误信息
          reject(new Error(`Spark error: ${res.header.code} ${res.header.message}`))
          ws.close()  // 关闭连接
          return
        }
        
        // 提取文本选择（星火API可能返回多个choice）
        const choices = res.payload?.choices?.text || []
        // 拼接所有返回的内容片段
        choices.forEach(item => { 
          if (item.content) finalText += item.content 
        })
        
        // 检查是否流式传输结束（status === 2 表示结束）
        if (res.header.status === 2) {
          clearTimeout(timeout)  // 清除超时定时器
          // 返回最终文本，如果为空则返回占位符
          resolve(finalText || '（空响应）')
          ws.close()  // 关闭WebSocket连接
        }
      })

      ws.on('error', (err) => {  // WebSocket发生错误时触发
        clearTimeout(timeout)     // 清除超时定时器
        reject(err)               // 拒绝Promise，传递错误
      })
      
      ws.on('close', () => {      // 连接关闭时触发
        /* no-op */                // 空操作，这里可以添加日志等
      })
    })
  }

  module.exports = { callSpark }  // 导出callSpark函数，供其他模块使用