<template>
  <div class="upload-page">
    <el-card>
      <template #header>
        <span>文件上传</span>
      </template>
      <el-form :model="uploadForm" label-width="120px">
        <el-form-item label="文件名">
          <el-input v-model="uploadForm.fileName" />
        </el-form-item>
        <el-form-item label="文件大小">
          <el-input v-model="uploadForm.fileSize" type="number" />
        </el-form-item>
        <el-form-item label="分片大小">
          <el-input v-model="uploadForm.chunkSize" type="number" placeholder="默认5MB" />
        </el-form-item>
        <el-form-item label="文件">
          <el-upload
            class="upload-demo"
            action="#"
            :auto-upload="false"
            :on-change="handleFileChange"
          >
            <el-button type="primary">选择文件</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleInitUpload" :loading="uploading">初始化上传</el-button>
          <el-button @click="handleCancelUpload" :disabled="!taskId">取消上传</el-button>
        </el-form-item>
      </el-form>

      <el-divider />

      <div v-if="taskId">
        <h3>上传进度</h3>
        <el-progress :percentage="uploadProgress" :status="uploadStatus" />
        <p>已上传: {{ uploadedChunks }} / {{ totalChunks }} 分片</p>
        <el-button @click="handleCheckStatus" :loading="checking">检查状态</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { uploadAPI } from '@/api'

const uploadForm = ref({
  fileName: '',
  fileSize: 0,
  chunkSize: 5 * 1024 * 1024, // 5MB
  fileHash: '',
  mimeType: ''
})

const uploading = ref(false)
const checking = ref(false)
const taskId = ref('')
const uploadProgress = ref(0)
const uploadedChunks = ref(0)
const totalChunks = ref(0)
const uploadStatus = ref('')

const handleFileChange = (file: any) => {
  uploadForm.value.fileName = file.name
  uploadForm.value.fileSize = file.size
  uploadForm.value.mimeType = file.type
  // 这里应该计算文件hash
  uploadForm.value.fileHash = 'calculated-hash'
}

const handleInitUpload = async () => {
  if (!uploadForm.value.fileName) {
    ElMessage.warning('请先选择文件')
    return
  }

  uploading.value = true
  try {
    const response = await uploadAPI.init(uploadForm.value)
    if (response.code === 0) {
      taskId.value = response.data.task_id
      totalChunks.value = response.data.total_chunks
      ElMessage.success('上传初始化成功')
      
      // 模拟分片上传
      simulateChunkUpload()
    } else {
      ElMessage.error(response.message || '初始化失败')
    }
  } catch (error) {
    ElMessage.error('初始化失败')
  } finally {
    uploading.value = false
  }
}

const simulateChunkUpload = async () => {
  // 模拟分片上传过程
  for (let i = 0; i < totalChunks.value; i++) {
    await new Promise(resolve => setTimeout(resolve, 500))
    uploadedChunks.value = i + 1
    uploadProgress.value = Math.round((uploadedChunks.value / totalChunks.value) * 100)
  }

  // 完成上传
  handleCompleteUpload()
}

const handleCompleteUpload = async () => {
  try {
    const response = await uploadAPI.complete({
      task_id: taskId.value,
      file_hash: uploadForm.value.fileHash
    })
    if (response.code === 0) {
      ElMessage.success('上传完成')
      uploadStatus.value = 'success'
    } else {
      ElMessage.error(response.message || '上传完成失败')
      uploadStatus.value = 'exception'
    }
  } catch (error) {
    ElMessage.error('上传完成失败')
    uploadStatus.value = 'exception'
  }
}

const handleCancelUpload = async () => {
  if (!taskId.value) return

  try {
    const response = await uploadAPI.cancel(taskId.value)
    if (response.code === 0) {
      ElMessage.success('上传已取消')
      resetUpload()
    } else {
      ElMessage.error(response.message || '取消失败')
    }
  } catch (error) {
    ElMessage.error('取消失败')
  }
}

const handleCheckStatus = async () => {
  if (!taskId.value) return

  checking.value = true
  try {
    const response = await uploadAPI.getStatus(taskId.value)
    if (response.code === 0) {
      uploadedChunks.value = response.data.uploaded_chunks
      totalChunks.value = response.data.total_chunks
      uploadProgress.value = response.data.progress
    } else {
      ElMessage.error(response.message || '获取状态失败')
    }
  } catch (error) {
    ElMessage.error('获取状态失败')
  } finally {
    checking.value = false
  }
}

const resetUpload = () => {
  taskId.value = ''
  uploadProgress.value = 0
  uploadedChunks.value = 0
  totalChunks.value = 0
  uploadStatus.value = ''
}
</script>

<style scoped>
.upload-page {
  padding: 20px;
}
</style>
