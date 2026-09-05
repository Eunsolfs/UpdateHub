import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/components/layout/index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '仪表盘' }
      },
      {
        path: 'software',
        name: 'Software',
        component: () => import('@/views/software/index.vue'),
        meta: { title: '软件管理' }
      },
      {
        path: 'version',
        name: 'Version',
        component: () => import('@/views/version/index.vue'),
        meta: { title: '版本管理' }
      },
      {
        path: 'upload',
        name: 'Upload',
        component: () => import('@/views/upload/index.vue'),
        meta: { title: '上传管理' }
      },
      {
        path: 'storage',
        name: 'Storage',
        component: () => import('@/views/storage/index.vue'),
        meta: { title: '存储配置' }
      },
      {
        path: 'user',
        name: 'User',
        component: () => import('@/views/user/index.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('@/views/role/index.vue'),
        meta: { title: '角色管理' }
      },
      {
        path: 'log',
        name: 'Log',
        component: () => import('@/views/log/index.vue'),
        meta: { title: '操作日志' }
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/settings/index.vue'),
        meta: { title: '系统设置' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.path !== '/login' && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router
