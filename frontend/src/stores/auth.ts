import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authAPI } from '@/api'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const user = ref<any>(null)

  const login = async (username: string, password: string) => {
    try {
      const response = await authAPI.login(username, password)
      if (response.code === 0) {
        token.value = response.data.token
        user.value = response.data.user
        localStorage.setItem('token', response.data.token)
        return true
      }
      return false
    } catch (error) {
      console.error('Login failed:', error)
      return false
    }
  }

  const logout = async () => {
    try {
      await authAPI.logout()
    } catch (error) {
      console.error('Logout failed:', error)
    } finally {
      token.value = ''
      user.value = null
      localStorage.removeItem('token')
    }
  }

  const getCurrentUser = async () => {
    try {
      const response = await authAPI.getCurrentUser()
      if (response.code === 0) {
        user.value = response.data
      }
    } catch (error) {
      console.error('Get current user failed:', error)
    }
  }

  const changePassword = async (oldPassword: string, newPassword: string) => {
    try {
      const response = await authAPI.changePassword(oldPassword, newPassword)
      return response.code === 0
    } catch (error) {
      console.error('Change password failed:', error)
      return false
    }
  }

  return {
    token,
    user,
    login,
    logout,
    getCurrentUser,
    changePassword
  }
})
