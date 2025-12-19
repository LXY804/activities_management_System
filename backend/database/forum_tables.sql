-- 论坛模块数据库表结构
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for forum_posts (论坛帖子表)
-- ----------------------------
DROP TABLE IF EXISTS `forum_posts`;
CREATE TABLE `forum_posts` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '发帖用户ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子内容',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '帖子图片',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`post_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_created_at`(`created_at`) USING BTREE,
  CONSTRAINT `forum_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for forum_comments (论坛评论表)
-- ----------------------------
DROP TABLE IF EXISTS `forum_comments`;
CREATE TABLE `forum_comments` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '帖子ID',
  `user_id` int NOT NULL COMMENT '评论用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_post_id`(`post_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `forum_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`post_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `forum_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for forum_favorites (论坛收藏表)
-- ----------------------------
DROP TABLE IF EXISTS `forum_favorites`;
CREATE TABLE `forum_favorites` (
  `favorite_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '帖子ID',
  `user_id` int NOT NULL COMMENT '收藏用户ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`favorite_id`) USING BTREE,
  UNIQUE INDEX `uk_post_user`(`post_id`, `user_id`) USING BTREE COMMENT '同一用户不能重复收藏同一帖子',
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `forum_favorites_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`post_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `forum_favorites_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;



-- 论坛帖子表添加审核字段
ALTER TABLE `forum_posts` 
ADD COLUMN `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0-待审核，1-已发布，2-已驳回' AFTER `updated_at`,
ADD COLUMN `admin_check` tinyint NULL DEFAULT NULL COMMENT '管理员审核状态：0-待审核，1-通过，2-驳回' AFTER `status`,
ADD COLUMN `check_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注' AFTER `admin_check`,
ADD COLUMN `checked_by` int NULL DEFAULT NULL COMMENT '审核管理员ID' AFTER `check_remark`,
ADD COLUMN `checked_at` datetime NULL DEFAULT NULL COMMENT '审核时间' AFTER `checked_by`,
ADD INDEX `idx_status`(`status`) USING BTREE,
ADD CONSTRAINT `forum_posts_ibfk_2` FOREIGN KEY (`checked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT;

-- 将现有帖子状态设为已发布（如果表已有数据）
UPDATE `forum_posts` SET `status` = 1, `admin_check` = 1 WHERE `status` = 0;


-- Table structure for announcements (系统公告表)
-- ----------------------------
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
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
  INDEX `idx_publisher`(`publisher_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_created_at`(`created_at`) USING BTREE,
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `announcements_ibfk_2` FOREIGN KEY (`checked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for announcement_confirmations (公告确认表)
-- ----------------------------
DROP TABLE IF EXISTS `announcement_confirmations`;
CREATE TABLE `announcement_confirmations` (
  `confirmation_id` int NOT NULL AUTO_INCREMENT,
  `announcement_id` int NOT NULL COMMENT '公告ID',
  `user_id` int NOT NULL COMMENT '确认用户ID',
  `confirmed_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '确认时间',
  PRIMARY KEY (`confirmation_id`) USING BTREE,
  UNIQUE INDEX `uk_announcement_user`(`announcement_id`, `user_id`) USING BTREE COMMENT '同一用户不能重复确认同一公告',
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `announcement_confirmations_ibfk_1` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`announcement_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `announcement_confirmations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


SET FOREIGN_KEY_CHECKS = 1;

