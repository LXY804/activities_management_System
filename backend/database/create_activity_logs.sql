-- 创建 activity_logs 表（如果不存在）
-- 用于记录系统操作日志

CREATE TABLE IF NOT EXISTS `activity_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL COMMENT '触发操作的用户ID，可为空',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '触发者用户名',
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '动作描述，如 GET /api/events',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'HTTP 方法',
  `route` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '路由路径（不含查询参数）',
  `status_code` int NOT NULL COMMENT '响应状态码',
  `success` tinyint NOT NULL DEFAULT 1 COMMENT '是否成功 (1-成功 0-失败)',
  `duration_ms` int NULL DEFAULT NULL COMMENT '请求耗时 (ms)',
  `ip_address` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户端 IP',
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户端 UA',
  `request_payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求负载（过滤敏感字段）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_log_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_log_route`(`route` ASC) USING BTREE,
  INDEX `idx_log_method`(`method` ASC) USING BTREE,
  INDEX `idx_log_status`(`status_code` ASC) USING BTREE,
  INDEX `idx_log_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

