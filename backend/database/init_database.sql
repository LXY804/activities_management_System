-- 校园活动管理系统数据库初始化脚本（修复版）

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS activity_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE activity_management;

-- 为了能够多次初始化，先安全地删除视图与表
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_activity_overview;
DROP VIEW IF EXISTS v_user_registrations;
DROP VIEW IF EXISTS v_activity_comments;
DROP VIEW IF EXISTS v_user_points;

DROP TABLE IF EXISTS gift_feedback;
DROP TABLE IF EXISTS activity_point_rules;
DROP TABLE IF EXISTS point_transactions;
DROP TABLE IF EXISTS gift_orders;
DROP TABLE IF EXISTS gift_items;
DROP TABLE IF EXISTS user_schedules;
DROP TABLE IF EXISTS activity_comments;
DROP TABLE IF EXISTS user_activity_apply;
DROP TABLE IF EXISTS organizer_activity_creation;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS activity_types;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS colleges;

-- 1. 学院表 (colleges)
CREATE TABLE colleges (
    college_id INT PRIMARY KEY AUTO_INCREMENT,
    college_name VARCHAR(100) NOT NULL,
    college_code VARCHAR(20) NOT NULL UNIQUE
);

-- 2. 用户表 (users)
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  ROW_FORMAT = Dynamic;

-- 3. 活动类型表 (activity_types)
CREATE TABLE activity_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    description VARCHAR(200)
);

-- 4. 活动表 (activities)
CREATE TABLE activities (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_name VARCHAR(100) NOT NULL,
    activity_code VARCHAR(50) NOT NULL UNIQUE,
    Activity_description TEXT,
    type_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    target_college_id INT,
    capacity INT NOT NULL,
    organizer_id INT NOT NULL,
    cover_image VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES activity_types(type_id),
    FOREIGN KEY (target_college_id) REFERENCES colleges(college_id),
    FOREIGN KEY (organizer_id) REFERENCES users(user_id)
);

-- 5. 组织者创建活动表 (organizer_activity_creation)
CREATE TABLE organizer_activity_creation (
    creation_id INT PRIMARY KEY AUTO_INCREMENT,
    organizer_id INT NOT NULL,
    activity_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    admin_check TINYINT DEFAULT 0,
    check_remark VARCHAR(200),
    FOREIGN KEY (organizer_id) REFERENCES users(user_id),
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id)
);

-- 6. 用户报名表 (user_activity_apply)
CREATE TABLE user_activity_apply (
    apply_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    activity_id INT NOT NULL,
    apply_status TINYINT DEFAULT 0, -- 0:待审核, 1:通过, 2:拒绝, 3:取消
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id)
);

-- 7. 用户评论表 (activity_comments)
CREATE TABLE activity_comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 8. 用户日程表 (user_schedules)
CREATE TABLE user_schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(120) NOT NULL,
    description TEXT,
    schedule_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    status ENUM('pending', 'done') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 9. 礼品库 (gift_items)
CREATE TABLE gift_items (
    gift_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(120) NOT NULL,
    description TEXT,
    cover_image VARCHAR(255),
    points_cost INT NOT NULL,
    stock INT NOT NULL,
    delivery_type ENUM('online', 'offline', 'both') DEFAULT 'offline',
    status ENUM('pending', 'active', 'inactive', 'rejected', 'archived') DEFAULT 'pending',
    review_note VARCHAR(255),
    created_by INT NOT NULL,
    approved_by INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id)
);

-- 10. 礼品兑换订单 (gift_orders)
CREATE TABLE gift_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    gift_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    total_points INT NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'received', 'cancelled') DEFAULT 'pending',
    contact_name VARCHAR(80),
    contact_phone VARCHAR(30),
    delivery_method ENUM('online', 'offline') DEFAULT 'offline',
    pickup_location VARCHAR(255),
    note VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (gift_id) REFERENCES gift_items(gift_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 11. 积分流水 (point_transactions)
CREATE TABLE point_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    change_amount INT NOT NULL,
    action_type ENUM('earn', 'spend', 'adjust') DEFAULT 'earn',
    related_activity_id INT NULL,
    related_gift_id INT NULL,
    order_id INT NULL,
    remark VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (related_activity_id) REFERENCES activities(activity_id),
    FOREIGN KEY (related_gift_id) REFERENCES gift_items(gift_id),
    FOREIGN KEY (order_id) REFERENCES gift_orders(order_id)
);

