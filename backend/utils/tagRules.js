// backend/utils/tagRules.js

// 预设标签及其关键词（可按需扩展）
const TAG_KEYWORDS = {
  讲座: ['讲座', '演讲', '报告', '分享会', 'talk', 'seminar'],
  竞赛: ['比赛', '竞赛', '大赛', '挑战赛', 'contest', 'competition'],
  学术: ['学术', '科研', '论文', '研究', '课题', '学术会议'],
  文艺: ['文艺', '演出', '音乐会', '话剧', '舞蹈', '展览', '艺术'],
  体育: ['体育', '运动', '篮球', '足球', '跑步', '健身', '比赛'],
  志愿: ['志愿', '公益', '服务', '支教', '环保'],
  招聘: ['招聘', '宣讲会', '实习', '校招', '就业'],
};

// 扁平化所有关键词（用于快速匹配）
const ALL_KEYWORDS = Object.values(TAG_KEYWORDS).flat();

module.exports = { TAG_KEYWORDS, ALL_KEYWORDS };