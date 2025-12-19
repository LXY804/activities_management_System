import request from './request'

// 管理员手动触发数据库备份
export const manualBackup = () => request.post('/admin/backup')















