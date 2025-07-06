import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiClient } from '../services/api'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || null)
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const loading = ref(false)
  const error = ref(null)

  const isAuthenticated = computed(() => !!token.value)

  const login = async (credentials) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await apiClient.post('/login', credentials)
      
      token.value = response.data.token
      user.value = response.data.user
      
      // Store in localStorage
      localStorage.setItem('token', token.value)
      localStorage.setItem('user', JSON.stringify(user.value))
      
      // Set default authorization header
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.error || 'Login failed'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    error.value = null
    
    // Remove from localStorage
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    
    // Remove authorization header
    delete apiClient.defaults.headers.common['Authorization']
  }

  const checkAuth = async () => {
    if (!token.value) return false
    
    try {
      // Set authorization header
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      // Verify token with backend
      const response = await apiClient.get('/protected')
      
      // Update user data
      user.value = response.data
      localStorage.setItem('user', JSON.stringify(user.value))
      
      return true
    } catch (err) {
      // Token is invalid, clear auth data
      logout()
      return false
    }
  }

  const getUserEntries = async (username) => {
    if (!token.value) return { success: false, error: 'Not authenticated' }
    
    try {
      // Set authorization header
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      // Fetch user entries
      const response = await apiClient.get(`/entries/${username}`)
      
      return { success: true, entries: response.data }
    } catch (err) {
      return { 
        success: false, 
        error: err.response?.data?.error || 'Failed to fetch entries' 
      }
    }
  }

  const openDoor = async (entryId) => {
    if (!token.value) return { success: false, error: 'Not authenticated' }
    
    try {
      // Set authorization header
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      // Open door for entry
      const response = await apiClient.post('/open_door', { entry_id: entryId })
      
      return { success: true, data: response.data }
    } catch (err) {
      return { 
        success: false, 
        error: err.response?.data?.error || 'Failed to open door' 
      }
    }
  }

  const closeDoor = async (entryId) => {
    if (!token.value) return { success: false, error: 'Not authenticated' }
    
    try {
      // Set authorization header
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      // Close door for entry
      const response = await apiClient.post('/close_door', { entry_id: entryId })
      
      return { success: true, data: response.data }
    } catch (err) {
      return { 
        success: false, 
        error: err.response?.data?.error || 'Failed to close door' 
      }
    }
  }

  // Initialize auth state
  if (token.value) {
    apiClient.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
    checkAuth()
  }

  return {
    token,
    user,
    loading,
    error,
    isAuthenticated,
    login,
    logout,
    checkAuth,
    getUserEntries,
    openDoor,
    closeDoor
  }
})
