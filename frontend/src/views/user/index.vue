<template>
  <div class="user-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="handleCreate">创建用户</el-button>
        </div>
      </template>
      <el-table :data="userList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role.name" label="角色" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
              {{ row.status === 'active' ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
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
        @current-change="fetchUserList"
        @size-change="fetchUserList"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 创建/编辑用户对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!form.id">
          <el-input v-model="form.password" type="password" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="角色" prop="roleId">
          <el-select v-model="form.roleId" placeholder="选择角色" style="width: 100%">
            <el-option v-for="role in roleList" :key="role.id" :label="role.name" :value="role.id" />
          </el-select>
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
import { userAPI } from '@/api'

const loading = ref(false)
const userList = ref([])
const roleList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('创建用户')
const formRef = ref()

const form = ref({
  id: 0,
  username: '',
  password: '',
  email: '',
  roleId: 0
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  email: [{ required: true, message: '请输入邮箱', trigger: 'blur' }],
  roleId: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const fetchUserList = async () => {
  loading.value = true
  try {
    const response = await userAPI.getList((currentPage.value - 1) * pageSize.value, pageSize.value)
    if (response.code === 0) {
      userList.value = response.data.users
      total.value = response.data.total
    }
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const fetchRoleList = async () => {
  try {
    const response = await userAPI.getRoles()
    if (response.code === 0) {
      roleList.value = response.data
    }
  } catch (error) {
    ElMessage.error('获取角色列表失败')
  }
}

const handleCreate = () => {
  dialogTitle.value = '创建用户'
  form.value = {
    id: 0,
    username: '',
    password: '',
    email: '',
    roleId: 0
  }
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  dialogTitle.value = '编辑用户'
  form.value = { ...row }
  dialogVisible.value = true
}

const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这个用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await userAPI.delete(row.id)
    if (response.code === 0) {
      ElMessage.success('删除成功')
      fetchUserList()
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
      response = await userAPI.create(form.value)
    } else {
      response = await userAPI.update(form.value.id, form.value)
    }
    
    if (response.code === 0) {
      ElMessage.success(form.value.id === 0 ? '创建成功' : '更新成功')
      dialogVisible.value = false
      fetchUserList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

onMounted(() => {
  fetchRoleList()
  fetchUserList()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
