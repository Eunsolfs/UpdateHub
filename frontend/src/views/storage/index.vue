<template>
  <div class="storage-page">
    <el-card>
      <template #header>
        <span>存储配置</span>
      </template>
      <el-form :model="storageConfig" label-width="120px">
        <el-form-item label="存储类型">
          <el-select v-model="storageConfig.type" @change="handleTypeChange">
            <el-option label="本地存储" value="local" />
            <el-option label="AWS S3" value="s3" />
            <el-option label="腾讯云COS" value="cos" />
            <el-option label="阿里云OSS" value="oss" />
          </el-select>
        </el-form-item>

        <!-- 本地存储配置 -->
        <template v-if="storageConfig.type === 'local'">
          <el-form-item label="基础路径">
            <el-input v-model="storageConfig.local.basePath" />
          </el-form-item>
          <el-form-item label="URL前缀">
            <el-input v-model="storageConfig.local.urlPrefix" />
          </el-form-item>
        </template>

        <!-- S3配置 -->
        <template v-if="storageConfig.type === 's3'">
          <el-form-item label="Access Key">
            <el-input v-model="storageConfig.s3.accessKeyId" />
          </el-form-item>
          <el-form-item label="Secret Key">
            <el-input v-model="storageConfig.s3.secretAccessKey" type="password" />
          </el-form-item>
          <el-form-item label="Region">
            <el-input v-model="storageConfig.s3.region" />
          </el-form-item>
          <el-form-item label="Bucket">
            <el-input v-model="storageConfig.s3.bucket" />
          </el-form-item>
          <el-form-item label="Endpoint">
            <el-input v-model="storageConfig.s3.endpoint" />
          </el-form-item>
        </template>

        <!-- COS配置 -->
        <template v-if="storageConfig.type === 'cos'">
          <el-form-item label="Secret ID">
            <el-input v-model="storageConfig.cos.secretId" />
          </el-form-item>
          <el-form-item label="Secret Key">
            <el-input v-model="storageConfig.cos.secretKey" type="password" />
          </el-form-item>
          <el-form-item label="Region">
            <el-input v-model="storageConfig.cos.region" />
          </el-form-item>
          <el-form-item label="Bucket">
            <el-input v-model="storageConfig.cos.bucket" />
          </el-form-item>
        </template>

        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="saving">保存配置</el-button>
          <el-button @click="handleTest" :loading="testing">测试连接</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { storageAPI } from '@/api'

const saving = ref(false)
const testing = ref(false)

const storageConfig = ref({
  type: 'local',
  local: {
    basePath: './uploads',
    urlPrefix: 'http://localhost:8080/uploads'
  },
  s3: {
    accessKeyId: '',
    secretAccessKey: '',
    region: 'us-east-1',
    bucket: '',
    endpoint: ''
  },
  cos: {
    secretId: '',
    secretKey: '',
    region: 'ap-guangzhou',
    bucket: ''
  }
})

const handleTypeChange = () => {
  // 切换存储类型时的处理
}

const handleSave = async () => {
  saving.value = true
  try {
    const response = await storageAPI.updateConfig(storageConfig.value)
    if (response.code === 0) {
      ElMessage.success('配置保存成功')
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

const handleTest = async () => {
  testing.value = true
  try {
    const response = await storageAPI.test(storageConfig.value)
    if (response.code === 0) {
      ElMessage.success('连接测试成功')
    } else {
      ElMessage.error(response.message || '连接测试失败')
    }
  } catch (error) {
    ElMessage.error('连接测试失败')
  } finally {
    testing.value = false
  }
}

onMounted(async () => {
  try {
    const response = await storageAPI.getConfig()
    if (response.code === 0) {
      storageConfig.value = response.data
    }
  } catch (error) {
    ElMessage.error('获取配置失败')
  }
})
</script>

<style scoped>
.storage-page {
  padding: 20px;
}
</style>
