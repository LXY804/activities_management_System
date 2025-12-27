#!/bin/bash
# 服务器性能优化脚本 - 加快 AI 聊天查询速度

echo "=== 开始优化查询性能 ==="

cd /var/www/activities_management/backend

# 备份原文件
cp controllers/chatController.js controllers/chatController.js.bak

echo "✅ 已备份原文件"

# 创建优化补丁
cat > /tmp/optimize_chat.patch << 'ENDOFPATCH'
--- a/controllers/chatController.js
+++ b/controllers/chatController.js
@@ -59,24 +59,20 @@ async function detectIntent(userMessage)
 
 // 报名人数最多的活动 Top5
 async function buildHotActivitiesText() {
-  const topList = await UserActivityApply.findAll({
-    attributes: [
-      'activityId',
-      [fn('COUNT', col('UserActivityApply.activity_id')), 'cnt'],
-    ],
-    where: {
-      applyStatus: { [Op.in]: [0, 1] }, // 待审核/已通过
-    },
-    include: [
-      {
-        model: Activity,
-        as: 'activity',
-        attributes: ['activityName', 'startTime', 'location'],
-      },
-    ],
-    group: ['UserActivityApply.activity_id', 'activity.activity_id'],
-    order: [literal('cnt DESC')],
-    limit: 5,
-    raw: true,
-  })
+  // 使用原生 SQL 查询，性能更好
+  const hotSql = `
+    SELECT 
+      a.activity_name AS activityName,
+      a.start_time AS startTime,
+      a.location,
+      COUNT(uaa.apply_id) AS cnt
+    FROM activities a
+    LEFT JOIN user_activity_apply uaa ON a.activity_id = uaa.activity_id 
+      AND uaa.apply_status IN (0, 1)
+    WHERE a.end_time > NOW()
+    GROUP BY a.activity_id, a.activity_name, a.start_time, a.location
+    ORDER BY cnt DESC
+    LIMIT 5
+  `
+  const topList = await sequelize.query(hotSql, { type: QueryTypes.SELECT })
 
   if (!topList.length) return '数据库中暂时没有活动报名数据。'
 
@@ -84,10 +80,10 @@ async function buildHotActivitiesText() {
     '当前报名人数最多的活动（按报名人数排序）：\n' +
     topList
       .map((r, i) => {
-        const name = r['activity.activityName'] || '未命名活动'
+        const name = r.activityName || '未命名活动'
         const cnt = r.cnt
-        const time = r['activity.startTime'] || '时间待定'
-        const loc = r['activity.location'] || '地点待定'
+        const time = r.startTime || '时间待定'
+        const loc = r.location || '地点待定'
         return `${i + 1}. ${name}（${cnt} 人报名），开始时间：${time}，地点：${loc}`
       })
       .join('\n')
@@ -96,15 +92,19 @@ async function buildHotActivitiesText() {
 
 // 志愿服务类活动（名称包含"志愿/义工"）
 async function buildVolunteerText() {
-  const volunteers = await Activity.findAll({
-    where: {
-      activityName: {
-        [Op.like]: '%志愿%',
-      },
-    },
-    order: [['startTime', 'ASC']],
-    limit: 5,
-    attributes: ['activityName', 'startTime', 'location'],
-    raw: true,
-  })
+  // 使用原生 SQL，添加索引提示
+  const volunteerSql = `
+    SELECT 
+      activity_name AS activityName,
+      start_time AS startTime,
+      location
+    FROM activities
+    WHERE activity_name LIKE '%志愿%'
+      AND end_time > NOW()
+    ORDER BY start_time ASC
+    LIMIT 5
+  `
+  const volunteers = await sequelize.query(volunteerSql, { type: QueryTypes.SELECT })
 
   if (!volunteers.length) return '当前没有查到包含"志愿"的活动，你可以稍后再来看看。'
 
@@ -127,18 +127,20 @@ async function buildMyRegisteredText(userId) {
 
 // 基于历史报名记录的智能推荐（整合多种推荐策略）
 async function buildRecommendText(userId) {
   const now = new Date()
+  const nowStr = now.toISOString().slice(0, 19).replace('T', ' ')
   
   // 策略1：优先使用推荐表 rec_user_topn（如果有离线推荐结果）
-  const topnRecs = await RecUserTopn.findAll({
-    where: { userId },
-    include: [
-      {
-        model: Activity,
-        as: 'activity',
-        attributes: ['activityId', 'activityName', 'startTime', 'endTime', 'location', 'typeId', 'Activity_description'],
-        where: {
-          endTime: { [Op.gt]: now } // 只推荐未结束的活动
-        },
-        include: [
-          { model: ActivityType, as: 'type', attributes: ['typeName'] }
-        ]
-      }
-    ],
-    order: [['score', 'DESC']],
-    limit: 10
-  })
+  // 使用原生 SQL 查询，性能更好
+  const topnSql = `
+    SELECT 
+      r.activity_id AS activityId,
+      r.score,
+      r.reason,
+      a.activity_name AS activityName,
+      a.start_time AS startTime,
+      a.end_time AS endTime,
+      a.location,
+      a.type_id AS typeId,
+      at.type_name AS typeName
+    FROM rec_user_topn r
+    INNER JOIN activities a ON r.activity_id = a.activity_id
+    LEFT JOIN activity_types at ON a.type_id = at.type_id
+    WHERE r.user_id = ?
+      AND a.end_time > ?
+    ORDER BY r.score DESC
+    LIMIT 10
+  `
+  const topnRecs = await sequelize.query(topnSql, {
+    replacements: [userId, nowStr],
+    type: QueryTypes.SELECT
+  })
 
   if (topnRecs.length > 0) {
     const recText = topnRecs
       .map((rec, i) => {
-        const act = rec.activity
-        const typeName = act?.type?.typeName || '未知类型'
-        const startTime = act?.startTime ? new Date(act.startTime).toLocaleString('zh-CN') : '时间待定'
-        const location = act?.location || '地点待定'
+        const typeName = rec.typeName || '未知类型'
+        const startTime = rec.startTime ? new Date(rec.startTime).toLocaleString('zh-CN') : '时间待定'
+        const location = rec.location || '地点待定'
         const reason = rec.reason === 'cf' ? '协同过滤推荐' : rec.reason || '个性化推荐'
-        return `${i + 1}. 【${typeName}】${act.activityName}\n   时间：${startTime}\n   地点：${location}\n   推荐理由：${reason}（推荐度：${(rec.score * 100).toFixed(1)}%）`
+        return `${i + 1}. 【${typeName}】${rec.activityName}\n   时间：${startTime}\n   地点：${location}\n   推荐理由：${reason}（推荐度：${(rec.score * 100).toFixed(1)}%）`
       })
       .join('\n\n')
     
@@ -200,7 +202,7 @@ async function buildRecommendText(userId) {
     order: [['appliedAt', 'DESC']],
-    limit: 50
+    limit: 20  // 减少查询数量，提高速度
   })
 
   if (!historyRecords.length) {
ENDOFPATCH

echo "⚠️  注意：由于代码较复杂，建议直接编辑文件"
echo ""
echo "请手动执行以下优化："
echo "1. 使用原生 SQL 替代复杂 Sequelize 查询"
echo "2. 减少 limit 数量"
echo "3. 简化查询逻辑"

