// DeepSeek 大模型客户端封装
// 使用 OpenAI 官方 SDK，指向 DeepSeek 的兼容接口

const OpenAI = require("openai");

// 在 .env 或系统环境中配置 DEEPSEEK_API_KEY
const openai = new OpenAI({
  baseURL: "https://api.deepseek.com",
  apiKey: "sk-25833b284ac84df4ab7bc85c5cbdb545",
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