-- 12. 礼品反馈 (gift_feedback)
CREATE TABLE gift_feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_feedback_order (order_id),
    FOREIGN KEY (order_id) REFERENCES gift_orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 13. 活动积分规则 (activity_point_rules)
CREATE TABLE activity_point_rules (
    rule_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    organizer_id INT NOT NULL,
    action_label VARCHAR(60) NOT NULL,
    points_value INT NOT NULL,
    description VARCHAR(255),
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_activity_action (activity_id, action_label),
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id),
    FOREIGN KEY (organizer_id) REFERENCES users(user_id)
);

-- ========= 插入初始数据 =========

INSERT INTO colleges (college_name, college_code) VALUES
('计算机学院', 'CS01'),
('电子信息学院', 'EE01'),
('管理学院', 'MG01'),
('交通与物流工程学院', 'TW01'),
('艺术设计学院', 'ART01'),
('自动化学院', 'AU01');

INSERT INTO users (user_id, username, password, role, email, college_id, real_name)
VALUES
(1, 'admin', '12345', 'admin', 'admin@example.com', 1, '管理员'),
(2, 'organizer1', '12345', 'organizer', 'organizer1@example.com', 1, '张组织'),
(3, 'student1', '12345', 'student', 'student1@example.com', 2, '李同学'),
(4, 'organizer2', '12345', 'organizer', 'organizer2@example.com', 2, '陈策划'),
(5, 'organizer_whut', '12345', 'organizer', 'campus_org@example.com', 1, '武汉理工团委'),
(6, 'student2', '12345', 'student', 'student2@example.com', 1, '周同学'),
(7, 'student3', '12345', 'student', 'student3@example.com', 2, '王同学'),
(8, 'student4', '12345', 'student', 'student4@example.com', 3, '刘同学'),
(9, 'student5', '12345', 'student', 'student5@example.com', 4, '赵同学'),
(10, 'student6', '12345', 'student', 'student6@example.com', 5, '孙同学'),
(11, 'assistant_admin', '12345', 'admin', 'assistant_admin@example.com', 1, '助理管理员'),
(12, 'organizer_media', '12345', 'organizer', 'media_org@example.com', 4, '融媒体中心'),
(13, 'student7', '12345', 'student', 'student7@example.com', 6, '钱同学');

ALTER TABLE users AUTO_INCREMENT = 14;

INSERT INTO activity_types (type_id, type_name, description) VALUES
(1, '学术讲座', '学术类分享与讲座'),
(2, '竞赛活动', '编程、创新等竞赛'),
(3, '志愿服务', '公益志愿者活动'),
(4, '体育赛事', '校级体育赛事与体验'),
(5, '文化节', '艺术展演与校园文化活动'),
(6, '创新创业', '创新创业训练营与沙龙');

ALTER TABLE activity_types AUTO_INCREMENT = 7;

