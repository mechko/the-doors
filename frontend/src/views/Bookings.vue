<template>
  <div class="dashboard">
    <div class="dashboard-container">
      <div class="welcome-section">
        <h1>Welcome to your Room Bookings</h1>
        <p v-if="user">Hello, {{ user.display_name || user.name  }}!</p>
      </div>
      
      <div class="dashboard-grid">

      <!-- User Entries Section -->
      <div class="entries-section">
        <div class="dashboard-card">
          <div class="card-header">
            <h3>Your Entries</h3>
            <span v-if="entries.length > 0" class="entry-count">{{ entries.length }} entries</span>
          </div>
          <div class="card-content">
            <div v-if="loadingEntries" class="loading">
              Loading entries...
            </div>
            <div v-else-if="entriesError" class="error">
              <p>{{ entriesError }}</p>
              <button @click="refreshEntries" class="action-btn">Try Again</button>
            </div>
            <div v-else-if="entries.length === 0" class="no-entries">
              <p>No entries found for your account.</p>
            </div>
            <div v-else class="entries-list">
              <div v-for="entry in entries" :key="entry.id" class="entry-item">
                <div class="entry-header">
                  <span class="entry-id">Entry #{{ entry.id }}</span>
                  <span class="room-id">Room: {{ entry.room_name }}</span>
                </div>
                <div class="entry-times">
                  <div class="time-item">
                    <span class="time-label">Start:</span>
                    <span class="time-value">{{ formatDate(entry.start_time) }}</span>
                  </div>
                  <div class="time-item">
                    <span class="time-label">End:</span>
                    <span class="time-value">{{ formatDate(entry.end_time) }}</span>
                  </div>
                </div>
                <div class="entry-duration">
                  <span class="duration-label">Duration:</span>
                  <span class="duration-value">{{ formatDuration(entry.start_time, entry.end_time) }}</span>
                </div>
                <div class="entry-actions">
                  <button 
                    @click="openDoor(entry.id)" 
                    class="door-btn open-btn"
                    :disabled="openingDoor === entry.id || closingDoor === entry.id"
                  >
                    <span v-if="openingDoor === entry.id">Opening...</span>
                    <span v-else>🚪 Open Door</span>
                  </button>
                  <button 
                    @click="closeDoor(entry.id)" 
                    class="door-btn close-btn"
                    :disabled="openingDoor === entry.id || closingDoor === entry.id"
                  >
                    <span v-if="closingDoor === entry.id">Closing...</span>
                    <span v-else>🔒 Close Door</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="dashboard-card">
          <div class="card-header">
            <h3>Profile Information</h3>
          </div>
          <div class="card-content">
            <div v-if="user" class="profile-info">
              <!--<div class="info-item">
                <span class="label">ID:</span>
                <span class="value">{{ user.id }}</span>
              </div>-->
              <div class="info-item">
                <span class="label">Username:</span>
                <span class="value">{{ user.name }}</span>
              </div>
              <div class="info-item">
                <span class="label">Email:</span>
                <span class="value">{{ user.email || 'Not provided' }}</span>
              </div>
            </div>
            <div v-else class="loading">
              Loading profile...
            </div>
          </div>
        </div>
    

    <div class="dashboard-card">
          <div class="card-header">
            <h3>Quick Actions</h3>
          </div>
          <div class="card-content">
            <div class="actions">
              <button @click="refreshEntries" class="action-btn" :disabled="loadingEntries">
                <span v-if="loadingEntries">Refreshing...</span>
                <span v-else>Refresh Entries</span>
              </button>
              <button @click="logout" class="action-btn danger">
                Logout
              </button>
            </div>
          </div>
      </div>
    </div>

    </div>
  </div>
</template>

