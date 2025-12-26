import { createRouter, createWebHistory } from 'vue-router'

const Home = () => import('../views/Home.vue')
const EventPromotion = () => import('../views/EventPromotion.vue')
const EventList = () => import('../views/EventList.vue')
const EventInfo = () => import('../views/EventInfo.vue')
const EventComments = () => import('../views/EventComments.vue')
const EventEvaluate = () => import('../views/EventEvaluate.vue')
const NewsList = () => import('../views/NewsList.vue')
const ForumMain = () => import('../views/ForumMain.vue')
const Login = () => import('../views/Login.vue')
const PersonalCenter = () => import('../views/PersonalCenter.vue')
const MyActivities = () => import('../views/MyActivities.vue')
const PersonalInfo = () => import('../views/PersonalInfo.vue')
const MyComments = () => import('../views/MyComments.vue')
const Statistics = () => import('../views/Statistics.vue')
const OrganizerManage = () => import('../views/OrganizerManage.vue')
const AdminDashboard = () => import('../views/AdminDashboard.vue')
const Forum = () => import('../views/Forum.vue')
const MyPosts = () => import('../views/MyPosts.vue')
const MyCommentedPosts = () => import('../views/MyCommentedPosts.vue')
const Announcements = () => import('../views/Announcements.vue')
const Rewards = () => import('../views/Rewards.vue')

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/home', name: 'HomePage', component: Home },
  { path: '/promotion', name: 'EventPromotion', component: EventPromotion },
  { path: '/rewards', name: 'Rewards', component: Rewards },
  { path: '/events', name: 'EventList', component: EventList },
  { path: '/forum', name: 'ForumMain', component: ForumMain },
  { path: '/event/:id', name: 'EventInfo', component: EventInfo },
  { path: '/event/:id/comments', name: 'EventComments', component: EventComments },
  { path: '/event/:id/evaluate', name: 'EventEvaluate', component: EventEvaluate },
  { path: '/news', name: 'NewsList', component: NewsList },
  { path: '/event', redirect: '/events' },
  { path: '/login', name: 'Login', component: Login },
  { path: '/organizer/manage', name: 'OrganizerManage', component: OrganizerManage },
  { path: '/admin/dashboard', name: 'AdminDashboard', component: AdminDashboard },
  { path: '/forum', name: 'Forum', component: Forum },
  { path: '/forum/post', name: 'ForumPost', component: Forum },
  { path: '/forum/my-posts', name: 'MyPosts', component: MyPosts },
  { path: '/forum/my-commented', name: 'MyCommentedPosts', component: MyCommentedPosts },
  { path: '/announcements', name: 'Announcements', component: Announcements },
  { 
    path: '/personal', 
    component: PersonalCenter,
    redirect: '/personal/activities',
    children: [
      { path: 'info', name: 'PersonalInfo', component: PersonalInfo },
      { path: 'activities', name: 'MyActivities', component: MyActivities },
      { path: 'comments', name: 'MyComments', component: MyComments },
      { path: 'statistics', name: 'Statistics', component: Statistics }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫：检查登录状态
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  const storedFlag = localStorage.getItem('isLoggedIn')
  const isLoggedIn = !!token || storedFlag === 'true'
  const userRole = localStorage.getItem('userRole')

  if (to.path.startsWith('/personal') && !isLoggedIn) {
    next('/login')
    return
  }

  if (to.path.startsWith('/organizer') && userRole !== 'organizer') {
    next('/login')
    return
  }

  if (to.path.startsWith('/admin') && userRole !== 'admin') {
    next('/login')
    return
  }

  next()
})

export default router