-- 核心修复：第11行补齐了参数 (增加了容量和组织者ID)
INSERT INTO activities (activity_id, activity_name, activity_code, Activity_description, type_id, start_time, end_time, location, target_college_id, capacity, organizer_id, cover_image) VALUES 
(1, 'AI技术讲座', 'ACT001', '邀请知名专家讲解人工智能最新技术发展', 1, '2024-12-15 14:00:00', '2024-12-15 16:00:00', '大礼堂', 1, 200, 2, NULL),
(2, '编程挑战赛', 'ACT002', '面向全校的算法编程竞赛', 2, '2025-01-05 09:00:00', '2025-01-05 18:00:00', '创新实验室', 2, 150, 2, NULL),
(3, '珞狮体育嘉年华', 'ACT003', '武汉理工田径场全天候体育嘉年华，包含飞盘、路跑、桨板等体验', 4, '2025-03-20 08:30:00', '2025-03-20 17:30:00', '余家头校区田径场', 2, 500, 4, NULL),
(4, '东湖龙舟体验营', 'ACT004', '邀请龙舟队教练带来水上课程，面向所有院系开放', 4, '2025-04-12 09:00:00', '2025-04-12 15:00:00', '东湖风景区码头', 3, 120, 4, NULL),
(5, '武汉理工校史文化巡礼', 'ACT005', '以校史馆为起点，串联余区地标的沉浸式讲解路线', 5, '2025-04-28 14:00:00', '2025-04-28 17:00:00', '余家头校史馆', 1, 80, 5, NULL),
(6, '青春湖畔音乐节', 'ACT006', '南湖草坪大型民谣与电子音乐专场，邀请师生乐队同台', 5, '2025-05-18 18:30:00', '2025-05-18 22:00:00', '南湖露天舞台', 4, 400, 5, NULL),
(7, '智能车创客营', 'ACT007', '智能车队与实验室联合举办的实训营，提供器材与导师辅导', 6, '2025-06-08 09:30:00', '2025-06-08 17:30:00', '智能制造实验室', 1, 60, 2, NULL),
(8, '光谷博物馆夜游', 'ACT008', '与光谷科技馆合作的夜间科普专场，含讲解与互动展区', 5, '2025-06-22 19:00:00', '2025-06-22 22:00:00', '湖北省科技馆', 3, 200, 5, NULL),
(9, '未来材料研讨沙龙', 'ACT009', '材料学院教授分享前沿成果，并邀请研究生参与圆桌讨论', 1, '2025-07-02 15:00:00', '2025-07-02 18:00:00', '材料科学楼A302', 1, 100, 1, NULL),
(10, '军运会志愿者培训营', 'ACT010', '志愿服务中心组织的赛会志愿技能培训', 3, '2025-07-15 13:30:00', '2025-07-15 17:30:00', '航海楼报告厅', 5, 250, 4, NULL),
(11, '国际文化交流日', 'ACT011', '留学生与本土社团联合布展，体验全球文化市集', 5, '2025-07-26 10:00:00', '2025-07-26 18:00:00', '南湖会堂', 4, 300, 12, NULL),
(12, '创客孵化工作坊', 'ACT012', '创客导师带来武汉理工特色的创业实战演练', 6, '2025-08-03 09:00:00', '2025-08-03 16:30:00', '创新创业基地', 1, 80, 2, NULL),
(13, '智慧交通创新周', 'ACT013', '交通学院联合企业开展未来交通方案共创周，含沙龙与体验展。', 6, '2026-03-10 09:30:00', '2026-03-15 17:30:00', '南湖交通创新中心', 4, 180, 2, NULL),
(14, '沿江城市徒步嘉年华', 'ACT014', '组织 30 公里江城徒步路线，沿途设置文化补给站与伙伴任务。', 4, '2026-04-20 07:00:00', '2026-04-20 18:00:00', '武汉江滩集合点', 2, 600, 4, NULL),
(15, '未来能源开放实验室', 'ACT015', '能源学院开放氢能与储能实验平台，安排导师带队深度体验。', 1, '2026-05-08 13:30:00', '2026-05-08 18:30:00', '能源大楼B1实验区', 1, 90, 1, NULL),
(16, '校园可持续设计黑客松', 'ACT016', '跨专业团队 36 小时共创低碳校园解决方案，配套导师辅导。', 2, '2026-06-12 09:00:00', '2026-06-13 21:00:00', '南湖创客空间', 5, 200, 5, NULL);

ALTER TABLE activities AUTO_INCREMENT = 17;

INSERT INTO organizer_activity_creation (organizer_id, activity_id, admin_check, check_remark) VALUES
(2, 1, 1, '已完成资料审核'),
(2, 2, 1, '教务处备案通过'),
(4, 3, 1, '体育部联合发布'),
(4, 4, 0, '等待水上安全审批'),
(5, 5, 1, '文化宣传部联动'),
(5, 6, 1, '通过'),
(2, 7, 1, '实验室开放日'),
(5, 8, 1, '科普基地合作'),
(1, 9, 1, '材料学院研讨会'),
(4, 10, 0, '需补充志愿者名单'),
(12, 11, 1, '留学生办公室联动'),
(2, 12, 1, '创新创业学院支持');

