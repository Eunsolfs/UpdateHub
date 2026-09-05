<template>
  <div class="software-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>软件管理</span>
          <el-button type="primary" @click="handleCreate">创建软件</el-button>
        </div>
      </template>
      <el-table :data="softwareList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="软件名称" />
        <el-table-column prop="identifier" label="软件标识" />
        <el-table-column prop="description" label="软件描述" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total="total"
        @current-change="fetchSoftwareList"
        @size-change="fetchSoftwareList"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 创建/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef">
        <el-form-item label="软件名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="软件标识" prop="identifier">
          <el-input v-model="form.identifier" />
        </el-form-item>
        <el-form-item label="软件描述" prop="description">
          <el-input v-model="form.description" type="textarea" />
        </el-form-item>
        <el-form-item label="软件图标" prop="icon">
          <el-input v-model="form.icon" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { softwareAPI } from '@/api'

const loading = ref(false)
const softwareList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('创建软件')
const formRef = ref()

const form = ref({
  id: 0,
  name: '',
  identifier: '',
  description: '',
  icon: ''
})

const rules = {
  name: [{ required: true, message: '请输入软件名称', trigger: 'blur' }],
  identifier: [{ required: true, message: '请输入软件标识', trigger: 'blur' }]
}

const fetchSoftwareList = async () => {
  loading.value = true
  try {
    const response = await softwareAPI.getList((currentPage.value - 1) * pageSize.value, pageSize.value)
    if (response.code === 0) {
      softwareList.value = response.data.software
      total.value = response.data.total
    }
  } catch (error) {
    ElMessage.error('获取软件列表失败')
  } finally {
    loading.value = false
  }
}

const handleCreate = () => {
  dialogTitle.value = '创建软件'
  form.value = {
    id: 0,
    name: '',
    identifier: '',
    description: '',
    icon: ''
  }
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  dialogTitle.value = '编辑软件'
  form.value = { ...row }
  dialogVisible.value = true
}

const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这个软件吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await softwareAPI.delete(row.id)
    if (response.code === 0) {
      ElMessage.success('删除成功')
      fetchSoftwareList()
    } else {
      ElMessage.error(response.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    
    let response
    if (form.value.id === 0) {
      response = await softwareAPI.create(form.value)
    } else {
      response = await softwareAPI.update(form.value.id, form.value)
    }
    
    if (response.code === 0) {
      ElMessage.success(form.value.id === 0 ? '创建成功' : '更新成功')
      dialogVisible.value = false
      fetchSoftwareList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

onMounted(() => {
  fetchSoftwareList()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
