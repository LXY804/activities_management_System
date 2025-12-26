<script setup>
  import ChatFloat from './components/ChatFloat.vue'
  </script>
  
  <template>
    <router-view />
    <!-- 悬浮聊天机器人 -->
    <ChatFloat />
  </template>

<style>
@import url('https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;600&family=Nunito:wght@400;500;600;700&display=swap');

:root {
  --brand-lime: #b6ff82;
  --brand-emerald: #66e7b1;
  --brand-sky: #73d4ff;
  --brand-deep: #0f1d33;
  --brand-soft: #f4fff3;
  --card-surface: rgba(255, 255, 255, 0.92);
  --shadow-soft: 0 18px 45px rgba(69, 143, 119, 0.2);
  --shadow-card: 0 20px 60px rgba(81, 194, 255, 0.25);
  --radius-xl: 28px;
  --font-display: 'Baloo 2', 'Noto Sans SC', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  --font-body: 'Nunito', 'Noto Sans SC', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  --sidebar-width: clamp(180px, 14vw, 220px);
  --app-background: radial-gradient(circle at 20% 20%, #f5fff7, #ecfbff 60%, #f3f7ff 100%);
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: var(--font-body);
  background: var(--app-background);
  color: var(--brand-deep);
  min-height: 100vh;
}

#app {
  min-height: 100vh;
}

.page {
  position: relative;
  min-height: 100vh;
  padding-bottom: 40px;
  background: transparent;
  overflow: visible;
}

body.has-side-nav-layout .page,
body.has-side-nav-layout .my-activities,
body.has-side-nav-layout .admin-dashboard,
body.has-side-nav-layout .manage-layout .layout-content,
body.has-side-nav-layout .personal-center .content {
  padding-left: calc(var(--sidebar-width) + 28px);
  padding-right: clamp(18px, 5vw, 56px);
}

body.has-side-nav-layout .page .container,
body.has-side-nav-layout .page .content,
body.has-side-nav-layout .page .dashboard-shell,
body.has-side-nav-layout .page .main-layout,
body.has-side-nav-layout .page .cards,
body.has-side-nav-layout .page .hero__inner {
  margin-left: 0;
}

@media (max-width: 1024px) {
  body.has-side-nav-layout .page,
  body.has-side-nav-layout .my-activities,
  body.has-side-nav-layout .admin-dashboard,
  body.has-side-nav-layout .manage-layout .layout-content,
  body.has-side-nav-layout .personal-center .content {
    padding-left: 0;
  }
}

.page::before,
.page::after {
  content: '';
  position: absolute;
  width: clamp(220px, 32vw, 420px);
  height: clamp(220px, 32vw, 420px);
  background: radial-gradient(circle, rgba(255, 255, 255, 0.7), transparent 70%);
  border-radius: 40% 60% 50% 70% / 60% 40% 60% 40%;
  z-index: 0;
  filter: blur(0.5px);
}

.page::before {
  top: -120px;
  right: -80px;
}

.page::after {
  bottom: -160px;
  left: -100px;
}

.page > * {
  position: relative;
  z-index: 1;
}

.glass-panel {
  background: var(--card-surface);
  border-radius: var(--radius-xl);
  padding: 24px;
  box-shadow: var(--shadow-card);
  border: 1px solid rgba(255, 255, 255, 0.35);
  backdrop-filter: blur(16px);
}

.pill-button {
  border: none;
  border-radius: 999px;
  padding: 12px 28px;
  font-weight: 600;
  font-size: 16px;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  background: linear-gradient(120deg, var(--brand-lime), var(--brand-emerald));
  color: var(--brand-deep);
  box-shadow: 0 12px 20px rgba(102, 231, 177, 0.35);
}

.pill-button:focus-visible,
.pill-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 26px rgba(102, 231, 177, 0.45);
}

.section-heading {
  font-family: var(--font-display);
  font-size: clamp(28px, 4vw, 40px);
  color: var(--brand-deep);
  margin: 0;
}

.section-subtitle {
  margin: 8px 0 0;
  color: rgba(15, 29, 51, 0.7);
  font-size: 15px;
}

.stat-chip {
  display: inline-flex;
  padding: 8px 18px;
  border-radius: 999px;
  font-size: 14px;
  background: rgba(255, 255, 255, 0.85);
  box-shadow: 0 12px 25px rgba(111, 207, 151, 0.25);
  color: var(--brand-deep);
}
</style>