INSERT INTO user_activity_apply (user_id, activity_id, apply_status, applied_at) VALUES
(3, 1, 1, '2024-12-10 09:00:00'),
(6, 1, 1, '2024-12-11 10:15:00'),
(7, 2, 0, '2024-12-22 14:20:00'),
(8, 3, 1, '2025-02-28 16:45:00'),
(3, 3, 2, '2025-03-02 09:30:00'),
(9, 4, 0, '2025-03-18 12:10:00'),
(6, 5, 1, '2025-04-10 08:40:00'),
(7, 6, 1, '2025-04-25 11:05:00'),
(8, 6, 1, '2025-04-26 15:18:00'),
(9, 7, 1, '2025-05-20 13:55:00'),
(10, 8, 0, '2025-05-28 19:10:00'),
(6, 9, 1, '2025-06-20 09:32:00'),
(7, 9, 1, '2025-06-21 10:02:00'),
(8, 10, 0, '2025-06-22 16:48:00'),
(9, 10, 1, '2025-06-23 18:12:00'),
(10, 11, 1, '2025-07-05 09:15:00'),
(6, 11, 1, '2025-07-06 14:00:00'),
(7, 12, 0, '2025-07-20 16:30:00'),
(13, 12, 1, '2025-07-22 10:18:00');

INSERT INTO activity_comments (activity_id, user_id, content, rating) VALUES
(1, 3, '比赛组织得很好，题目有挑战性。', 4),
(1, 6, '讲座中分享的案例贴近武汉理工的科研方向。', 5),
(2, 7, '赛题覆盖算法与工程实现，强烈推荐参加。', 5),
(3, 8, '嘉年华的飞盘体验太棒了，期待明年继续。', 5),
(5, 6, '讲解老师耐心，路线紧凑，了解了很多校史细节。', 4),
(6, 7, '舞台灯光和音响配置专业，就是排队入场稍慢。', 4),
(7, 9, '导师手把手指导焊接与调试，新手也能快速入门。', 5),
(8, 10, '夜场讲解氛围感很好，互动装置很酷。', 4),
(9, 6, '沙龙嘉宾回答问题很细致，收获满满。', 5),
(10, 9, '培训内容覆盖突发情况处理，对志愿者很实用。', 5),
(11, 10, '文化展位太丰富了，咖啡和音乐都超赞。', 5),
(12, 13, '导师拆解商业模型思路清晰，干货拉满。', 5);

INSERT INTO user_schedules (user_id, title, description, schedule_date, start_time, end_time, status) VALUES
(3, 'AI 技术讲座', '准备问题并提前到场签到', '2024-12-15', '13:30:00', '16:30:00', 'done'),
(6, '编程挑战赛热身', '与队友调试算法模板', '2025-01-04', '18:00:00', '21:00:00', 'pending'),
(7, '珞狮嘉年华志愿岗', '负责飞盘体验报名引导', '2025-03-20', '08:00:00', '12:00:00', 'done'),
(8, '东湖龙舟体验营', '上午训练 下午体验赛', '2025-04-12', '08:30:00', '15:30:00', 'pending'),
(9, '校史文化巡礼', '拍摄活动花絮短片', '2025-04-28', '13:00:00', '18:00:00', 'pending'),
(10, '湖畔音乐节排练', '与乐队进行最终彩排', '2025-05-18', '15:00:00', '17:30:00', 'done'),
(6, '智能车创客营', '完成传感器调试任务', '2025-06-08', '09:00:00', '17:30:00', 'pending'),
(7, '博物馆夜游', '组织同学签到入场', '2025-06-22', '18:30:00', '22:30:00', 'pending'),
(8, '材料研讨沙龙', '准备圆桌分享发言稿', '2025-07-02', '14:00:00', '18:30:00', 'pending'),
(9, '志愿者培训营', '提交值岗意向并参与演练', '2025-07-15', '13:00:00', '18:00:00', 'pending'),
(10, '国际文化交流日主持', '彩排流程 + 控场', '2025-07-25', '14:00:00', '20:00:00', 'pending'),
(13, '创客孵化工作坊', '准备商业画布资料', '2025-08-02', '13:00:00', '15:00:00', 'pending');

