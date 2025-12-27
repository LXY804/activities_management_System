-- ============================================
-- 删除活动表所有记录
-- ⚠️ 警告：此操作不可恢复，请谨慎使用！
-- ============================================

-- 开始事务（如果出错可以回滚）
START TRANSACTION;

-- 1. 删除 organizer_activity_creation 表中的所有关联记录
DELETE FROM organizer_activity_creation;

-- 2. 删除 user_activity_apply 表中的所有报名记录
DELETE FROM user_activity_apply;

-- 3. 删除 activity_comments 表中的所有评论
DELETE FROM activity_comments;

-- 4. 删除 activity_point_rules 表中的所有积分规则
DELETE FROM activity_point_rules;

-- 5. 删除 point_transactions 表中关联活动的积分交易记录
DELETE FROM point_transactions WHERE related_activity_id IS NOT NULL;

-- 6. 删除 activities 表中的所有活动记录
DELETE FROM activities;

-- 查看删除结果
SELECT 
    (SELECT COUNT(*) FROM activities) AS remaining_activities,
    (SELECT COUNT(*) FROM organizer_activity_creation) AS remaining_organizer_records,
    (SELECT COUNT(*) FROM user_activity_apply) AS remaining_apply_records,
    (SELECT COUNT(*) FROM activity_comments) AS remaining_comments,
    (SELECT COUNT(*) FROM activity_point_rules) AS remaining_rules;

-- 如果确认无误，执行 COMMIT;
-- 如果出错，执行 ROLLBACK;

-- COMMIT;
-- ROLLBACK;

