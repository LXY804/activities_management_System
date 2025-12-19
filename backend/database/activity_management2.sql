/*
 Navicat Premium Data Transfer

 Source Server         : APP
 Source Server Type    : MySQL
 Source Server Version : 80040
 Source Host           : localhost:3306
 Source Schema         : activity_management2

 Target Server Type    : MySQL
 Target Server Version : 80040
 File Encoding         : 65001

 Date: 16/12/2025 19:43:00
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for activities
-- ----------------------------
DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities`  (
  `activity_id` int NOT NULL AUTO_INCREMENT,
  `activity_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `activity_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `Activity_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `type_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_college_id` int NULL DEFAULT NULL,
  `capacity` int NOT NULL,
  `organizer_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `cover_image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `points` int NOT NULL DEFAULT 0 COMMENT '活动积分',
  PRIMARY KEY (`activity_id`) USING BTREE,
  UNIQUE INDEX `activity_code`(`activity_code` ASC) USING BTREE,
  INDEX `type_id`(`type_id` ASC) USING BTREE,
  INDEX `target_college_id`(`target_college_id` ASC) USING BTREE,
  INDEX `organizer_id`(`organizer_id` ASC) USING BTREE,
  INDEX `idx_start_time`(`start_time` ASC) USING BTREE,
  INDEX `idx_type_start`(`type_id` ASC, `start_time` ASC) USING BTREE,
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `activity_types` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activities_ibfk_2` FOREIGN KEY (`target_college_id`) REFERENCES `colleges` (`college_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activities_ibfk_3` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of activities
-- ----------------------------
INSERT INTO `activities` VALUES (1, 'AI技术讲座', 'ACT001', '邀请知名专家讲解人工智能最新技术发展', 2, '2025-12-09 14:00:00', '2024-12-11 14:00:00', '大礼堂', 1, 200, 6, '2025-12-02 21:57:37', 'uploads\\fbd146228157e894c10fa56bd950c829.jpg', 3);
INSERT INTO `activities` VALUES (2, '编程大赛', 'ACT002', '面向全校学生的编程竞赛活动', 3, '2025-12-09 09:00:00', '2025-12-11 17:00:00', '计算机楼', NULL, 100, 6, '2025-12-02 21:57:37', NULL, 5);
INSERT INTO `activities` VALUES (3, '新年音乐会', 'ACT003', '迎接新年的音乐演出活动', 4, '2025-12-09 19:00:00', '2025-12-11 21:00:00', '音乐厅', NULL, 500, 6, '2025-12-02 21:57:37', 'uploads\\97a156b9e419b7ca5ac3e231825b6022.jpg', 6);
INSERT INTO `activities` VALUES (4, '武汉市消防比武志愿者招募', 'ACT004', '配合消防员裁判开展场内赛事引导及相关辅助工作', 1, '2025-12-08 11:17:19', '2025-12-11 14:17:22', '南湖操场', NULL, 10, 6, '2025-12-03 11:17:58', 'uploads\\c66a4da9d515a6487722b04c7a29333b.jpg\"', 5);
INSERT INTO `activities` VALUES (5, '“百年五四，精神永存”马研年终特色活动', 'ACT005', '本次活动将通过五四历史回顾、精神内涵解读、交流研讨等形式，带领大家重温五四岁月，深刻感悟五四精神的时代价值，进一步激发成员的责任与担当，为年度学习工作画上圆满句号。', 7, '2025-12-08 11:19:42', '2025-12-11 11:19:45', '学海楼510教室', NULL, 45, 6, '2025-12-03 11:20:14', 'uploads\\44ef742eb72016659bb41ef9340efb01.jpg', 5);
INSERT INTO `activities` VALUES (6, '奔跑吧，武理”撕名牌校园娱乐活动', 'ACT006', '为了丰富同学们的校园生活，经济学院与信息学院，计算机学院，外国语学院联合举办“奔跑吧，武理”校园娱乐活动。', 7, '2025-12-08 11:21:17', '2025-12-11 11:21:24', '南湖操场', NULL, 50, 6, '2025-12-03 11:21:56', 'uploads\\dada3100a60e5266bd7457481cc12204.jpg', 5);
INSERT INTO `activities` VALUES (7, '闻桂香，写心声——武汉理工大学问渠文学社“桂枝香”征文活动', 'ACT007', '桂子月中落，天香云外飘。”当理工的严谨遇上文学的浪漫，当深秋的桂香浸润笔墨的温度，一场属于武理学子的文字盛宴已悄然酝酿——这份以“桂枝香”为名的邀约，正等待热爱文学的你赴约。', 7, '2025-12-09 11:23:23', '2025-12-11 11:23:26', '南湖图书馆', NULL, 0, 6, '2025-12-03 11:24:16', 'uploads\\9f1bc778038e51b150fa88c253bbafcb.jpg', 5);
INSERT INTO `activities` VALUES (8, '猫捉老鼠”校园娱乐活动', 'ACT008', '参与的同学根据自己的猫鼠角色抽签情况，使用高德地图等软件分别进行抓捕和躲藏的行动（所有人位置信息共享，头像使用猫或鼠的两种共享头像）如规定时间内所有老鼠全部被抓则猫阵营获胜，反之鼠阵营获胜。具体规则比赛开始前在QQ群内发布。', 7, '2025-12-09 11:25:23', '2025-12-11 11:25:29', '南湖校区', NULL, 50, 6, '2025-12-03 11:25:51', 'uploads\\714cf734c5a96941b5d8115c7cc48aad.jpg', 5);
INSERT INTO `activities` VALUES (9, '寒假母校行', 'ACT009', '', 1, '2025-12-03 12:27:00', '2025-12-05 12:27:00', '', NULL, 0, 6, '2025-12-03 12:27:18', NULL, 5);
INSERT INTO `activities` VALUES (10, '1', 'ACT010', '', 2, '2025-12-03 12:33:00', '2025-12-11 12:33:00', '', NULL, 0, 6, '2025-12-03 12:34:00', NULL, 5);
INSERT INTO `activities` VALUES (11, '心晴游园会', 'ACT011', '\r\n步履匆匆的日子里\r\n\r\n我们总在追逐远方\r\n\r\n却常忘了留一份温柔给自己\r\n\r\n在一年一度的大学生心理健康节来临之际，\r\n\r\n学工部心理健康教育中心携手\r\n\r\n图书馆、校心协、各学院心协分会\r\n\r\n及华中师范大学心协\r\n\r\n于12月7日（本周日）14：30\r\n\r\n带着满满的诚意和惊喜向大家奔赴而来\r\n\r\n邀请WUTers暂歇脚步，与自己对话，\r\n\r\n开启这场治愈的爱己之旅！\r\n\r\n', 7, '2025-12-07 14:00:00', '2025-12-07 16:00:00', '南湖校区博学广场', NULL, 0, 6, '2025-12-03 13:59:17', 'uploads\\cover_1764741557423_9dve88.png', 5);
INSERT INTO `activities` VALUES (12, '心晴游园会', 'ACT012', '步履匆匆的日子里\r\n\r\n我们总在追逐远方\r\n\r\n却常忘了留一份温柔给自己\r\n\r\n在一年一度的大学生心理健康节来临之际，\r\n\r\n学工部心理健康教育中心携手\r\n\r\n图书馆、校心协、各学院心协分会\r\n\r\n及华中师范大学心协\r\n\r\n于12月7日（本周日）14：30\r\n\r\n带着满满的诚意和惊喜向大家奔赴而来\r\n\r\n邀请WUTers暂歇脚步，与自己对话，\r\n\r\n开启这场治愈的爱己之旅！\r\n\r\n', 7, '2025-12-07 14:30:00', '2025-12-07 16:30:00', '南湖校区博学广场', NULL, 0, 6, '2025-12-03 14:05:33', 'uploads\\cover_1764741557423_9dve88.png', 5);
INSERT INTO `activities` VALUES (13, '前沿人工智能技术分享会', 'ACT013', '邀请计算机学院教师与企业工程师，分享大模型、自动驾驶等最新 AI 应用案例，现场答疑。', 2, '2025-12-03 16:01:00', '2025-12-05 16:01:00', '', NULL, 0, 6, '2025-12-03 16:01:31', NULL, 5);
INSERT INTO `activities` VALUES (14, '1', 'ACT014', '', 2, '2025-12-03 17:17:00', '2025-12-05 17:17:00', '', NULL, 0, 6, '2025-12-03 17:18:02', NULL, 5);
INSERT INTO `activities` VALUES (24, '环湖夜跑', 'ACT024', '5km 打卡，配速友好，新手可跟领跑员，完赛赠夜跑贴纸与补给。', 7, '2025-12-17 19:30:00', '2025-12-17 21:00:00', '东湖绿道', NULL, 120, 6, '2025-12-08 20:19:14', NULL, 5);
INSERT INTO `activities` VALUES (25, '无人机航拍体验', 'ACT025', '基础操控教学、安全规范与航拍演示，教练一对一指导，提供练习机。', 3, '2025-12-24 10:00:00', '2025-12-24 12:00:00', '操场东侧', NULL, 40, 6, '2025-12-08 20:19:14', NULL, 5);

-- ----------------------------
-- Table structure for activity_comments
-- ----------------------------
DROP TABLE IF EXISTS `activity_comments`;
CREATE TABLE `activity_comments`  (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `activity_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` tinyint NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `activity_id`(`activity_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_activity_created`(`activity_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_user_created`(`user_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `activity_comments_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of activity_comments
-- ----------------------------
INSERT INTO `activity_comments` VALUES (5, 1, 3, '讲座内容非常精彩，受益匪浅！', 5, '2025-12-02 22:01:23');
INSERT INTO `activity_comments` VALUES (6, 2, 3, '比赛组织得很好，题目有挑战性。', 4, '2025-12-02 22:01:23');
INSERT INTO `activity_comments` VALUES (7, 1, 2, '好', 5, '2025-12-03 11:03:58');

-- ----------------------------
-- Table structure for activity_types
-- ----------------------------
DROP TABLE IF EXISTS `activity_types`;
CREATE TABLE `activity_types`  (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `type_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of activity_types
-- ----------------------------
INSERT INTO `activity_types` VALUES (1, '志愿', '1');
INSERT INTO `activity_types` VALUES (2, '学术讲座', '专家讲座、学术报告等活动');
INSERT INTO `activity_types` VALUES (3, '科技竞赛', '编程比赛、创新大赛等竞赛活动');
INSERT INTO `activity_types` VALUES (4, '文艺演出', '音乐会、话剧、舞蹈等演出活动');
INSERT INTO `activity_types` VALUES (5, '体育比赛', '各类体育竞赛活动');
INSERT INTO `activity_types` VALUES (6, '志愿服务', '社会公益、志愿服务等活动');
INSERT INTO `activity_types` VALUES (7, '社团活动', '社团内部建设、培训等活动');

-- ----------------------------
-- Table structure for colleges
-- ----------------------------
DROP TABLE IF EXISTS `colleges`;
CREATE TABLE `colleges`  (
  `college_id` int NOT NULL AUTO_INCREMENT,
  `college_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `college_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`college_id`) USING BTREE,
  UNIQUE INDEX `college_code`(`college_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of colleges
-- ----------------------------
INSERT INTO `colleges` VALUES (1, '计算机科学与技术学院', 'CS');
INSERT INTO `colleges` VALUES (2, '机械工程学院', 'ME');
INSERT INTO `colleges` VALUES (3, '电气工程学院', 'EE');
INSERT INTO `colleges` VALUES (4, '商学院', 'BUS');
INSERT INTO `colleges` VALUES (5, '外国语学院', 'FL');
INSERT INTO `colleges` VALUES (6, '法学院', 'LAW');

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sender` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_session_created`(`session_id` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES (1, 'demo-session-1', 'user', '今天几月几号？', '2025-12-16 15:17:32');
INSERT INTO `messages` VALUES (2, 'demo-session-1', 'user', '？', '2025-12-16 15:17:37');
INSERT INTO `messages` VALUES (3, 'demo-session-1', 'user', '今天几月几号？', '2025-12-16 15:18:40');
INSERT INTO `messages` VALUES (4, 'demo-session-1', 'user', '？', '2025-12-16 15:19:06');
INSERT INTO `messages` VALUES (5, 'demo-session-1', 'user', '？', '2025-12-16 15:21:32');
INSERT INTO `messages` VALUES (6, 'demo-session-1', 'user', '？', '2025-12-16 15:28:27');
INSERT INTO `messages` VALUES (7, 'demo-session-1', 'user', '？', '2025-12-16 15:28:37');
INSERT INTO `messages` VALUES (8, 'demo-session-1', 'user', '？', '2025-12-16 15:31:50');
INSERT INTO `messages` VALUES (9, 'demo-session-1', 'user', '？', '2025-12-16 15:35:35');
INSERT INTO `messages` VALUES (10, 'demo-session-1', 'bot', '抱歉呀，我没办法直接告诉你今天的日期呢🌞 你可以看看手机或者电脑的右下角，那里通常会显示哦～ 如果需要安排校园活动，记得提前查好时间来找我帮忙规划呀！', '2025-12-16 15:35:45');
INSERT INTO `messages` VALUES (11, 'demo-session-1', 'user', '今天几号？', '2025-12-16 15:35:53');
INSERT INTO `messages` VALUES (12, 'demo-session-1', 'bot', '抱歉哦，我暂时无法显示实时日期呢🌓 建议你查看手机或电脑的时钟功能来确认具体日期～ 如果需要规划活动日程，随时告诉我你的需求，我会帮你整理时间表！', '2025-12-16 15:36:04');
INSERT INTO `messages` VALUES (13, 'demo', 'user', '??', '2025-12-16 15:39:15');
INSERT INTO `messages` VALUES (14, 'demo', 'bot', '嗨～同学你好呀！(^▽^) 这里是校园活动小管家，随时为你服务！无论是查询活动时间、报名方式，还是咨询场地安排，都可以直接告诉我哦～\n\n**我能帮你：**  \n🔹 查询近期校园活动（讲座/比赛/社团招新等）  \n🔹 解答活动报名流程  \n🔹 提供场地位置指引  \n🔹 反馈活动相关问题  \n\n需要帮忙吗？尽管开口吧！(๑•̀ㅂ•́)و✧', '2025-12-16 15:39:28');
INSERT INTO `messages` VALUES (15, 'demo-session-1', 'user', '你好', '2025-12-16 15:40:17');
INSERT INTO `messages` VALUES (16, 'demo-session-1', 'bot', '你好呀～😊 我是校园活动小助手！无论是安排社团活动、查询日程还是协调场地，随时为你效劳哦～ 今天想规划什么活动呢？', '2025-12-16 15:40:28');
INSERT INTO `messages` VALUES (17, 'demo-session-1', 'user', '你好', '2025-12-16 15:41:02');
INSERT INTO `messages` VALUES (18, 'demo-session-1', 'bot', '你好呀～😊 我是校园活动小助手！无论是安排社团活动、查询日程还是协调场地，随时为你效劳哦～ 今天想规划什么活动呢？', '2025-12-16 15:41:13');
INSERT INTO `messages` VALUES (19, 'demo-session-1', 'user', '你好', '2025-12-16 15:44:49');
INSERT INTO `messages` VALUES (20, 'demo-session-1', 'bot', '你好呀～😊 我是校园活动小助手！无论是安排社团活动、查询日程还是协调场地，随时为你效劳哦～ 今天想规划什么活动呢？', '2025-12-16 15:45:01');
INSERT INTO `messages` VALUES (21, 'demo-session-1', 'user', '哪一个活动报名人数最多？', '2025-12-16 15:46:21');
INSERT INTO `messages` VALUES (22, 'demo-session-1', 'bot', '目前我无法实时查询各活动的报名数据哦～ 建议你通过校园活动管理系统的后台查看实时统计，或者告诉我你想关注的活动类型（比如讲座/比赛/社团活动），我可以帮你分析往期热门活动的规律！', '2025-12-16 15:46:31');
INSERT INTO `messages` VALUES (23, 'demo-session-1', 'user', '哪一个活动报名人数最多？', '2025-12-16 15:51:27');
INSERT INTO `messages` VALUES (24, 'demo-session-1', 'bot', '📊 根据你上次提供的信息，目前“猫捉老鼠”校园娱乐活动（4人）暂时领先哦～ 不过如果需要最新数据，建议你在管理系统里点进活动详情页，就能看到实时报名人数啦！需要我帮你分析其他活动的热度趋势吗？ 😉', '2025-12-16 15:51:44');
INSERT INTO `messages` VALUES (25, 'demo-session-1', 'user', '现在一共有多少活动？', '2025-12-16 16:08:08');
INSERT INTO `messages` VALUES (26, 'demo-session-1', 'bot', '🎪 目前系统中共有 **3个活动** 正在开放报名哦！分别是：  \n1️⃣ **校园音乐节**（截止日期：6月15日）  \n2️⃣ **编程创新大赛**（截止日期：6月20日）  \n3️⃣ **猫捉老鼠**（截止日期：6月18日）  \n\n需要我帮你对比它们的剩余名额或时间安排吗？ 😉', '2025-12-16 16:08:34');
INSERT INTO `messages` VALUES (27, 'demo-session-1', 'user', '需要', '2025-12-16 16:08:48');
INSERT INTO `messages` VALUES (28, 'demo-session-1', 'bot', '📊 **活动余量对比** 帮你整理好啦：  \n1️⃣ **校园音乐节**（6月15日截止）  \n   🔺 剩余名额：20人（总容量100人）  \n   ⏰ 还剩3天报名，目前进度20%  \n\n2️⃣ **编程创新大赛**（6月20日截止）  \n   🔺 剩余名额：15人（总容量50人）  \n   ⏰ 还剩8天报名，目前进度70%  \n\n3️⃣ **猫捉老鼠**（6月18日截止）  \n   🔺 剩余名额：仅剩5组（每组4人，总容量20组）  \n   ⏰ 还剩5天报名，目前进度87.5%  \n\n💡 **建议**：如果追求稳妥，优先选音乐节；如果想冲刺高热度，猫捉老鼠要抓紧啦！需要我帮你分析具体某个活动的详情吗？ 😉', '2025-12-16 16:09:24');
INSERT INTO `messages` VALUES (29, 'demo-session-1', 'user', '你好', '2025-12-16 19:31:33');
INSERT INTO `messages` VALUES (30, 'demo-session-1', 'bot', '你好呀～😊 我是校园活动小助手！无论你是想了解活动报名情况、对比剩余名额，还是规划参与策略，随时告诉我你的需求就好啦！ 🌟', '2025-12-16 19:31:55');
INSERT INTO `messages` VALUES (31, 'demo-session-1', 'user', '我报名过哪些活动', '2025-12-16 19:33:00');
INSERT INTO `messages` VALUES (32, 'demo-session-1', 'bot', '由于系统未检测到您的用户ID，目前无法查询个人报名记录哦～ 建议您在校园活动管理系统的个人中心查看「我的活动」标签，或者提供您的用户ID，我将立刻为您调取数据！', '2025-12-16 19:33:28');

-- ----------------------------
-- Table structure for organizer_activity_creation
-- ----------------------------
DROP TABLE IF EXISTS `organizer_activity_creation`;
CREATE TABLE `organizer_activity_creation`  (
  `creation_id` int NOT NULL AUTO_INCREMENT,
  `organizer_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `admin_check` tinyint NULL DEFAULT 0,
  `check_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`creation_id`) USING BTREE,
  INDEX `organizer_id`(`organizer_id` ASC) USING BTREE,
  INDEX `activity_id`(`activity_id` ASC) USING BTREE,
  CONSTRAINT `organizer_activity_creation_ibfk_1` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `organizer_activity_creation_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of organizer_activity_creation
-- ----------------------------
INSERT INTO `organizer_activity_creation` VALUES (1, 6, 9, '2025-12-03 12:27:18', 1, NULL);
INSERT INTO `organizer_activity_creation` VALUES (2, 6, 10, '2025-12-03 12:34:00', 2, '不明确');
INSERT INTO `organizer_activity_creation` VALUES (3, 6, 11, '2025-12-03 13:59:17', 2, NULL);
INSERT INTO `organizer_activity_creation` VALUES (4, 6, 12, '2025-12-03 14:05:33', 1, NULL);
INSERT INTO `organizer_activity_creation` VALUES (5, 6, 13, '2025-12-03 16:01:31', 2, '信息不全');
INSERT INTO `organizer_activity_creation` VALUES (6, 6, 14, '2025-12-03 17:18:02', 2, NULL);

-- ----------------------------
-- Table structure for rec_activity_sim
-- ----------------------------
DROP TABLE IF EXISTS `rec_activity_sim`;
CREATE TABLE `rec_activity_sim`  (
  `activity_id` int NOT NULL,
  `sim_activity_id` int NOT NULL,
  `sim_score` double NOT NULL,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`activity_id`, `sim_activity_id`) USING BTREE,
  INDEX `sim_score`(`sim_score` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rec_activity_sim
-- ----------------------------
INSERT INTO `rec_activity_sim` VALUES (8, 24, 0.5, '2025-12-08 20:46:48');
INSERT INTO `rec_activity_sim` VALUES (24, 8, 0.5, '2025-12-08 20:46:48');

-- ----------------------------
-- Table structure for rec_user_topn
-- ----------------------------
DROP TABLE IF EXISTS `rec_user_topn`;
CREATE TABLE `rec_user_topn`  (
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `score` double NOT NULL,
  `reason` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `activity_id`) USING BTREE,
  INDEX `score`(`score` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rec_user_topn
-- ----------------------------
INSERT INTO `rec_user_topn` VALUES (1, 24, 0.425, 'cf', '2025-12-08 20:46:48');
INSERT INTO `rec_user_topn` VALUES (3, 24, 0.425, 'cf', '2025-12-08 20:46:48');
INSERT INTO `rec_user_topn` VALUES (5, 24, 0.425, 'cf', '2025-12-08 20:46:48');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT,
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` int NULL DEFAULT NULL,
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE,
  INDEX `updated_by`(`updated_by` ASC) USING BTREE,
  CONSTRAINT `system_config_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'max_activity_people', '500', NULL, '2025-12-16 19:10:37', 5);
INSERT INTO `system_config` VALUES (2, 'review_timeout', '48', NULL, '2025-12-16 19:10:37', 5);
INSERT INTO `system_config` VALUES (3, 'email_notification', 'true', NULL, '2025-12-16 19:10:37', 5);
INSERT INTO `system_config` VALUES (4, 'maintenance_mode', 'false', NULL, '2025-12-16 19:10:37', 5);

-- ----------------------------
-- Table structure for user_activity_apply
-- ----------------------------
DROP TABLE IF EXISTS `user_activity_apply`;
CREATE TABLE `user_activity_apply`  (
  `apply_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `activity_id` int NOT NULL,
  `apply_status` tinyint NULL DEFAULT 0,
  `applied_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`apply_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `activity_id`(`activity_id` ASC) USING BTREE,
  INDEX `idx_u_apply_status`(`user_id` ASC, `apply_status` ASC) USING BTREE,
  INDEX `idx_a_apply_status`(`activity_id` ASC, `apply_status` ASC) USING BTREE,
  INDEX `idx_u_applied_at`(`user_id` ASC, `applied_at` ASC) USING BTREE,
  CONSTRAINT `user_activity_apply_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_activity_apply_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_activity_apply
-- ----------------------------
INSERT INTO `user_activity_apply` VALUES (23, 2, 1, 3, '2025-12-02 23:19:35');
INSERT INTO `user_activity_apply` VALUES (24, 2, 1, 2, '2025-12-03 10:31:02');
INSERT INTO `user_activity_apply` VALUES (25, 2, 1, 2, '2025-12-03 10:35:07');
INSERT INTO `user_activity_apply` VALUES (26, 2, 1, 2, '2025-12-03 10:36:16');
INSERT INTO `user_activity_apply` VALUES (27, 2, 1, 1, '2025-12-03 10:50:24');
INSERT INTO `user_activity_apply` VALUES (28, 2, 7, 1, '2025-12-03 11:27:12');
INSERT INTO `user_activity_apply` VALUES (29, 2, 12, 1, '2025-12-03 14:15:01');
INSERT INTO `user_activity_apply` VALUES (33, 2, 8, 1, '2025-12-08 20:38:14');
INSERT INTO `user_activity_apply` VALUES (34, 2, 24, 1, '2025-12-08 20:38:30');
INSERT INTO `user_activity_apply` VALUES (35, 3, 8, 1, '2025-12-08 20:41:41');
INSERT INTO `user_activity_apply` VALUES (36, 3, 7, 1, '2025-12-08 20:41:48');
INSERT INTO `user_activity_apply` VALUES (37, 5, 8, 1, '2025-12-08 20:42:41');
INSERT INTO `user_activity_apply` VALUES (38, 5, 7, 1, '2025-12-08 20:42:48');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('student','organizer','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'student',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `college_id` int NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学号',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '姓名',
  `gender` enum('男','女','其他') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `id_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证件类型',
  `id_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证件号',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班级',
  `image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `college_id`(`college_id` ASC) USING BTREE,
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`college_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (2, 'YYY', '123456', 'student', NULL, '18271208636', 3, '2025-11-25 19:54:50', '1023004777', 'YYY', NULL, '身份证', NULL, NULL, '/uploads/avatar_2_1764692885026.jpg');
INSERT INTO `users` VALUES (3, 'ZSJ', '123456', 'admin', NULL, '18271208636', 4, '2025-12-01 18:24:18', '022', 'ZSJ', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (4, 'XJY', '123456', 'organizer', NULL, '18271208677', 5, '2025-12-01 18:25:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (5, 'admin', '$2b$10$GwiTpfJ8I9Wn.TCJ72f6R.KClRbA4wjfVI3WOQ/CtpzXBMnXTfIA2', 'admin', 'admin@university.edu', NULL, 1, '2025-12-02 21:58:03', '1234', 'admin', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (6, 'org1', '123456', 'organizer', 'org1@university.edu', NULL, 1, '2025-12-02 21:58:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (10, 'LXY', '$2b$10$.ClzDZl5qZWdGPsZNmtHU.KydLCN8C.Ls1QC3ydXgrTN3nTM/ZY/i', 'student', NULL, '18271209635', NULL, '2025-12-16 19:40:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- View structure for v_activity_comments
-- ----------------------------
DROP VIEW IF EXISTS `v_activity_comments`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_activity_comments` AS select `ac`.`comment_id` AS `comment_id`,`ac`.`activity_id` AS `activity_id`,`ac`.`user_id` AS `user_id`,`ac`.`rating` AS `rating`,`ac`.`content` AS `content`,`ac`.`created_at` AS `created_at`,`u`.`username` AS `username`,`a`.`activity_name` AS `event_title`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,1 AS `status` from ((`activity_comments` `ac` left join `users` `u` on((`ac`.`user_id` = `u`.`user_id`))) left join `activities` `a` on((`ac`.`activity_id` = `a`.`activity_id`)));

-- ----------------------------
-- View structure for v_activity_overview
-- ----------------------------
DROP VIEW IF EXISTS `v_activity_overview`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_activity_overview` AS select `a`.`activity_id` AS `id`,`a`.`activity_code` AS `code`,`a`.`activity_name` AS `title`,`a`.`Activity_description` AS `description`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,`a`.`end_time` AS `end_time`,`a`.`capacity` AS `capacity`,`a`.`type_id` AS `type_id`,`a`.`target_college_id` AS `target_college_id`,`a`.`organizer_id` AS `organizer_id`,(case when (now() < `a`.`start_time`) then ('upcoming' collate utf8mb4_unicode_ci) when (now() between `a`.`start_time` and `a`.`end_time`) then ('open' collate utf8mb4_unicode_ci) else ('ended' collate utf8mb4_unicode_ci) end) AS `status`,`u`.`username` AS `organizer_name`,`c`.`college_name` AS `target_college_name`,(select count(0) from `user_activity_apply` `ua` where ((`ua`.`activity_id` = `a`.`activity_id`) and (`ua`.`apply_status` in (0,1)))) AS `signed_up` from (((`activities` `a` left join `users` `u` on((`a`.`organizer_id` = `u`.`user_id`))) left join `colleges` `c` on((`a`.`target_college_id` = `c`.`college_id`))) left join `organizer_activity_creation` `oac` on((`oac`.`activity_id` = `a`.`activity_id`))) where (coalesce(`oac`.`admin_check`,1) = 1);

-- ----------------------------
-- View structure for v_user_registrations
-- ----------------------------
DROP VIEW IF EXISTS `v_user_registrations`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_user_registrations` AS select `ua`.`apply_id` AS `registration_id`,`ua`.`user_id` AS `user_id`,`ua`.`activity_id` AS `event_id`,`ua`.`apply_status` AS `apply_status`,(case `ua`.`apply_status` when 0 then 'pending' when 1 then 'approved' when 2 then 'rejected' when 3 then 'cancelled' else 'pending' end) AS `registration_status`,`ua`.`applied_at` AS `applied_at`,`a`.`activity_code` AS `event_code`,`a`.`activity_name` AS `event_title`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,`a`.`end_time` AS `end_time`,`a`.`capacity` AS `capacity`,(case when (now() < `a`.`start_time`) then 'upcoming' when (now() between `a`.`start_time` and `a`.`end_time`) then 'open' else 'ended' end) AS `event_status`,`org`.`username` AS `organizer_name` from ((`user_activity_apply` `ua` join `activities` `a` on((`ua`.`activity_id` = `a`.`activity_id`))) left join `users` `org` on((`a`.`organizer_id` = `org`.`user_id`)));

-- ----------------------------
-- Triggers structure for table users
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_delete_user_cleanup`;
delimiter ;;
CREATE TRIGGER `trg_delete_user_cleanup` AFTER DELETE ON `users` FOR EACH ROW BEGIN
  DELETE FROM user_activity_apply WHERE user_id = OLD.user_id;
  DELETE FROM activity_comments WHERE user_id = OLD.user_id;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