INSERT INTO gift_items (gift_id, title, description, cover_image, points_cost, stock, delivery_type, status, created_by, approved_by)
VALUES
(1, '校园定制水杯', '双层玻璃杯，限量校徽款。', '/uploads/gift_cup.jpg', 120, 80, 'offline', 'active', 2, 1),
(2, '活动加油礼包', '含能量棒、贴纸等小礼物，适合户外活动。', '/uploads/gift_energy.jpg', 80, 120, 'both', 'active', 2, 1),
(3, '线上音乐会门票', '赞助商提供的线上演唱会兑换码。', '/uploads/gift_music.jpg', 200, 40, 'online', 'active', 1, 1),
(4, '珞狮校园帆布包', '武汉理工手绘地标帆布包，含胸章贴纸组合。', '/uploads/gift_bag.jpg', 90, 150, 'both', 'active', 4, 1),
(5, '余区纪念徽章套装', '校史馆推出的四枚限量徽章，附纪念卡。', '/uploads/gift_badge.jpg', 60, 220, 'offline', 'active', 5, 1),
(6, '龙舟体验券', '可在东湖龙舟基地兑换一次体验课程。', '/uploads/gift_dragonboat.jpg', 180, 50, 'offline', 'pending', 4, NULL),
(7, '夜游科普手账', '夜游活动限定手账与荧光贴组合。', '/uploads/gift_notebook.jpg', 70, 160, 'both', 'active', 5, 1),
(8, '材料实验室 VIP 参观券', '可预约带队进入材料学院示范实验室。', '/uploads/gift_labpass.jpg', 150, 30, 'offline', 'inactive', 1, 1),
(9, '校园咖啡券', '南湖咖啡吧任意饮品一杯，附限定杯套。', '/uploads/gift_coffee.jpg', 65, 200, 'offline', 'active', 12, 1);

ALTER TABLE gift_items AUTO_INCREMENT = 10;

INSERT INTO point_transactions (user_id, change_amount, action_type, related_activity_id, remark)
VALUES
(3, 200, 'earn', 1, '参与 AI 技术讲座'),
(3, -80, 'spend', NULL, '兑换活动加油礼包预留'),
(6, 150, 'earn', 2, '编程挑战赛二等奖'),
(7, 120, 'earn', 3, '珞狮体育嘉年华志愿者'),
(8, 100, 'earn', 4, '龙舟体验营签到完成'),
(9, 80, 'earn', 5, '校史巡礼记录稿提交'),
(7, -120, 'spend', NULL, '兑换珞狮校园帆布包'),
(6, -200, 'spend', NULL, '兑换线上音乐会门票'),
(8, -70, 'spend', NULL, '兑换夜游科普手账'),
(9, 60, 'earn', 9, '材料沙龙志愿摄影'),
(10, 90, 'earn', 6, '湖畔音乐节舞台演出'),
(10, -90, 'spend', NULL, '兑换余区纪念徽章套装'),
(3, 50, 'adjust', NULL, '管理员补发签到积分'),
(10, 110, 'earn', 11, '国际文化交流日主持'),
(6, 130, 'earn', 12, '创客孵化优秀方案'),
(6, -120, 'spend', NULL, '兑换校园定制水杯'),
(13, 140, 'earn', 12, '孵化营商业画布评优');

-- 核心修复：第4行和第9行 delivery_method 写法错误 (ENUM只接受 online/offline，不接受 both)
INSERT INTO gift_orders (gift_id, user_id, quantity, total_points, status, contact_name, contact_phone, delivery_method, pickup_location)
VALUES
(2, 3, 1, 80, 'processing', '李同学', '18800001111', 'offline', '学生事务中心'),
(4, 7, 1, 120, 'shipped', '王同学', '18800002222', 'offline', '余家头校史馆文创角'),
(5, 10, 1, 90, 'received', '孙同学', '18800003333', 'offline', '校史馆服务台'),
(7, 8, 1, 70, 'received', '刘同学', '18800004444', 'offline', '邮寄至学生公寓'),
(1, 6, 2, 240, 'pending', '周同学', '18800005555', 'offline', '南湖生活区包裹点'),
(3, 6, 1, 200, 'processing', '周同学', '18800005555', 'online', NULL),
(6, 9, 1, 180, 'pending', '赵同学', '18800006666', 'offline', '东湖龙舟基地前台'),
(9, 10, 2, 130, 'received', '孙同学', '18800003333', 'offline', '南湖咖啡吧'),
(4, 13, 1, 90, 'processing', '钱同学', '18800007777', 'offline', '邮寄至创业学院');

