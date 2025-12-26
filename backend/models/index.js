// 导入所有模型
const User = require('./User')
const College = require('./College')
const Activity = require('./Activity')
const ActivityType = require('./ActivityType')
const Announcement = require('./Announcement')
const Comment = require('./Comment')
const UserActivityApply = require('./UserActivityApply')
const Message = require('./Message')
const AnnouncementConfirmation = require('./AnnouncementConfirmation')
const OrganizerActivityCreation = require('./OrganizerActivityCreation')
const ForumPost = require('./ForumPost')
const ForumComment = require('./ForumComment')
const News = require('./News')
const Schedule = require('./Schedule')
const GiftItem = require('./GiftItem')
const GiftOrder = require('./GiftOrder')
const RecUserTopn = require('./RecUserTopn')

// User <-> College (多对一)
User.belongsTo(College, {
  foreignKey: 'college_id',
  as: 'college'
})
College.hasMany(User, {
  foreignKey: 'college_id',
  as: 'users'
})

// User <-> Activity (组织者)
Activity.belongsTo(User, {
  foreignKey: 'organizer_id',
  as: 'organizer'
})
User.hasMany(Activity, {
  foreignKey: 'organizer_id',
  as: 'organizedActivities'
})

// Activity <-> College (目标学院)
Activity.belongsTo(College, {
  foreignKey: 'target_college_id',
  as: 'targetCollege'
})
College.hasMany(Activity, {
  foreignKey: 'target_college_id',
  as: 'targetActivities'
})

// User <-> Announcement (发布者)
Announcement.belongsTo(User, {
  foreignKey: 'publisher_id',
  as: 'publisher'
})
User.hasMany(Announcement, {
  foreignKey: 'publisher_id',
  as: 'publishedAnnouncements'
})

// User <-> Announcement (审核者)
Announcement.belongsTo(User, {
  foreignKey: 'checked_by',
  as: 'checker'
})
User.hasMany(Announcement, {
  foreignKey: 'checked_by',
  as: 'checkedAnnouncements'
})

// User <-> UserActivityApply (报名)
UserActivityApply.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(UserActivityApply, {
  foreignKey: 'user_id',
  as: 'applications'
})

// Activity <-> UserActivityApply
UserActivityApply.belongsTo(Activity, {
  foreignKey: 'activity_id',
  as: 'activity'
})
Activity.hasMany(UserActivityApply, {
  foreignKey: 'activity_id',
  as: 'applications'
})

// Activity <-> Comment (评论)
Comment.belongsTo(Activity, {
  foreignKey: 'activity_id',
  as: 'activity'
})
Activity.hasMany(Comment, {
  foreignKey: 'activity_id',
  as: 'comments'
})

// User <-> Comment (评论者)
Comment.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(Comment, {
  foreignKey: 'user_id',
  as: 'comments'
})

// Announcement <-> AnnouncementConfirmation
AnnouncementConfirmation.belongsTo(Announcement, {
  foreignKey: 'announcement_id',
  as: 'announcement'
})
Announcement.hasMany(AnnouncementConfirmation, {
  foreignKey: 'announcement_id',
  as: 'confirmations'
})

// User <-> AnnouncementConfirmation
AnnouncementConfirmation.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(AnnouncementConfirmation, {
  foreignKey: 'user_id',
  as: 'confirmations'
})

// Activity <-> ActivityType
Activity.belongsTo(ActivityType, {
  foreignKey: 'type_id',
  as: 'type'
})
ActivityType.hasMany(Activity, {
  foreignKey: 'type_id',
  as: 'activities'
})

// Activity <-> OrganizerActivityCreation
OrganizerActivityCreation.belongsTo(Activity, {
  foreignKey: 'activity_id',
  as: 'activity'
})
Activity.hasOne(OrganizerActivityCreation, {
  foreignKey: 'activity_id',
  as: 'creation'
})

// User <-> OrganizerActivityCreation
OrganizerActivityCreation.belongsTo(User, {
  foreignKey: 'organizer_id',
  as: 'organizer'
})
User.hasMany(OrganizerActivityCreation, {
  foreignKey: 'organizer_id',
  as: 'activityCreations'
})

// User <-> ForumPost
ForumPost.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'author'
})
User.hasMany(ForumPost, {
  foreignKey: 'user_id',
  as: 'forumPosts'
})

// User <-> ForumPost (审核者)
ForumPost.belongsTo(User, {
  foreignKey: 'checked_by',
  as: 'checker'
})

// ForumPost <-> ForumComment
ForumComment.belongsTo(ForumPost, {
  foreignKey: 'post_id',
  as: 'post'
})
ForumPost.hasMany(ForumComment, {
  foreignKey: 'post_id',
  as: 'comments'
})

// User <-> ForumComment
ForumComment.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'author'
})
User.hasMany(ForumComment, {
  foreignKey: 'user_id',
  as: 'forumComments'
})

// User <-> News
News.belongsTo(User, {
  foreignKey: 'publisher_id',
  as: 'publisher'
})
User.hasMany(News, {
  foreignKey: 'publisher_id',
  as: 'news'
})

// User <-> Schedule
Schedule.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(Schedule, {
  foreignKey: 'user_id',
  as: 'schedules'
})

// User <-> GiftItem (创建者)
GiftItem.belongsTo(User, {
  foreignKey: 'created_by',
  as: 'creator'
})
User.hasMany(GiftItem, {
  foreignKey: 'created_by',
  as: 'createdGifts'
})

// User <-> GiftItem (审核者)
GiftItem.belongsTo(User, {
  foreignKey: 'approved_by',
  as: 'approver'
})

// GiftItem <-> GiftOrder
GiftOrder.belongsTo(GiftItem, {
  foreignKey: 'gift_id',
  as: 'gift'
})
GiftItem.hasMany(GiftOrder, {
  foreignKey: 'gift_id',
  as: 'orders'
})

// User <-> GiftOrder
GiftOrder.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(GiftOrder, {
  foreignKey: 'user_id',
  as: 'giftOrders'
})

// RecUserTopn <-> User
RecUserTopn.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user'
})
User.hasMany(RecUserTopn, {
  foreignKey: 'user_id',
  as: 'recommendations'
})

// RecUserTopn <-> Activity
RecUserTopn.belongsTo(Activity, {
  foreignKey: 'activity_id',
  as: 'activity'
})
Activity.hasMany(RecUserTopn, {
  foreignKey: 'activity_id',
  as: 'userRecommendations'
})

module.exports = {
  User,
  College,
  Activity,
  ActivityType,
  Announcement,
  Comment,
  UserActivityApply,
  Message,
  AnnouncementConfirmation,
  OrganizerActivityCreation,
  ForumPost,
  ForumComment,
  News,
  Schedule,
  GiftItem,
  GiftOrder,
  RecUserTopn
}

