// DeepSeek 大模型客户端封装
// 使用 OpenAI 官方 SDK，指向 DeepSeek 的兼容接口

const OpenAI = require("openai");

// 从环境变量读取 API Key
const apiKey = process.env.DEEPSEEK_API_KEY;
if (apiKey) {
  console.log('[DeepSeek] 读取到的 API Key:', `${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}`);
} else {
  console.error('⚠️  警告: DEEPSEEK_API_KEY 未配置，AI 功能将无法使用');
}

const openai = new OpenAI({
  baseURL: "https://api.deepseek.com",
  apiKey: apiKey || "", // 从环境变量读取，如果未配置则为空字符串
});

/**
 * 与星火 callSpark 保持类似接口：
 * messages: [{ role: 'user' | 'assistant' | 'system', content: string }, ...]
 * 返回：最终回复文本字符串
 */
async function callDeepseek(messages) {
  try {
    const completion = await openai.chat.completions.create({
      model: process.env.DEEPSEEK_MODEL || "deepseek-chat",
      messages,
    });

    const content = completion.choices?.[0]?.message?.content || "";
    return content || "（空响应）";
  } catch (err) {
    // 统一包装一下错误，便于上层查看
    throw new Error(`DeepSeek error: ${err.message || err.toString()}`);
  }
}

module.exports = { callDeepseek };