INSERT INTO gift_feedback (order_id, user_id, rating, content) VALUES
(2, 7, 5, '帆布包质感很好，收到第二天就背去上课了。'),
(3, 10, 4, '徽章很精致，如果能再附包装袋就更好了。'),
(4, 8, 5, '手账纸质顺滑，荧光贴很有夜游氛围。'),
(8, 10, 5, '咖啡券兑换方便，限定杯套很有收藏价值。');

INSERT INTO activity_point_rules (activity_id, organizer_id, action_label, points_value, description, is_active) VALUES
(1, 2, '签到参与', 50, '按时到场并完成二维码签到', 1),
(1, 2, '现场提问', 30, '向嘉宾提问并被采纳', 1),
(2, 2, '提交作品', 120, '按要求提交完整作品', 1),
(3, 4, '完成挑战站点', 80, '体育嘉年华完成全部体验盖章', 1),
(5, 5, '集章打卡', 60, '巡礼路线集齐三枚章', 1),
(7, 2, '实验任务达成', 150, '独立完成智能车调试任务', 1),
(10, 4, '培训考核通过', 90, '完成志愿者情景考核', 1),
(11, 12, '文化互动分享', 70, '在国际文化交流日分享家乡文化', 1),
(12, 2, '商业画布提交', 130, '完成创客营商业画布评审', 1);

SET FOREIGN_KEY_CHECKS = 1;

-- ========= 视图定义 =========

CREATE VIEW v_activity_overview AS
SELECT 
    a.activity_id AS id,
    a.activity_code AS code,
    a.activity_name AS title,
    a.Activity_description AS description,
    a.location,
    a.start_time,
    a.end_time,
    a.capacity,
    a.type_id,
    a.target_college_id,
    a.organizer_id,
    CASE
        WHEN NOW() < a.start_time THEN 'upcoming'
        WHEN NOW() BETWEEN a.start_time AND a.end_time THEN 'open'
        ELSE 'ended'
    END AS status,
    u.username AS organizer_name,
    c.college_name AS target_college_name,
    (
        SELECT COUNT(*)
        FROM user_activity_apply ua
        WHERE ua.activity_id = a.activity_id AND ua.apply_status IN (0, 1)
    ) AS signed_up
FROM activities a
LEFT JOIN users u ON a.organizer_id = u.user_id
LEFT JOIN colleges c ON a.target_college_id = c.college_id
LEFT JOIN organizer_activity_creation oac ON oac.activity_id = a.activity_id
WHERE COALESCE(oac.admin_check, 1) = 1;

CREATE VIEW v_user_registrations AS
SELECT 
    ua.apply_id AS registration_id,
    ua.user_id,
    ua.activity_id AS event_id,
    ua.apply_status,
    CASE ua.apply_status
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'approved'
        WHEN 2 THEN 'rejected'
        WHEN 3 THEN 'cancelled'
        ELSE 'pending'
    END AS registration_status,
    ua.applied_at,
    a.activity_code AS event_code,
    a.activity_name AS event_title,
    a.location,
    a.start_time,
    a.end_time,
    a.capacity,
    CASE
        WHEN NOW() < a.start_time THEN 'upcoming'
        WHEN NOW() BETWEEN a.start_time AND a.end_time THEN 'open'
        ELSE 'ended'
    END AS event_status,
    org.username AS organizer_name
FROM user_activity_apply ua
INNER JOIN activities a ON ua.activity_id = a.activity_id
LEFT JOIN users org ON a.organizer_id = org.user_id;

CREATE VIEW v_activity_comments AS
SELECT
    ac.comment_id,
    ac.activity_id,
    ac.user_id,
    ac.rating,
    ac.content,
    ac.created_at,
    u.username,
    a.activity_name AS event_title,
    a.location,
    a.start_time,
    1 AS status
FROM activity_comments ac
LEFT JOIN users u ON ac.user_id = u.user_id
LEFT JOIN activities a ON ac.activity_id = a.activity_id;

CREATE VIEW v_user_points AS
SELECT
    u.user_id,
    COALESCE(SUM(pt.change_amount), 0) AS total_points
FROM users u
LEFT JOIN point_transactions pt ON pt.user_id = u.user_id
GROUP BY u.user_id;