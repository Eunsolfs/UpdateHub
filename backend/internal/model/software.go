package model

import "time"

// Software 软件模型
type Software struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Identifier  string    `gorm:"uniqueIndex;not null" json:"identifier"` // 软件唯一标识
	Name        string    `gorm:"not null" json:"name"`                    // 软件名称
	Description string    `json:"description"`                             // 软件描述
	Icon        string    `json:"icon"`                                    // 软件图标
	CreatedBy   uint      `json:"created_by"`                              // 创建人ID
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Versions    []Version `gorm:"foreignKey:SoftwareID" json:"versions,omitempty"`
}

// Version 版本模型
type Version struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	SoftwareID      uint      `gorm:"not null;index" json:"software_id"`
	Software        Software  `gorm:"foreignKey:SoftwareID" json:"software,omitempty"`
	VersionNumber   string    `gorm:"not null" json:"version_number"`   // 版本号
	ReleaseNotes    string    `json:"release_notes"`                    // 更新说明
	FileID          string    `json:"file_id"`                          // 文件ID
	FilePath        string    `json:"file_path"`                        // 文件路径
	FileSize        int64     `json:"file_size"`                        // 文件大小
	MD5             string    `json:"md5"`                              // MD5校验值
	SHA256          string    `json:"sha256"`                           // SHA256校验值
	UpdateType      string    `gorm:"default:full" json:"update_type"`   // 更新类型: full/diff
	ForceUpdate     bool      `gorm:"default:false" json:"force_update"` // 是否强制更新
	Platform        string    `json:"platform"`                         // 平台: windows/macos/linux
	Status          string    `gorm:"default:draft" json:"status"`      // 状态: draft/published/archived/deleted
	IsCurrent       bool      `gorm:"default:false" json:"is_current"`  // 是否为当前版本
	PublishedBy     uint      `json:"published_by"`                      // 发布人ID
	PublishedAt     *time.Time `json:"published_at"`                    // 发布时间
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// User 用户模型
type User struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Username  string    `gorm:"uniqueIndex;not null" json:"username"`
	Password  string    `gorm:"not null" json:"-"`
	Email     string    `gorm:"uniqueIndex" json:"email"`
	RoleID    uint      `gorm:"not null;index" json:"role_id"`
	Role      Role      `gorm:"foreignKey:RoleID" json:"role,omitempty"`
	Status    string    `gorm:"default:active" json:"status"` // active/disabled
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Role 角色模型
type Role struct {
	ID          uint        `gorm:"primaryKey" json:"id"`
	Name        string      `gorm:"uniqueIndex;not null" json:"name"`
	Description string      `json:"description"`
	Permissions []Permission `gorm:"many2many:role_permissions;" json:"permissions,omitempty"`
	CreatedAt   time.Time   `json:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at"`
}

// Permission 权限模型
type Permission struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Name        string    `gorm:"uniqueIndex;not null" json:"name"`        // 权限名称，如 software:create
	Description string    `json:"description"`                            // 权限描述
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// StorageConfig 存储配置模型
type StorageConfig struct {
	ID     uint   `gorm:"primaryKey" json:"id"`
	Type   string `gorm:"not null" json:"type"` // local/s3/cos/oss
	Config string `gorm:"type:jsonb" json:"config"` // JSON格式的配置
	IsDefault bool `gorm:"default:false" json:"is_default"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
