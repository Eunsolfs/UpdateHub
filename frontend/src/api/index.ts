import axios from 'axios'

const api = axios.create({
  baseURL: '/api/v1',
  timeout: 10000
})

// 请求拦截器
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  (response) => {
    return response.data
  },
  (error) => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          localStorage.removeItem('token')
          window.location.href = '/login'
          break
        case 403:
          console.error('Permission denied')
          break
        case 404:
          console.error('Resource not found')
          break
        case 500:
          console.error('Server error')
          break
      }
    }
    return Promise.reject(error)
  }
)

export default api

// 认证相关API
export const authAPI = {
  login: (username: string, password: string) =>
    api.post('/auth/login', { username, password }),
  logout: () => api.post('/auth/logout'),
  getCurrentUser: () => api.get('/auth/user'),
  changePassword: (oldPassword: string, newPassword: string) =>
    api.put('/auth/password', { old_password: oldPassword, new_password: newPassword })
}

// 软件管理API
export const softwareAPI = {
  getList: (offset = 0, limit = 10) =>
    api.get('/software', { params: { offset, limit } }),
  create: (data: any) => api.post('/software', data),
  update: (id: number, data: any) => api.put(`/software/${id}`, data),
  delete: (id: number) => api.delete(`/software/${id}`)
}

// 版本管理API
export const versionAPI = {
  create: (data: any) => api.post('/version', data),
  get: (id: number) => api.get(`/version/${id}`),
  updateStatus: (id: number, status: string) =>
    api.put(`/version/${id}/status`, { status }),
  rollback: (id: number, rollbackType: string, reason: string) =>
    api.post(`/version/${id}/rollback`, { rollback_type: rollbackType, reason }),
  getHistory: (id: number) => api.get(`/version/${id}/history`),
  switch: (id: number, targetVersionId: number, reason: string) =>
    api.post(`/version/${id}/switch`, { target_version_id: targetVersionId, reason }),
  delete: (id: number) => api.delete(`/version/${id}`)
}

// 文件上传API
export const uploadAPI = {
  init: (data: any) => api.post('/upload/init', data),
  uploadChunk: (formData: FormData) => api.post('/upload/chunk', formData),
  complete: (data: any) => api.post('/upload/complete', data),
  cancel: (taskId: string) => api.post('/upload/cancel', { task_id: taskId }),
  getStatus: (taskId: string) => api.get(`/upload/status/${taskId}`)
}

// 用户管理API
export const userAPI = {
  getList: (offset = 0, limit = 10) =>
    api.get('/users', { params: { offset, limit } }),
  create: (data: any) => api.post('/users', data),
  update: (id: number, data: any) => api.put(`/users/${id}`, data),
  delete: (id: number) => api.delete(`/users/${id}`),
  getRoles: () => api.get('/roles'),
  createRole: (data: any) => api.post('/roles', data),
  updateRole: (id: number, data: any) => api.put(`/roles/${id}`, data)
}

// 客户端管理API
export const clientAPI = {
  register: (data: any) => api.post('/client/register', data),
  heartbeat: (data: any) => api.post('/client/heartbeat', data),
  getList: (softwareId?: number, status?: string, offset = 0, limit = 10) =>
    api.get('/client/list', { params: { software_id: softwareId, status, offset, limit } }),
  push: (data: any) => api.post('/client/push', data),
  getStatus: (id: string) => api.get(`/client/${id}/status`),
  delete: (id: string) => api.delete(`/client/${id}`)
}

// 存储管理API
export const storageAPI = {
  getConfig: () => api.get('/storage/config'),
  updateConfig: (data: any) => api.put('/storage/config', data),
  test: (data: any) => api.post('/storage/test', data)
}

// Webhook API
export const webhookAPI = {
  getList: () => api.get('/webhooks'),
  create: (data: any) => api.post('/webhooks', data),
  update: (id: number, data: any) => api.put(`/webhooks/${id}`, data),
  delete: (id: number) => api.delete(`/webhooks/${id}`),
  test: (id: number) => api.post(`/webhooks/${id}/test`)
}

// 系统监控API
export const systemAPI = {
  health: () => api.get('/health'),
  metrics: () => api.get('/metrics'),
  stats: () => api.get('/stats'),
  logs: (params?: any) => api.get('/logs', { params })
}

// 限流配置API
export const rateLimitAPI = {
  getConfig: () => api.get('/rate-limit/config'),
  updateConfig: (data: any) => api.put('/rate-limit/config', data)
}

// 安全相关API
export const securityAPI = {
  getIPWhitelist: () => api.get('/security/ip-whitelist'),
  addIPWhitelist: (data: any) => api.post('/security/ip-whitelist', data),
  deleteIPWhitelist: (id: number) => api.delete(`/security/ip-whitelist/${id}`),
  getIPBlacklist: () => api.get('/security/ip-blacklist'),
  addIPBlacklist: (data: any) => api.post('/security/ip-blacklist', data),
  deleteIPBlacklist: (id: number) => api.delete(`/security/ip-blacklist/${id}`),
  getSecurityLogs: (params?: any) => api.get('/security/download-logs', { params })
}
