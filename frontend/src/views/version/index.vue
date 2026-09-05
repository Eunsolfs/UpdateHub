<template>
  <div class="version-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>版本管理</span>
          <el-button type="primary" @click="handleCreate">发布版本</el-button>
        </div>
      </template>
      <el-table :data="versionList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="versionNumber" label="版本号" />
        <el-table-column prop="platform" label="平台" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250">
          <template #default="{ row }">
            <el-button size="small" @click="handlePublish(row)" v-if="row.status === 'draft'">发布</el-button>
            <el-button size="small" type="warning" @click="handleRollback(row)" v-if="row.status === 'published'">回滚</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)" v-if="row.status === 'draft'">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 发布版本对话框 -->
    <el-dialog v-model="dialogVisible" title="发布版本" width="600px">
      <el-form :model="form" :rules="rules" ref="formRef">
        <el-form-item label="软件" prop="softwareId">
          <el-select v-model="form.softwareId" placeholder="选择软件" style="width: 100%">
            <el-option v-for="software in softwareList" :key="software.id" :label="software.name" :value="software.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="版本号" prop="versionNumber">
          <el-input v-model="form.versionNumber" placeholder="如: 1.0.0" />
        </el-form-item>
        <el-form-item label="平台" prop="platform">
          <el-select v-model="form.platform" placeholder="选择平台" style="width: 100%">
            <el-option label="Windows" value="windows" />
            <el-option label="macOS" value="macos" />
            <el-option label="Linux" value="linux" />
          </el-select>
        </el-form-item>
        <el-form-item label="更新说明" prop="releaseNotes">
          <el-input v-model="form.releaseNotes" type="textarea" :rows="4" />
        </el-form-item>
        <el-form-item label="强制更新">
          <el-switch v-model="form.forceUpdate" />
        </el-form-item>
        <el-form-item label="文件上传">
          <el-upload
            class="upload-demo"
            action="#"
            :auto-upload="false"
            :on-change="handleFileChange"
          >
            <el-button type="primary">选择文件</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { versionAPI, softwareAPI } from '@/api'

const loading = ref(false)
const versionList = ref([])
const softwareList = ref([])
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref()

const form = ref({
  softwareId: 0,
  versionNumber: '',
  platform: 'windows',
  releaseNotes: '',
  forceUpdate: false,
  fileId: '',
  filePath: '',
  fileSize: 0,
  md5: '',
  sha256: ''
})

const rules = {
  softwareId: [{ required: true, message: '请选择软件', trigger: 'change' }],
  versionNumber: [{ required: true, message: '请输入版本号', trigger: 'blur' }],
  platform: [{ required: true, message: '请选择平台', trigger: 'change' }],
  releaseNotes: [{ required: true, message: '请输入更新说明', trigger: 'blur' }]
}

const fetchVersionList = async () => {
  loading.value = true
  try {
    // 暂时获取第一个软件的版本
    const softwareResponse = await softwareAPI.getList(0, 10)
    if (softwareResponse.code === 0 && softwareResponse.data.software.length > 0) {
      const softwareId = softwareResponse.data.software[0].id
      const response = await versionAPI.getHistory(softwareId)
      if (response.code === 0) {
        versionList.value = response.data.versions
      }
    }
  } catch (error) {
    ElMessage.error('获取版本列表失败')
  } finally {
    loading.value = false
  }
}

const fetchSoftwareList = async () => {
  try {
    const response = await softwareAPI.getList(0, 100)
    if (response.code === 0) {
      softwareList.value = response.data.software
    }
  } catch (error) {
    ElMessage.error('获取软件列表失败')
  }
}

const handleCreate = () => {
  form.value = {
    softwareId: 0,
    versionNumber: '',
    platform: 'windows',
    releaseNotes: '',
    forceUpdate: false,
    fileId: '',
    filePath: '',
    fileSize: 0,
    md5: '',
    sha256: ''
  }
  dialogVisible.value = true
}

const handlePublish = async (row: any) => {
  try {
    const response = await versionAPI.updateStatus(row.id, 'published')
    if (response.code === 0) {
      ElMessage.success('发布成功')
      fetchVersionList()
    } else {
      ElMessage.error(response.message || '发布失败')
    }
  } catch (error) {
    ElMessage.error('发布失败')
  }
}

const handleRollback = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要回滚这个版本吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await versionAPI.rollback(row.id, 'soft', '手动回滚')
    if (response.code === 0) {
      ElMessage.success('回滚成功')
      fetchVersionList()
    } else {
      ElMessage.error(response.message || '回滚失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('回滚失败')
    }
  }
}

const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这个版本吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await versionAPI.delete(row.id)
    if (response.code === 0) {
      ElMessage.success('删除成功')
      fetchVersionList()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleFileChange = (file: any) => {
  // 这里应该处理文件上传逻辑
  console.log('File selected:', file)
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    submitting.value = true
    
    const response = await versionAPI.create(form.value)
    if (response.code === 0) {
      ElMessage.success('发布成功')
      dialogVisible.value = false
      fetchVersionList()
    } else {
      ElMessage.error(response.message || '发布失败')
    }
  } catch (error) {
    ElMessage.error('发布失败')
  } finally {
    submitting.value = false
  }
}

const getStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    draft: 'info',
    published: 'success',
    archived: 'warning',
    deleted: 'danger'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    draft: '草稿',
    published: '已发布',
    archived: '已归档',
    deleted: '已删除'
  }
  return statusMap[status] || status
}

onMounted(() => {
  fetchSoftwareList()
  fetchVersionList()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
