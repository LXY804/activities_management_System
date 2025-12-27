-- 级联删除用户时，需要先删除的关联表
-- 注意：这个文件仅作为参考，实际删除逻辑在代码中实现

-- 需要删除的关联数据（按顺序）：
-- 1. user_activity_apply (用户活动报名)
-- 2. activity_comments (活动评论)
-- 3. gift_orders (礼品订单)
-- 4. gift_feedback (礼品反馈)
-- 5. point_transactions (积分交易)
-- 6. forum_comments (论坛评论)
-- 7. forum_favorites (论坛收藏)
-- 8. forum_posts (论坛帖子)
-- 9. announcement_confirmations (公告确认)
-- 10. user_schedules (用户日程)
-- 11. activity_logs (操作日志，设置为 NULL)
-- 12. 最后删除 users 表

