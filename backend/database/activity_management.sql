/*
 Navicat Premium Data Transfer

 Source Server         : APP
 Source Server Type    : MySQL
 Source Server Version : 80040
 Source Host           : localhost:3306
 Source Schema         : activity_management

 Target Server Type    : MySQL
 Target Server Version : 80040
 File Encoding         : 65001

 Date: 26/12/2025 14:23:09
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
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`activity_id`) USING BTREE,
  UNIQUE INDEX `activity_code`(`activity_code` ASC) USING BTREE,
  INDEX `type_id`(`type_id` ASC) USING BTREE,
  INDEX `target_college_id`(`target_college_id` ASC) USING BTREE,
  INDEX `organizer_id`(`organizer_id` ASC) USING BTREE,
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `activity_types` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activities_ibfk_2` FOREIGN KEY (`target_college_id`) REFERENCES `colleges` (`college_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activities_ibfk_3` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activities
-- ----------------------------
INSERT INTO `activities` VALUES (1, 'AI技术讲座', 'ACT001', '邀请知名专家讲解人工智能最新技术发展', 1, '2024-12-15 14:00:00', '2024-12-15 16:00:00', '大礼堂', 1, 200, 2, 'uploads\\fbd146228157e894c10fa56bd950c829.jpg', '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (2, '编程挑战赛', 'ACT002', '面向全校的算法编程竞赛', 2, '2025-01-05 09:00:00', '2025-01-05 18:00:00', '创新实验室', 2, 150, 2, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (3, '珞狮体育嘉年华', 'ACT003', '武汉理工田径场全天候体育嘉年华，包含飞盘、路跑、桨板等体验', 4, '2025-03-20 08:30:00', '2025-03-20 17:30:00', '余家头校区田径场', 2, 500, 4, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (4, '东湖龙舟体验营', 'ACT004', '邀请龙舟队教练带来水上课程，面向所有院系开放', 4, '2025-04-12 09:00:00', '2025-04-12 15:00:00', '东湖风景区码头', 3, 120, 4, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (5, '武汉理工校史文化巡礼', 'ACT005', '以校史馆为起点，串联余区地标的沉浸式讲解路线', 5, '2025-04-28 14:00:00', '2025-04-28 17:00:00', '余家头校史馆', 1, 80, 5, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (6, '青春湖畔音乐节', 'ACT006', '南湖草坪大型民谣与电子音乐专场，邀请师生乐队同台', 5, '2025-05-18 18:30:00', '2025-05-18 22:00:00', '南湖露天舞台', 4, 400, 5, 'uploads\\avatar_12_1766058138829.jpg', '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (7, '智能车创客营', 'ACT007', '智能车队与实验室联合举办的实训营，提供器材与导师辅导', 6, '2025-06-08 09:30:00', '2025-06-08 17:30:00', '智能制造实验室', 1, 60, 2, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (8, '光谷博物馆夜游', 'ACT008', '与光谷科技馆合作的夜间科普专场，含讲解与互动展区', 5, '2025-06-22 19:00:00', '2025-06-22 22:00:00', '湖北省科技馆', 3, 200, 5, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (9, '未来材料研讨沙龙', 'ACT009', '材料学院教授分享前沿成果，并邀请研究生参与圆桌讨论', 1, '2025-07-02 15:00:00', '2025-07-02 18:00:00', '材料科学楼A302', 1, 100, 1, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (10, '军运会志愿者培训营', 'ACT010', '志愿服务中心组织的赛会志愿技能培训', 3, '2025-07-15 13:30:00', '2025-07-15 17:30:00', '航海楼报告厅', 5, 250, 4, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (11, '国际文化交流日', 'ACT011', '留学生与本土社团联合布展，体验全球文化市集', 5, '2025-07-26 10:00:00', '2025-07-26 18:00:00', '南湖会堂', 4, 300, 12, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (12, '创客孵化工作坊', 'ACT012', '创客导师带来武汉理工特色的创业实战演练', 6, '2025-08-03 09:00:00', '2025-08-03 16:30:00', '创新创业基地', 1, 80, 2, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (13, '智慧交通创新周', 'ACT013', '交通学院联合企业开展未来交通方案共创周，含沙龙与体验展。', 6, '2026-03-10 09:30:00', '2026-03-15 17:30:00', '南湖交通创新中心', 4, 180, 2, NULL, '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (14, '沿江城市徒步嘉年华', 'ACT014', '组织 30 公里江城徒步路线，沿途设置文化补给站与伙伴任务。', 4, '2026-04-20 07:00:00', '2026-04-20 18:00:00', '武汉江滩集合点', 2, 600, 4, 'uploads\\12856a4a6a09886ee2cef503d7b52703.jpg', '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (15, '未来能源开放实验室', 'ACT015', '能源学院开放氢能与储能实验平台，安排导师带队深度体验。', 1, '2026-05-08 13:30:00', '2026-05-08 18:30:00', '能源大楼B1实验区', 1, 90, 1, 'uploads\\dde8647d62163b809fec57e3bfece40d.jpg', '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (16, '校园可持续设计黑客松', 'ACT016', '跨专业团队 36 小时共创低碳校园解决方案，配套导师辅导。', 2, '2026-06-12 09:00:00', '2026-06-13 21:00:00', '南湖创客空间', 5, 200, 5, 'uploads\\fbd146228157e894c10fa56bd950c829.jpg', '2025-12-20 13:04:18');
INSERT INTO `activities` VALUES (17, '舞动青春', 'ACT2512205164', '舞动青春是一场面向全校同学的文体活动，旨在通过舞蹈释放活力、展现风采。无论你是舞蹈爱好者还是零基础新手，都可以在这里感受节奏、结交朋友，在律动中放松身心、收获快乐。具体时间地点将另行通知，期待与你共舞！', 1, '2025-12-21 18:30:00', '2025-12-21 20:30:00', '慧园操场', NULL, 0, 2, '/uploads/cover_1766216625125_kkp4nr.jpg', '2025-12-20 15:43:45');
INSERT INTO `activities` VALUES (18, '冬至包饺子', 'ACT2512249846', '冬至将至，一起动手包饺子吧！在欢声笑语中体验传统习俗，亲手制作热腾腾的饺子，与同学们分享温暖与美味。无论你是厨房新手还是美食达人，都能在这里找到乐趣，结交新朋友，感受冬日里的校园温情。具体时间地点请关注后续通知，期待与你共度温馨冬至！', 1, '2025-12-24 11:50:00', '2025-12-25 11:50:00', '越远食堂', NULL, 0, 2, '/uploads/cover_1766548269788_locjn7.jpg', '2025-12-24 11:51:09');

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
  CONSTRAINT `activity_comments_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_comments_chk_1` CHECK ((`rating` >= 1) and (`rating` <= 5))
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_comments
-- ----------------------------
INSERT INTO `activity_comments` VALUES (2, 1, 6, '讲座中分享的案例贴近武汉理工的科研方向。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (3, 2, 7, '赛题覆盖算法与工程实现，强烈推荐参加。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (4, 3, 8, '嘉年华的飞盘体验太棒了，期待明年继续。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (5, 5, 6, '讲解老师耐心，路线紧凑，了解了很多校史细节。', 4, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (6, 6, 7, '舞台灯光和音响配置专业，就是排队入场稍慢。', 4, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (7, 7, 9, '导师手把手指导焊接与调试，新手也能快速入门。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (8, 8, 10, '夜场讲解氛围感很好，互动装置很酷。', 4, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (9, 9, 6, '沙龙嘉宾回答问题很细致，收获满满。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (10, 10, 9, '培训内容覆盖突发情况处理，对志愿者很实用。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (11, 11, 10, '文化展位太丰富了，咖啡和音乐都超赞。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (12, 12, 13, '导师拆解商业模型思路清晰，干货拉满。', 5, '2025-12-20 13:04:18');
INSERT INTO `activity_comments` VALUES (13, 1, 3, '好', 5, '2025-12-20 13:30:08');

-- ----------------------------
-- Table structure for activity_point_rules
-- ----------------------------
DROP TABLE IF EXISTS `activity_point_rules`;
CREATE TABLE `activity_point_rules`  (
  `rule_id` int NOT NULL AUTO_INCREMENT,
  `activity_id` int NOT NULL,
  `organizer_id` int NOT NULL,
  `action_label` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `points_value` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint NULL DEFAULT 1,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`) USING BTREE,
  UNIQUE INDEX `uq_activity_action`(`activity_id` ASC, `action_label` ASC) USING BTREE,
  INDEX `organizer_id`(`organizer_id` ASC) USING BTREE,
  CONSTRAINT `activity_point_rules_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_point_rules_ibfk_2` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_point_rules
-- ----------------------------
INSERT INTO `activity_point_rules` VALUES (1, 1, 2, '签到参与', 50, '按时到场并完成二维码签到', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (2, 1, 2, '现场提问', 30, '向嘉宾提问并被采纳', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (3, 2, 2, '提交作品', 120, '按要求提交完整作品', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (4, 3, 4, '完成挑战站点', 80, '体育嘉年华完成全部体验盖章', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (5, 5, 5, '集章打卡', 60, '巡礼路线集齐三枚章', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (6, 7, 2, '实验任务达成', 150, '独立完成智能车调试任务', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (7, 10, 4, '培训考核通过', 90, '完成志愿者情景考核', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (8, 11, 12, '文化互动分享', 70, '在国际文化交流日分享家乡文化', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `activity_point_rules` VALUES (9, 12, 2, '商业画布提交', 130, '完成创客营商业画布评审', 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');

-- ----------------------------
-- Table structure for activity_types
-- ----------------------------
DROP TABLE IF EXISTS `activity_types`;
CREATE TABLE `activity_types`  (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `type_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_types
-- ----------------------------
INSERT INTO `activity_types` VALUES (1, '学术讲座', '学术类分享与讲座');
INSERT INTO `activity_types` VALUES (2, '竞赛活动', '编程、创新等竞赛');
INSERT INTO `activity_types` VALUES (3, '志愿服务', '公益志愿者活动');
INSERT INTO `activity_types` VALUES (4, '体育赛事', '校级体育赛事与体验');
INSERT INTO `activity_types` VALUES (5, '文化节', '艺术展演与校园文化活动');
INSERT INTO `activity_types` VALUES (6, '创新创业', '创新创业训练营与沙龙');

-- ----------------------------
-- Table structure for announcement_confirmations
-- ----------------------------
DROP TABLE IF EXISTS `announcement_confirmations`;
CREATE TABLE `announcement_confirmations`  (
  `confirmation_id` int NOT NULL AUTO_INCREMENT,
  `announcement_id` int NOT NULL COMMENT '公告ID',
  `user_id` int NOT NULL COMMENT '确认用户ID',
  `confirmed_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '确认时间',
  PRIMARY KEY (`confirmation_id`) USING BTREE,
  UNIQUE INDEX `uk_announcement_user`(`announcement_id` ASC, `user_id` ASC) USING BTREE COMMENT '同一用户不能重复确认同一公告',
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `announcement_confirmations_ibfk_1` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`announcement_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `announcement_confirmations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of announcement_confirmations
-- ----------------------------
INSERT INTO `announcement_confirmations` VALUES (1, 1, 3, '2025-12-20 16:14:11');
INSERT INTO `announcement_confirmations` VALUES (2, 1, 6, '2025-12-20 16:17:41');
INSERT INTO `announcement_confirmations` VALUES (3, 1, 2, '2025-12-20 16:17:58');
INSERT INTO `announcement_confirmations` VALUES (4, 1, 1, '2025-12-20 16:53:11');
INSERT INTO `announcement_confirmations` VALUES (5, 1, 14, '2025-12-24 00:11:55');

-- ----------------------------
-- Table structure for announcements
-- ----------------------------
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements`  (
  `announcement_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告内容',
  `publisher_id` int NOT NULL COMMENT '发布者ID（管理员或组织者）',
  `publisher_type` enum('admin','organizer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin' COMMENT '发布者类型',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-待审核（组织者申请），1-已发布，2-已驳回',
  `admin_check` tinyint NULL DEFAULT NULL COMMENT '管理员审核状态：0-待审核，1-通过，2-驳回',
  `check_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `checked_by` int NULL DEFAULT NULL COMMENT '审核管理员ID',
  `checked_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `published_at` datetime NULL DEFAULT NULL COMMENT '发布时间',
  PRIMARY KEY (`announcement_id`) USING BTREE,
  INDEX `idx_publisher`(`publisher_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `announcements_ibfk_2`(`checked_by` ASC) USING BTREE,
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `announcements_ibfk_2` FOREIGN KEY (`checked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of announcements
-- ----------------------------
INSERT INTO `announcements` VALUES (1, '测试公告', '测试测试', 1, 'admin', 1, NULL, NULL, NULL, NULL, '2025-12-20 16:13:30', '2025-12-20 16:13:30');

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of colleges
-- ----------------------------
INSERT INTO `colleges` VALUES (1, '计算机学院', 'CS01');
INSERT INTO `colleges` VALUES (2, '电子信息学院', 'EE01');
INSERT INTO `colleges` VALUES (3, '管理学院', 'MG01');
INSERT INTO `colleges` VALUES (4, '交通与物流工程学院', 'TW01');
INSERT INTO `colleges` VALUES (5, '艺术设计学院', 'ART01');
INSERT INTO `colleges` VALUES (6, '自动化学院', 'AU01');

-- ----------------------------
-- Table structure for forum_comments
-- ----------------------------
DROP TABLE IF EXISTS `forum_comments`;
CREATE TABLE `forum_comments`  (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '帖子ID',
  `user_id` int NOT NULL COMMENT '评论用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `forum_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`post_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `forum_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of forum_comments
-- ----------------------------
INSERT INTO `forum_comments` VALUES (1, 1, 6, '鉴主教学楼这边能骑过来看看吗？', '2025-12-20 15:44:05');
INSERT INTO `forum_comments` VALUES (2, 2, 7, '我刚才去302看了一眼，去一楼保安亭问问？', '2025-12-19 16:44:05');
INSERT INTO `forum_comments` VALUES (3, 3, 8, '它是真的心宽体胖。', '2025-12-18 14:44:05');
INSERT INTO `forum_comments` VALUES (4, 7, 6, '冒菜西施', '2025-12-20 15:04:46');
INSERT INTO `forum_comments` VALUES (5, 7, 6, '真的好吃', '2025-12-20 15:06:46');
INSERT INTO `forum_comments` VALUES (6, 7, 6, '？', '2025-12-20 15:07:01');
INSERT INTO `forum_comments` VALUES (7, 7, 6, '？', '2025-12-20 15:08:27');

-- ----------------------------
-- Table structure for forum_favorites
-- ----------------------------
DROP TABLE IF EXISTS `forum_favorites`;
CREATE TABLE `forum_favorites`  (
  `favorite_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '帖子ID',
  `user_id` int NOT NULL COMMENT '收藏用户ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`favorite_id`) USING BTREE,
  UNIQUE INDEX `uk_post_user`(`post_id` ASC, `user_id` ASC) USING BTREE COMMENT '同一用户不能重复收藏同一帖子',
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `forum_favorites_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`post_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `forum_favorites_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of forum_favorites
-- ----------------------------

-- ----------------------------
-- Table structure for forum_posts
-- ----------------------------
DROP TABLE IF EXISTS `forum_posts`;
CREATE TABLE `forum_posts`  (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '发帖用户ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子内容',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '帖子图片',
  `category_id` int NULL DEFAULT 0 COMMENT '类别ID：0-全部/未分类，1-二手闲置，2-打听求助，3-恋爱交友，4-校园趣事，5-兼职招聘',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-待审核，1-已发布，2-已驳回',
  `admin_check` tinyint NULL DEFAULT NULL COMMENT '管理员审核状态：0-待审核，1-通过，2-驳回',
  `check_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `checked_by` int NULL DEFAULT NULL COMMENT '审核管理员ID',
  `checked_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`post_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `forum_posts_ibfk_2`(`checked_by` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `forum_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `forum_posts_ibfk_2` FOREIGN KEY (`checked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of forum_posts
-- ----------------------------
INSERT INTO `forum_posts` VALUES (1, 3, '【急出】南湖西院出Giant公路车，碟刹24速', '由于毕业无法带走，极品成色。原价2800购入，现价1100。南湖校区自提，车况非常好，送车锁。', 'https://img.alicdn.com/imgextra/i4/1596671518/O1CN01pBikeC1d2v8b3MtMz_!!0-item_pic.jpg', 0, 1, 1, NULL, NULL, NULL, '2025-12-20 13:44:05', '2025-12-20 13:44:05');
INSERT INTO `forum_posts` VALUES (2, 6, '求助：博学楼302有没有捡到一个蓝色钥匙包？', '昨晚在那自习，里面有升升公寓的门禁卡和两把宿舍钥匙，真的很急，今天还要回寝室。', NULL, 0, 1, 1, NULL, NULL, NULL, '2025-12-19 13:44:05', '2025-12-20 13:44:05');
INSERT INTO `forum_posts` VALUES (3, 7, '南湖图书馆后门的猫猫又胖了，大家真的别喂火腿肠了！', '宿管阿姨说它最近已经跳不上窗台了，建议大家换成健康的冻干或者猫粮。', 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500', 0, 1, 1, NULL, NULL, NULL, '2025-12-18 13:44:05', '2025-12-20 13:44:05');
INSERT INTO `forum_posts` VALUES (4, 8, '【官方招募】校园文创市集执行志愿者，有补贴', '本周五下午校门口。协助布展。表现优异送理大限定帆布包。', NULL, 0, 1, 1, NULL, NULL, NULL, '2025-12-17 13:44:05', '2025-12-20 13:44:05');
INSERT INTO `forum_posts` VALUES (5, 9, '寻找每天在鉴湖边晨读的那个戴蓝色耳机的女孩', '你经常在早上7点左右出现，读的是托尔斯泰，感觉很有气质，想交个朋友。', NULL, 0, 1, 1, NULL, NULL, NULL, '2025-12-16 13:44:05', '2025-12-20 13:44:05');
INSERT INTO `forum_posts` VALUES (6, 3, '有午饭推荐吗', '南湖附近有什么好吃的外卖', NULL, 0, 1, 1, NULL, 1, '2025-12-20 15:56:49', '2025-12-20 13:46:36', '2025-12-20 15:56:49');
INSERT INTO `forum_posts` VALUES (7, 3, '午饭推荐', '有什么午饭推荐吗uu', NULL, 2, 1, 1, NULL, NULL, NULL, '2025-12-20 13:53:04', '2025-12-20 13:53:04');

-- ----------------------------
-- Table structure for gift_feedback
-- ----------------------------
DROP TABLE IF EXISTS `gift_feedback`;
CREATE TABLE `gift_feedback`  (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` tinyint NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`) USING BTREE,
  UNIQUE INDEX `uq_feedback_order`(`order_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `gift_feedback_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `gift_orders` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gift_feedback_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gift_feedback_chk_1` CHECK (`rating` between 1 and 5)
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gift_feedback
-- ----------------------------
INSERT INTO `gift_feedback` VALUES (1, 2, 7, 5, '帆布包质感很好，收到第二天就背去上课了。', '2025-12-20 13:04:18');
INSERT INTO `gift_feedback` VALUES (2, 3, 10, 4, '徽章很精致，如果能再附包装袋就更好了。', '2025-12-20 13:04:18');
INSERT INTO `gift_feedback` VALUES (3, 4, 8, 5, '手账纸质顺滑，荧光贴很有夜游氛围。', '2025-12-20 13:04:18');
INSERT INTO `gift_feedback` VALUES (4, 8, 10, 5, '咖啡券兑换方便，限定杯套很有收藏价值。', '2025-12-20 13:04:18');

-- ----------------------------
-- Table structure for gift_items
-- ----------------------------
DROP TABLE IF EXISTS `gift_items`;
CREATE TABLE `gift_items`  (
  `gift_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `points_cost` int NOT NULL,
  `stock` int NOT NULL,
  `delivery_type` enum('online','offline','both') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'offline',
  `status` enum('pending','active','inactive','rejected','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'pending',
  `review_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by` int NOT NULL,
  `approved_by` int NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`gift_id`) USING BTREE,
  INDEX `created_by`(`created_by` ASC) USING BTREE,
  INDEX `approved_by`(`approved_by` ASC) USING BTREE,
  CONSTRAINT `gift_items_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gift_items_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gift_items
-- ----------------------------
INSERT INTO `gift_items` VALUES (1, '校园定制水杯', '双层玻璃杯，限量校徽款。', 'uploads\\gifts\\校园定制水杯.jpg', 120, 80, 'offline', 'active', NULL, 2, 1, '2025-12-20 13:04:18', '2025-12-24 12:01:43');
INSERT INTO `gift_items` VALUES (2, '活动加油礼包', '含能量棒、贴纸等小礼物，适合户外活动。', 'uploads\\gifts\\活动加油礼包.jpg', 80, 119, 'both', 'active', NULL, 2, 1, '2025-12-20 13:04:18', '2025-12-24 12:04:08');
INSERT INTO `gift_items` VALUES (3, '线上音乐会门票', '赞助商提供的线上演唱会兑换码。', 'uploads\\gifts\\线上音乐会门票.jpg', 200, 40, 'online', 'active', NULL, 1, 1, '2025-12-20 13:04:18', '2025-12-24 12:03:35');
INSERT INTO `gift_items` VALUES (4, '珞狮校园帆布包', '武汉理工手绘地标帆布包，含胸章贴纸组合。', 'uploads\\gifts\\珞狮校园帆布包.jpg', 90, 150, 'both', 'active', NULL, 4, 1, '2025-12-20 13:04:18', '2025-12-24 12:05:02');
INSERT INTO `gift_items` VALUES (5, '余区纪念徽章套装', '校史馆推出的四枚限量徽章，附纪念卡。', 'uploads\\gifts\\余区纪念微章套装.jpg', 60, 220, 'offline', 'active', NULL, 5, 1, '2025-12-20 13:04:18', '2025-12-24 12:03:07');
INSERT INTO `gift_items` VALUES (6, '龙舟体验券', '可在东湖龙舟基地兑换一次体验课程。', 'uploads\\gifts\\龙舟体验券.jpg', 180, 50, 'offline', 'active', '管理员审核通过', 4, 1, '2025-12-20 13:04:18', '2025-12-24 12:04:36');
INSERT INTO `gift_items` VALUES (7, '夜游科普手账', '夜游活动限定手账与荧光贴组合。', 'uploads\\gifts\\夜游科普手账.jpg', 70, 160, 'both', 'active', NULL, 5, 1, '2025-12-20 13:04:18', '2025-12-24 12:02:47');
INSERT INTO `gift_items` VALUES (8, '材料实验室 VIP 参观券', '可预约带队进入材料学院示范实验室。', '/uploads/gift_labpass.jpg', 150, 30, 'offline', 'inactive', NULL, 1, 1, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `gift_items` VALUES (9, '校园咖啡券', '南湖咖啡吧任意饮品一杯，附限定杯套。', 'uploads\\gifts\\校园咖啡券.jpg', 65, 200, 'offline', 'active', NULL, 12, 1, '2025-12-20 13:04:18', '2025-12-24 12:02:11');
INSERT INTO `gift_items` VALUES (11, '书', '', '/uploads/gift_1766220831932_a1zugc.jpg', 100, 20, 'offline', 'active', '管理员审核通过', 2, 1, '2025-12-20 16:53:51', '2025-12-20 16:54:13');

-- ----------------------------
-- Table structure for gift_orders
-- ----------------------------
DROP TABLE IF EXISTS `gift_orders`;
CREATE TABLE `gift_orders`  (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `gift_id` int NOT NULL,
  `user_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT 1,
  `total_points` int NOT NULL,
  `status` enum('pending','processing','shipped','received','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'pending',
  `contact_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_method` enum('online','offline') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'offline',
  `pickup_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`) USING BTREE,
  INDEX `gift_id`(`gift_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `gift_orders_ibfk_1` FOREIGN KEY (`gift_id`) REFERENCES `gift_items` (`gift_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gift_orders_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gift_orders
-- ----------------------------
INSERT INTO `gift_orders` VALUES (1, 2, 3, 1, 80, 'shipped', '李同学', '18800001111', 'offline', '学生事务中心', NULL, '2025-12-20 13:04:18', '2025-12-26 00:10:28');
INSERT INTO `gift_orders` VALUES (2, 4, 7, 1, 120, 'shipped', '王同学', '18800002222', 'offline', '余家头校史馆文创角', NULL, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `gift_orders` VALUES (3, 5, 10, 1, 90, 'received', '孙同学', '18800003333', 'offline', '校史馆服务台', NULL, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `gift_orders` VALUES (4, 7, 8, 1, 70, 'received', '刘同学', '18800004444', 'offline', '邮寄至学生公寓', NULL, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `gift_orders` VALUES (5, 1, 6, 2, 240, 'shipped', '周同学', '18800005555', 'offline', '南湖生活区包裹点', NULL, '2025-12-20 13:04:18', '2025-12-26 00:10:28');
INSERT INTO `gift_orders` VALUES (6, 3, 6, 1, 200, 'shipped', '周同学', '18800005555', 'online', NULL, NULL, '2025-12-20 13:04:18', '2025-12-26 00:10:29');
INSERT INTO `gift_orders` VALUES (7, 6, 9, 1, 180, 'shipped', '赵同学', '18800006666', 'offline', '东湖龙舟基地前台', NULL, '2025-12-20 13:04:18', '2025-12-26 00:10:29');
INSERT INTO `gift_orders` VALUES (8, 9, 10, 2, 130, 'received', '孙同学', '18800003333', 'offline', '南湖咖啡吧', NULL, '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `gift_orders` VALUES (9, 4, 13, 1, 90, 'shipped', '钱同学', '18800007777', 'offline', '邮寄至创业学院', NULL, '2025-12-20 13:04:18', '2025-12-26 00:10:29');
INSERT INTO `gift_orders` VALUES (10, 2, 3, 1, 80, 'shipped', 'student1', '13324653456', 'offline', '', '', '2025-12-20 13:36:09', '2025-12-26 00:10:27');

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
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `messages` VALUES (33, 'demo-session-1', 'user', '你好', '2025-12-20 13:29:31');
INSERT INTO `messages` VALUES (34, 'demo-session-1', 'bot', '你好！😊 看起来你可能有新的需求？无论是想了解活动详情、报名进度，还是需要其他帮助，随时告诉我吧！我会尽力为你提供清晰的信息～ 🌟', '2025-12-20 13:29:35');
INSERT INTO `messages` VALUES (35, 'demo-session-1', 'user', '今天几月几号', '2025-12-25 22:41:07');
INSERT INTO `messages` VALUES (36, 'demo-session-1', 'bot', '今天是 **2025年6月12日**（星期四）。  \n如果需要查询活动截止时间或安排日程，可以随时告诉我哦！ 📅✨', '2025-12-25 22:41:11');
INSERT INTO `messages` VALUES (37, 'demo-session-1', 'user', '今天几月几号', '2025-12-25 22:43:01');
INSERT INTO `messages` VALUES (38, 'demo-session-1', 'bot', '今天是 **2025年6月12日**（星期四）。  \n需要我帮你看看近期有哪些活动吗？ 😊', '2025-12-25 22:43:04');
INSERT INTO `messages` VALUES (39, 'demo-session-1', 'user', '今天几月几号', '2025-12-25 22:53:53');
INSERT INTO `messages` VALUES (40, 'demo-session-1', 'bot', '今天是 **2025年6月12日**（星期四）。  \n如果对日期有疑问（比如活动截止时间），可以告诉我具体活动名称，我来帮你核对哦！ 📅✨', '2025-12-25 22:53:58');
INSERT INTO `messages` VALUES (41, 'demo-session-1', 'user', '你能给我推荐一些活动吗', '2025-12-26 00:39:36');
INSERT INTO `messages` VALUES (42, 'demo-session-1', 'bot', '由于系统未检测到您的用户ID，我暂时无法基于您的历史报名记录进行个性化推荐。不过，我可以为你介绍一些近期校园内比较热门的活动类型，供你参考：\n\n**近期热门活动类型参考**  \n1. **学术讲座类**  \n   - 常见主题：人工智能前沿、创业分享、学科竞赛指导  \n   - 时间特点：多集中在周末或工作日晚间  \n\n2. **志愿服务类**  \n   - 常见项目：社区帮扶、环保活动、支教招募  \n   - 适合人群：喜欢实践、有社会责任感的同学  \n\n3. **文体娱乐类**  \n   - 常见形式：篮球赛、音乐节、话剧演出、手工 workshop  \n   - 时间特点：周末或节假日居多  \n\n4. **职业发展类**  \n   - 常见活动：企业参访、模拟面试、简历 workshop  \n   - 适合人群：求职或实习准备期的同学  \n\n**小贴士**  \n- 如果你有**用户ID**，可以告诉我，我能立刻调取你的历史报名记录，为你做个性化推荐（比如“常参加某类活动”“常去某个校区”等）。  \n- 你也可以在校园活动系统的 **“活动广场”** 页面，用筛选功能按类型、时间、地点快速查找感兴趣的活动哦！  \n\n需要我帮你解释某类活动的具体内容，或者查询某个特定活动吗？ 😊', '2025-12-26 00:39:48');
INSERT INTO `messages` VALUES (43, 'guest-session', 'user', '你能给我推荐一些活动吗', '2025-12-26 00:41:53');
INSERT INTO `messages` VALUES (44, 'guest-session', 'bot', '嗨！我是小活，你的校园活动助手！😊\n\n目前我无法获取你的历史报名记录，所以暂时无法提供个性化的智能推荐。不过，我可以为你展示当前校园里最热门的几个活动，这些活动的报名人数都很多，你可以参考一下：\n\n**🔥 当前热门活动推荐：**\n\n1. **AI技术讲座**\n   - **类型**：学术讲座\n   - **时间**：2024年12月15日 14:00\n   - **地点**：大礼堂\n   - **热度**：已有2人报名\n\n2. **国际文化交流日**\n   - **类型**：文化交流\n   - **时间**：2025年7月26日 10:00\n   - **地点**：南湖会堂\n   - **热度**：已有2人报名\n\n3. **军运会志愿者培训营**\n   - **类型**：志愿服务\n   - **时间**：2025年7月15日 13:30\n   - **地点**：航海楼报告厅\n   - **热度**：已有2人报名\n\n4. **未来材料研讨沙龙**\n   - **类型**：学术研讨\n   - **时间**：2025年7月2日 15:00\n   - **地点**：材料科学楼A302\n   - **热度**：已有2人报名\n\n5. **青春湖畔音乐节**\n   - **类型**：文艺演出\n   - **时间**：2025年5月18日 18:30\n   - **地点**：南湖露天舞台\n   - **热度**：已有2人报名\n\n💡 **温馨提示**：\n- 如果你想获得更精准的个性化推荐（比如根据你常参加的活动类型、时间偏好等），建议登录系统后，我就能基于你的历史记录为你智能匹配更适合的活动啦！\n- 今天是 **2025年12月26日（星期五）**，现在是 **00:41**。你可以根据自己的时间安排来选择活动。\n\n你对哪种类型的活动比较感兴趣呢？我可以帮你留意一下！🎉', '2025-12-26 00:42:08');
INSERT INTO `messages` VALUES (45, 'user-3-session', 'user', '你能给我推荐一些活动吗', '2025-12-26 00:43:25');
INSERT INTO `messages` VALUES (46, 'user-3-session', 'bot', '嗨！小活来啦！✨\n\n根据你的历史报名记录分析，我发现你特别喜欢参加**学术讲座**类的活动，而且经常去**武汉江滩集合点**附近参加活动。基于这些偏好，我为你推荐以下几个活动：\n\n---\n\n### 🎓 推荐活动列表\n\n1. **【学术讲座】未来能源开放实验室**  \n   ⏰ 时间：2026年5月8日 13:30  \n   📍 地点：能源大楼B1实验区  \n   💡 推荐理由：**类型匹配**——你常参加学术讲座类活动，这个活动正好符合你的兴趣！\n\n2. **【创新创业】智慧交通创新周**  \n   ⏰ 时间：2026年3月10日 09:30  \n   📍 地点：南湖交通创新中心  \n   💡 推荐理由：**拓展尝试**——虽然不是你常去的类型，但创新创业类活动能拓宽视野，说不定你会喜欢哦~\n\n3. **【竞赛活动】校园可持续设计黑客松**  \n   ⏰ 时间：2026年6月12日 09:00  \n   📍 地点：南湖创客空间  \n   💡 推荐理由：**热门活动**——这是近期很多同学关注的竞赛类活动，适合喜欢挑战的你！\n\n---\n\n如果你对某个活动感兴趣，或者想看看更多类型（比如志愿服务、文艺演出等），随时告诉我哦！😊', '2025-12-26 00:43:36');
INSERT INTO `messages` VALUES (47, 'user-3-session', 'user', '现在有什么同类型的活动？并且我还能报名', '2025-12-26 00:44:07');
INSERT INTO `messages` VALUES (48, 'user-3-session', 'bot', '你好！我来帮你筛选一下当前还能报名的、与你常参加的**学术讲座**同类型的活动。  \n\n不过，我需要先说明一下：  \n- **当前系统时间**是 **2025年12月26日（星期五）00:44**。  \n- 我手头现有的推荐数据中，与你偏好匹配的学术讲座类活动是 **【未来能源开放实验室】**，但它的举办时间是 **2026年5月8日**，距离现在还有好几个月，报名通道很可能还没开放，或者开放时间未定。  \n\n---\n\n### 🔍 当前可报名的同类型活动情况\n根据现有数据，**暂时没有正在报名中或即将举办的学术讲座类活动**。  \n\n这可能是因为：  \n1. 近期（12月底～1月初）正值考试周或假期，学术讲座类活动安排较少。  \n2. 你常参加的活动地点（武汉江滩集合点）近期没有讲座计划。  \n\n---\n\n### 💡 我的建议\n1. **留意新学期初**：通常每学期开学后（2月、9月左右）会有大量学术讲座上线。  \n2. **扩大筛选范围**：如果你愿意尝试其他地点（如校内教学楼、图书馆报告厅等），我可以帮你看看是否有其他类型的活动可以报名。  \n3. **主动关注**：你可以随时问我“最近有什么能报名的活动”，我会帮你实时筛选。  \n\n需要我帮你看看其他类型的活动吗？还是你有特定的时间或地点偏好？ 😊', '2025-12-26 00:44:19');
INSERT INTO `messages` VALUES (49, 'user-3-session', 'user', '今天几月几号', '2025-12-26 00:51:21');
INSERT INTO `messages` VALUES (50, 'user-3-session', 'bot', '今天是 **2025年12月26日（星期五）**，现在是 **00:51**。 😊', '2025-12-26 00:51:24');

-- ----------------------------
-- Table structure for news
-- ----------------------------
DROP TABLE IF EXISTS `news`;
CREATE TABLE `news`  (
  `news_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资讯内容',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '资讯图片',
  `publisher_id` int NOT NULL COMMENT '发布者ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`news_id`) USING BTREE,
  INDEX `idx_publisher`(`publisher_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `news_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of news
-- ----------------------------
INSERT INTO `news` VALUES (1, '测试资讯', '测试测试', NULL, 1, '2025-12-20 16:01:47', '2025-12-20 16:01:47');
INSERT INTO `news` VALUES (2, '四、六级笔试将于 12 月 13 日举行', '2025 年下半年全国大学英语四、六级考试笔试将于 12 月 13 日举行。请各位考生提前做好准备，注意考试时间和地点安排。', NULL, 1, '2025-10-12 10:00:00', '2025-12-20 16:04:59');
INSERT INTO `news` VALUES (3, '雅思成绩正式纳入美国 O-1 杰出人才签证语言能力证明', '雅思成绩正式纳入美国 O-1 杰出人才签证语言能力证明，权重进一步提升。这对于计划申请美国工作签证的同学来说是一个重要消息。', NULL, 1, '2025-10-15 14:30:00', '2025-12-20 16:04:59');
INSERT INTO `news` VALUES (4, '2025 年英语专业八级拟于 3 月 29 日举行', '2025 年英语专业八级拟于 3 月 29 日举行，请关注报名通知。请相关专业的同学及时关注学校通知，做好报名准备。', NULL, 1, '2025-10-18 09:00:00', '2025-12-20 16:04:59');

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of organizer_activity_creation
-- ----------------------------
INSERT INTO `organizer_activity_creation` VALUES (1, 2, 1, '2025-12-20 13:04:18', 1, '已完成资料审核');
INSERT INTO `organizer_activity_creation` VALUES (2, 2, 2, '2025-12-20 13:04:18', 1, '教务处备案通过');
INSERT INTO `organizer_activity_creation` VALUES (3, 4, 3, '2025-12-20 13:04:18', 1, '体育部联合发布');
INSERT INTO `organizer_activity_creation` VALUES (4, 4, 4, '2025-12-20 13:04:18', 1, '等待水上安全审批');
INSERT INTO `organizer_activity_creation` VALUES (5, 5, 5, '2025-12-20 13:04:18', 1, '文化宣传部联动');
INSERT INTO `organizer_activity_creation` VALUES (6, 5, 6, '2025-12-20 13:04:18', 1, '通过');
INSERT INTO `organizer_activity_creation` VALUES (7, 2, 7, '2025-12-20 13:04:18', 1, '实验室开放日');
INSERT INTO `organizer_activity_creation` VALUES (8, 5, 8, '2025-12-20 13:04:18', 1, '科普基地合作');
INSERT INTO `organizer_activity_creation` VALUES (9, 1, 9, '2025-12-20 13:04:18', 1, '材料学院研讨会');
INSERT INTO `organizer_activity_creation` VALUES (10, 4, 10, '2025-12-20 13:04:18', 1, '需补充志愿者名单');
INSERT INTO `organizer_activity_creation` VALUES (11, 12, 11, '2025-12-20 13:04:18', 1, '留学生办公室联动');
INSERT INTO `organizer_activity_creation` VALUES (12, 2, 12, '2025-12-20 13:04:18', 1, '创新创业学院支持');
INSERT INTO `organizer_activity_creation` VALUES (13, 2, 17, '2025-12-20 15:43:45', 1, NULL);
INSERT INTO `organizer_activity_creation` VALUES (14, 2, 18, '2025-12-24 11:51:09', 1, NULL);

-- ----------------------------
-- Table structure for point_transactions
-- ----------------------------
DROP TABLE IF EXISTS `point_transactions`;
CREATE TABLE `point_transactions`  (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `change_amount` int NOT NULL,
  `action_type` enum('earn','spend','adjust') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'earn',
  `related_activity_id` int NULL DEFAULT NULL,
  `related_gift_id` int NULL DEFAULT NULL,
  `order_id` int NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `related_activity_id`(`related_activity_id` ASC) USING BTREE,
  INDEX `related_gift_id`(`related_gift_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  CONSTRAINT `point_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `point_transactions_ibfk_2` FOREIGN KEY (`related_activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `point_transactions_ibfk_3` FOREIGN KEY (`related_gift_id`) REFERENCES `gift_items` (`gift_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `point_transactions_ibfk_4` FOREIGN KEY (`order_id`) REFERENCES `gift_orders` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of point_transactions
-- ----------------------------
INSERT INTO `point_transactions` VALUES (1, 3, 200, 'earn', 1, NULL, NULL, '参与 AI 技术讲座', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (2, 3, -80, 'spend', NULL, NULL, NULL, '兑换活动加油礼包预留', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (3, 6, 150, 'earn', 2, NULL, NULL, '编程挑战赛二等奖', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (4, 7, 120, 'earn', 3, NULL, NULL, '珞狮体育嘉年华志愿者', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (5, 8, 100, 'earn', 4, NULL, NULL, '龙舟体验营签到完成', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (6, 9, 80, 'earn', 5, NULL, NULL, '校史巡礼记录稿提交', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (7, 7, -120, 'spend', NULL, NULL, NULL, '兑换珞狮校园帆布包', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (8, 6, -200, 'spend', NULL, NULL, NULL, '兑换线上音乐会门票', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (9, 8, -70, 'spend', NULL, NULL, NULL, '兑换夜游科普手账', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (10, 9, 60, 'earn', 9, NULL, NULL, '材料沙龙志愿摄影', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (11, 10, 90, 'earn', 6, NULL, NULL, '湖畔音乐节舞台演出', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (12, 10, -90, 'spend', NULL, NULL, NULL, '兑换余区纪念徽章套装', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (13, 3, 50, 'adjust', NULL, NULL, NULL, '管理员补发签到积分', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (14, 10, 110, 'earn', 11, NULL, NULL, '国际文化交流日主持', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (15, 6, 130, 'earn', 12, NULL, NULL, '创客孵化优秀方案', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (16, 6, -120, 'spend', NULL, NULL, NULL, '兑换校园定制水杯', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (17, 13, 140, 'earn', 12, NULL, NULL, '孵化营商业画布评优', '2025-12-20 13:04:18');
INSERT INTO `point_transactions` VALUES (18, 3, -80, 'spend', NULL, 2, 10, '兑换 活动加油礼包', '2025-12-20 13:36:09');
INSERT INTO `point_transactions` VALUES (19, 3, 100, 'earn', NULL, NULL, NULL, '管理员调整', '2025-12-20 16:58:12');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'max_activity_people', '500', '最大活动人数限制', '2025-12-20 13:04:18', NULL);
INSERT INTO `system_config` VALUES (2, 'review_timeout', '48', '审核活动超时时间（小时）', '2025-12-20 13:04:18', NULL);
INSERT INTO `system_config` VALUES (3, 'email_notification', 'true', '启用邮件通知', '2025-12-20 13:04:18', NULL);
INSERT INTO `system_config` VALUES (4, 'maintenance_mode', 'false', '维护模式', '2025-12-20 13:04:18', NULL);

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
  CONSTRAINT `user_activity_apply_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_activity_apply_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_activity_apply
-- ----------------------------
INSERT INTO `user_activity_apply` VALUES (1, 3, 1, 1, '2024-12-10 09:00:00');
INSERT INTO `user_activity_apply` VALUES (2, 6, 1, 1, '2024-12-11 10:15:00');
INSERT INTO `user_activity_apply` VALUES (3, 7, 2, 1, '2024-12-22 14:20:00');
INSERT INTO `user_activity_apply` VALUES (4, 8, 3, 1, '2025-02-28 16:45:00');
INSERT INTO `user_activity_apply` VALUES (5, 3, 3, 2, '2025-03-02 09:30:00');
INSERT INTO `user_activity_apply` VALUES (6, 9, 4, 0, '2025-03-18 12:10:00');
INSERT INTO `user_activity_apply` VALUES (7, 6, 5, 1, '2025-04-10 08:40:00');
INSERT INTO `user_activity_apply` VALUES (8, 7, 6, 1, '2025-04-25 11:05:00');
INSERT INTO `user_activity_apply` VALUES (9, 8, 6, 1, '2025-04-26 15:18:00');
INSERT INTO `user_activity_apply` VALUES (10, 9, 7, 1, '2025-05-20 13:55:00');
INSERT INTO `user_activity_apply` VALUES (11, 10, 8, 0, '2025-05-28 19:10:00');
INSERT INTO `user_activity_apply` VALUES (12, 6, 9, 1, '2025-06-20 09:32:00');
INSERT INTO `user_activity_apply` VALUES (13, 7, 9, 1, '2025-06-21 10:02:00');
INSERT INTO `user_activity_apply` VALUES (14, 8, 10, 0, '2025-06-22 16:48:00');
INSERT INTO `user_activity_apply` VALUES (15, 9, 10, 1, '2025-06-23 18:12:00');
INSERT INTO `user_activity_apply` VALUES (16, 10, 11, 1, '2025-07-05 09:15:00');
INSERT INTO `user_activity_apply` VALUES (17, 6, 11, 1, '2025-07-06 14:00:00');
INSERT INTO `user_activity_apply` VALUES (18, 7, 12, 1, '2025-07-20 16:30:00');
INSERT INTO `user_activity_apply` VALUES (19, 13, 12, 1, '2025-07-22 10:18:00');
INSERT INTO `user_activity_apply` VALUES (20, 3, 14, 1, '2025-12-20 13:23:43');
INSERT INTO `user_activity_apply` VALUES (21, 14, 16, 3, '2025-12-25 23:03:00');
INSERT INTO `user_activity_apply` VALUES (22, 14, 15, 0, '2025-12-25 23:03:11');

-- ----------------------------
-- Table structure for user_schedules
-- ----------------------------
DROP TABLE IF EXISTS `user_schedules`;
CREATE TABLE `user_schedules`  (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `schedule_date` date NOT NULL,
  `start_time` time NULL DEFAULT NULL,
  `end_time` time NULL DEFAULT NULL,
  `status` enum('pending','done') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'pending',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`schedule_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_schedules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_schedules
-- ----------------------------
INSERT INTO `user_schedules` VALUES (1, 3, 'AI 技术讲座', '准备问题并提前到场签到', '2024-12-15', '13:30:00', '16:30:00', 'done', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (2, 6, '编程挑战赛热身', '与队友调试算法模板', '2025-01-04', '18:00:00', '21:00:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (3, 7, '珞狮嘉年华志愿岗', '负责飞盘体验报名引导', '2025-03-20', '08:00:00', '12:00:00', 'done', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (4, 8, '东湖龙舟体验营', '上午训练 下午体验赛', '2025-04-12', '08:30:00', '15:30:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (5, 9, '校史文化巡礼', '拍摄活动花絮短片', '2025-04-28', '13:00:00', '18:00:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (6, 10, '湖畔音乐节排练', '与乐队进行最终彩排', '2025-05-18', '15:00:00', '17:30:00', 'done', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (7, 6, '智能车创客营', '完成传感器调试任务', '2025-06-08', '09:00:00', '17:30:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (8, 7, '博物馆夜游', '组织同学签到入场', '2025-06-22', '18:30:00', '22:30:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (9, 8, '材料研讨沙龙', '准备圆桌分享发言稿', '2025-07-02', '14:00:00', '18:30:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (10, 9, '志愿者培训营', '提交值岗意向并参与演练', '2025-07-15', '13:00:00', '18:00:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (11, 10, '国际文化交流日主持', '彩排流程 + 控场', '2025-07-25', '14:00:00', '20:00:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');
INSERT INTO `user_schedules` VALUES (12, 13, '创客孵化工作坊', '准备商业画布资料', '2025-08-02', '13:00:00', '15:00:00', 'pending', '2025-12-20 13:04:18', '2025-12-20 13:04:18');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2b$10$qCEfe692sjamqP8kx6/yMujwvu5n6Mpwan8GjSeKysxPuuznS.l2G', 'admin', 'admin@example.com', NULL, 1, '2025-12-20 13:04:18', NULL, '管理员', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (2, 'organizer1', '$2b$10$8ynM8aFun8JtFvX2qRha2uGw2pzzurGPoF1BxG5BTzSladvYuxlgC', 'organizer', 'organizer1@example.com', NULL, 1, '2025-12-20 13:04:18', NULL, '张组织', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (3, 'student1', '$2b$10$/Wp4XyMajp/pwX3VOVvC8OXceu5LEFi4i.tq8sRNb8JulH5BWJIcG', 'student', 'student1@example.com', NULL, 2, '2025-12-20 13:04:18', '1023004777', '李同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (4, 'organizer2', '$2b$10$Dn02uZ20zXnlcMgPZWdlfeIm9tcaR29IZ8vX1565WqbbxF.P/hNgi', 'organizer', 'organizer2@example.com', NULL, 2, '2025-12-20 13:04:18', NULL, '陈策划', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (5, 'organizer_whut', '12345', 'organizer', 'campus_org@example.com', NULL, 1, '2025-12-20 13:04:18', NULL, '武汉理工团委', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (6, 'student2', '12345', 'student', 'student2@example.com', NULL, 1, '2025-12-20 13:04:18', NULL, '周同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (7, 'student3', '12345', 'student', 'student3@example.com', NULL, 2, '2025-12-20 13:04:18', NULL, '王同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (8, 'student4', '12345', 'student', 'student4@example.com', NULL, 3, '2025-12-20 13:04:18', NULL, '刘同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (9, 'student5', '12345', 'student', 'student5@example.com', NULL, 4, '2025-12-20 13:04:18', NULL, '赵同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (10, 'student6', '12345', 'student', 'student6@example.com', NULL, 5, '2025-12-20 13:04:18', NULL, '孙同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (11, 'assistant_admin', '12345', 'admin', 'assistant_admin@example.com', NULL, 1, '2025-12-20 13:04:18', NULL, '助理管理员', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (12, 'organizer_media', '12345', 'organizer', 'media_org@example.com', NULL, 4, '2025-12-20 13:04:18', NULL, '融媒体中心', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (13, 'student7', '12345', 'student', 'student7@example.com', NULL, 6, '2025-12-20 13:04:18', NULL, '钱同学', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (14, 'LXY', '$2b$10$b5kqbDtePP7pqP.QuQCmBeA1ZUIzLbkREolpEtNjlkfPXt6Q23WXq', 'student', NULL, '12461209283', 1, '2025-12-24 00:09:28', '1023004555', 'LXY', NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- View structure for v_activity_comments
-- ----------------------------
DROP VIEW IF EXISTS `v_activity_comments`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_activity_comments` AS select `ac`.`comment_id` AS `comment_id`,`ac`.`activity_id` AS `activity_id`,`ac`.`user_id` AS `user_id`,`ac`.`rating` AS `rating`,`ac`.`content` AS `content`,`ac`.`created_at` AS `created_at`,`u`.`username` AS `username`,`a`.`activity_name` AS `event_title`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,1 AS `status` from ((`activity_comments` `ac` left join `users` `u` on((`ac`.`user_id` = `u`.`user_id`))) left join `activities` `a` on((`ac`.`activity_id` = `a`.`activity_id`)));

-- ----------------------------
-- View structure for v_activity_overview
-- ----------------------------
DROP VIEW IF EXISTS `v_activity_overview`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_activity_overview` AS select `a`.`activity_id` AS `id`,`a`.`activity_code` AS `code`,`a`.`activity_name` AS `title`,`a`.`Activity_description` AS `description`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,`a`.`end_time` AS `end_time`,`a`.`capacity` AS `capacity`,`a`.`type_id` AS `type_id`,`a`.`target_college_id` AS `target_college_id`,`a`.`organizer_id` AS `organizer_id`,(case when (now() < `a`.`start_time`) then 'upcoming' when (now() between `a`.`start_time` and `a`.`end_time`) then 'open' else 'ended' end) AS `status`,`u`.`username` AS `organizer_name`,`c`.`college_name` AS `target_college_name`,(select count(0) from `user_activity_apply` `ua` where ((`ua`.`activity_id` = `a`.`activity_id`) and (`ua`.`apply_status` in (0,1)))) AS `signed_up` from (((`activities` `a` left join `users` `u` on((`a`.`organizer_id` = `u`.`user_id`))) left join `colleges` `c` on((`a`.`target_college_id` = `c`.`college_id`))) left join `organizer_activity_creation` `oac` on((`oac`.`activity_id` = `a`.`activity_id`))) where (coalesce(`oac`.`admin_check`,1) = 1);

-- ----------------------------
-- View structure for v_user_points
-- ----------------------------
DROP VIEW IF EXISTS `v_user_points`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_user_points` AS select `u`.`user_id` AS `user_id`,coalesce(sum(`pt`.`change_amount`),0) AS `total_points` from (`users` `u` left join `point_transactions` `pt` on((`pt`.`user_id` = `u`.`user_id`))) group by `u`.`user_id`;

-- ----------------------------
-- View structure for v_user_registrations
-- ----------------------------
DROP VIEW IF EXISTS `v_user_registrations`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_user_registrations` AS select `ua`.`apply_id` AS `registration_id`,`ua`.`user_id` AS `user_id`,`ua`.`activity_id` AS `event_id`,`ua`.`apply_status` AS `apply_status`,(case `ua`.`apply_status` when 0 then 'pending' when 1 then 'approved' when 2 then 'rejected' when 3 then 'cancelled' else 'pending' end) AS `registration_status`,`ua`.`applied_at` AS `applied_at`,`a`.`activity_code` AS `event_code`,`a`.`activity_name` AS `event_title`,`a`.`location` AS `location`,`a`.`start_time` AS `start_time`,`a`.`end_time` AS `end_time`,`a`.`capacity` AS `capacity`,(case when (now() < `a`.`start_time`) then 'upcoming' when (now() between `a`.`start_time` and `a`.`end_time`) then 'open' else 'ended' end) AS `event_status`,`org`.`username` AS `organizer_name` from ((`user_activity_apply` `ua` join `activities` `a` on((`ua`.`activity_id` = `a`.`activity_id`))) left join `users` `org` on((`a`.`organizer_id` = `org`.`user_id`)));

SET FOREIGN_KEY_CHECKS = 1;
