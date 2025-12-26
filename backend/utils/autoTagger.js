// backend/utils/autoTagger.js
const jieba = require('jieba-wasm');
const { TAG_KEYWORDS, ALL_KEYWORDS } = require('./tagRules');

/**
 * 从文本中自动提取标签
 * @param {string} text - 活动标题或描述
 * @returns {string[]} 建议标签数组（去重）
 */
function generateTags(text) {
  if (!text || typeof text !== 'string') return [];

  // 1. 使用 jieba 分词
  const words = jieba.cut(text);

  // 2. 合并原始文本（防止未登录词漏掉，比如“招聘会”不在词典但包含“招聘”）
  const allText = [text, ...words];

  // 3. 匹配关键词
  const matchedTags = new Set();
  for (const segment of allText) {
    for (const [tag, keywords] of Object.entries(TAG_KEYWORDS)) {
      if (keywords.some(kw => segment.includes(kw))) {
        matchedTags.add(tag);
      }
    }
  }

  return Array.from(matchedTags);
}

module.exports = { generateTags };