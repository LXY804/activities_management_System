// test-jieba.js
const jieba = require('jieba-wasm');

// 初始化（首次调用会加载 WASM，稍慢）
const result = jieba.cut('欢迎参加校园活动管理系统开发');

console.log('✅ 分词成功！');
console.log('结果:', result);