<script>
import { computed, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { fromUnixTime, format, formatDistanceStrict } from 'date-fns'
import { toZonedTime } from 'date-fns-tz'

export default {
  name: 'Dashboard',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    
    const loadingEntries = ref(false)
    const entries = ref([])
    const entriesError = ref(null)
    const openingDoor = ref(null)
    const closingDoor = ref(null)
    
    const user = computed(() => authStore.user)
    
    const refreshEntries = async () => {
      if (!user.value) return
      
      loadingEntries.value = true
      entriesError.value = null
      
      try {
        const result = await authStore.getUserEntries(user.value.name)
        if (result.success) {
          entries.value = result.entries
        } else {
          entriesError.value = result.error
        }
      } catch (error) {
        entriesError.value = 'Failed to load entries'
      } finally {
        loadingEntries.value = false
      }
    }
    
    const openDoor = async (entryId) => {
      openingDoor.value = entryId
      
      try {
        const result = await authStore.openDoor(entryId)
        if (result.success) {
          // Show success message (you could use a toast notification here)
          alert('Door opened successfully!')
        } else {
          alert(`Failed to open door: ${result.error}`)
        }
      } catch (error) {
        alert('Failed to open door: Network error')
      } finally {
        openingDoor.value = null
      }
    }
    
    const closeDoor = async (entryId) => {
      closingDoor.value = entryId
      
      try {
        const result = await authStore.closeDoor(entryId)
        if (result.success) {
          // Show success message (you could use a toast notification here)
          alert('Door closed successfully!')
        } else {
          alert(`Failed to close door: ${result.error}`)
        }
      } catch (error) {
        alert('Failed to close door: Network error')
      } finally {
        closingDoor.value = null
      }
    }
    
    const formatDate = (unixTimestamp) => {
      try {
        // Convert UNIX timestamp to Date
        const date = fromUnixTime(unixTimestamp)
        
        // Convert to Berlin timezone
        const berlinTime = toZonedTime(date, 'Europe/Berlin')
        
        // Format the date
        return format(berlinTime, 'PPP p')
      } catch (error) {
        return 'Invalid date'
      }
    }
    
    const formatDuration = (startTime, endTime) => {
      try {
        const start = fromUnixTime(startTime)
        const end = fromUnixTime(endTime)
        return formatDistanceStrict(start, end)
      } catch (error) {
        return 'Unknown duration'
      }
    }
    
    const logout = () => {
      authStore.logout()
      router.push('/login')
    }
    
    // Load entries when component mounts
    onMounted(() => {
      refreshEntries()
    })
    
    return {
      user,
      entries,
      loadingEntries,
      entriesError,
      openingDoor,
      closingDoor,
      refreshEntries,
      openDoor,
      closeDoor,
      formatDate,
      formatDuration,
      logout
    }
  }
}
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.dashboard-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.welcome-section {
  text-align: center;
  margin-bottom: 2rem;
}

.welcome-section h1 {
  color: white;
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.welcome-section p {
  color: rgba(255, 255, 255, 0.8);
  font-size: 1.2rem;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
}

.dashboard-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 1rem;
  padding: 0;
  overflow: hidden;
  backdrop-filter: blur(10px);
}

.card-header {
  background: rgba(255, 255, 255, 0.1);
  padding: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  color: white;
  margin: 0;
  font-size: 1.2rem;
}

.entry-count {
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
}

.card-content {
  padding: 1.5rem;
}

.profile-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 0.5rem;
}

.label {
  color: rgba(255, 255, 255, 0.7);
  font-weight: 500;
}

.value {
  color: white;
  font-weight: 600;
}

.actions {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.action-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  background: rgba(74, 144, 226, 0.8);
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn:hover:not(:disabled) {
  background: rgba(74, 144, 226, 1);
  transform: translateY(-1px);
}

.action-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.action-btn.danger {
  background: rgba(220, 53, 69, 0.8);
}

.action-btn.danger:hover:not(:disabled) {
  background: rgba(220, 53, 69, 1);
}

.entries-section {
  margin-top: 2rem;
}

.loading, .error, .no-entries {
  text-align: center;
  padding: 2rem;
  color: rgba(255, 255, 255, 0.7);
}

.error {
  color: rgba(220, 53, 69, 0.8);
}

.entries-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.entry-item {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 0.75rem;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.entry-item:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.2);
}

.entry-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.entry-id {
  color: white;
  font-weight: bold;
  font-size: 1.1rem;
}

.room-id {
  color: rgba(10, 21, 33, 0.8);
  font-weight: 600;
  background: rgba(74, 144, 226, 0.1);
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.9rem;
}

.entry-times {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.time-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.time-label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.85rem;
  font-weight: 500;
}

.time-value {
  color: white;
  font-weight: 600;
}

.entry-duration {
  margin-bottom: 1rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 0.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.duration-label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.9rem;
  font-weight: 500;
}

.duration-value {
  color: rgba(40, 167, 69, 0.8);
  font-weight: 600;
}

.entry-actions {
  margin-top: 1rem;
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.door-btn {
  padding: 0.5rem 1rem;
  border: 2px solid rgba(0, 255, 0, 0.3);
  border-radius: 0.5rem;
  background: rgba(0, 255, 0, 0.1);
  color: #90EE90;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.door-btn.open-btn {
  border-color: rgba(0, 255, 0, 0.3);
  background: rgba(0, 255, 0, 0.1);
  color: #90EE90;
}

.door-btn.open-btn:hover:not(:disabled) {
  background: rgba(0, 255, 0, 0.2);
  border-color: rgba(0, 255, 0, 0.5);
}

.door-btn.close-btn {
  border-color: rgba(255, 60, 0, 0.3);
  background: rgba(255, 165, 0, 0.1);
  color: #ff5500;
}

.door-btn.close-btn:hover:not(:disabled) {
  background: rgba(255, 165, 0, 0.2);
  border-color: #ff5500(255, 165, 0, 0.5);
}

.door-btn:hover:not(:disabled) {
  transform: translateY(-1px);
}

.door-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 768px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
  
  .welcome-section h1 {
    font-size: 2rem;
  }
  
  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .entry-header {
    flex-direction: column;
    gap: 0.5rem;
    align-items: flex-start;
  }
  
  .entry-times {
    grid-template-columns: 1fr;
  }
  
  .entry-actions {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .door-btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
