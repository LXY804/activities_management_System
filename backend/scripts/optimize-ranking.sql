-- ========================================
-- 积分排行榜性能优化脚本
-- ========================================

-- 1. 检查现有索引
-- SHOW INDEXES FROM point_transactions;
-- SHOW INDEXES FROM users;

-- 2. 为 point_transactions 表添加复合索引（如果不存在）
-- user_id 已有索引，但我们可以添加更优化的索引组合
ALTER TABLE point_transactions ADD INDEX idx_user_points (user_id, change_amount);

-- 3. 为 users 表的 role 字段添加索引（可选，用于后续过滤）
ALTER TABLE users ADD INDEX idx_role (role);

-- 4. 验证查询性能
-- 测试查询（不使用视图，直接聚合）
EXPLAIN SELECT 
  u.user_id AS userId,
  u.username,
  u.role AS userType,
  u.image AS avatar,
  COALESCE(SUM(pt.change_amount), 0) AS totalPoints
FROM users u
LEFT JOIN point_transactions pt ON u.user_id = pt.user_id
GROUP BY u.user_id, u.username, u.role, u.image
HAVING COALESCE(SUM(pt.change_amount), 0) > 0
ORDER BY totalPoints DESC, u.user_id ASC
LIMIT 500;

-- 5. 对比：原始查询（使用视图）
-- EXPLAIN SELECT * FROM v_user_points ORDER BY total_points DESC;

-- 6. 检查索引是否有效
-- 如果执行计划中看到 'Using index' 或 'Using index condition'，说明索引工作正常
