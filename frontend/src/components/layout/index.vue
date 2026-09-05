<template>
  <div class="layout-container">
    <el-container>
      <el-aside width="200px">
        <div class="logo">
          <h3>UpdateHub</h3>
        </div>
        <el-menu
          :default-active="activeMenu"
          router
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409eff"
        >
          <el-menu-item index="/dashboard">
            <el-icon><Dashboard /></el-icon>
            <span>仪表盘</span>
          </el-menu-item>
          <el-menu-item index="/software">
            <el-icon><Box /></el-icon>
            <span>软件管理</span>
          </el-menu-item>
          <el-menu-item index="/version">
            <el-icon><Document /></el-icon>
            <span>版本管理</span>
          </el-menu-item>
          <el-menu-item index="/upload">
            <el-icon><Upload /></el-icon>
            <span>上传管理</span>
          </el-menu-item>
          <el-menu-item index="/storage">
            <el-icon><FolderOpened /></el-icon>
            <span>存储配置</span>
          </el-menu-item>
          <el-menu-item index="/user">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/role">
            <el-icon><Key /></el-icon>
            <span>角色管理</span>
          </el-menu-item>
          <el-menu-item index="/log">
            <el-icon><DocumentCopy /></el-icon>
            <span>操作日志</span>
          </el-menu-item>
          <el-menu-item index="/settings">
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-container>
        <el-header>
          <div class="header-content">
            <div class="breadcrumb">
              <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
                <el-breadcrumb-item>{{ currentPageTitle }}</el-breadcrumb-item>
              </el-breadcrumb>
            </div>
            <div class="header-actions">
              <el-button circle @click="toggleTheme">
                <el-icon><Moon /></el-icon>
              </el-button>
              <el-dropdown>
                <el-button circle>
                  <el-icon><User /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </el-header>
        <el-main>
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()

const activeMenu = computed(() => route.path)
const currentPageTitle = computed(() => route.meta.title as string || '首页')

const toggleTheme = () => {
  ElMessage.info('主题切换功能待实现')
}

const handleLogout = () => {
  localStorage.removeItem('token')
  ElMessage.success('退出登录成功')
  router.push('/login')
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.el-container {
  height: 100%;
}

.el-aside {
  background-color: #304156;
  height: 100%;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  border-bottom: 1px solid #1f2d3d;
}

.logo h3 {
  margin: 0;
  font-size: 20px;
}

.el-header {
  background-color: white;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  padding: 0 20px;
}

.header-content {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-main {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>
