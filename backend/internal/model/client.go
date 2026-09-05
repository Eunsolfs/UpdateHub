package model

import "time"

// Client 客户端模型
type Client struct {
	ID                 uint      `gorm:"primaryKey" json:"id"`
	ClientID           string    `gorm:"uniqueIndex;not null" json:"client_id"`
	SoftwareID         uint      `gorm:"not null;index" json:"software_id"`
	SoftwareIdentifier string    `json:"software_identifier"`
	CurrentVersion     string    `json:"current_version"`
	Platform           string    `json:"platform"`
	OSVersion          string    `json:"os_version"`
	DeviceInfo         string    `gorm:"type:jsonb" json:"device_info"`
	Status             string    `gorm:"default:online" json:"status"` // online/offline
	LastHeartbeat      *time.Time `json:"last_heartbeat"`
	LastCheckUpdate    *time.Time `json:"last_check_update"`
	RegisteredAt       time.Time `json:"registered_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}

// PushRecord 推送记录模型
type PushRecord struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	PushID        string    `gorm:"uniqueIndex;not null" json:"push_id"`
	VersionID     uint      `gorm:"not null;index" json:"version_id"`
	TargetType    string    `json:"target_type"` // all/software/specific
	TargetClients string    `gorm:"type:jsonb" json:"target_clients"`
	Message       string    `json:"message"`
	ForceNotify   bool      `gorm:"default:false" json:"force_notify"`
	TotalCount    int       `gorm:"default:0" json:"total_count"`
	SuccessCount  int       `gorm:"default:0" json:"success_count"`
	FailedCount   int       `gorm:"default:0" json:"failed_count"`
	PushedBy      uint      `json:"pushed_by"`
	PushedAt      time.Time `json:"pushed_at"`
}

// RateLimit 限流配置模型
type RateLimit struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	Key            string    `gorm:"uniqueIndex;not null" json:"key"`
	LimitPerMinute int       `gorm:"default:60" json:"limit_per_minute"`
	LimitPerHour   int       `gorm:"default:1000" json:"limit_per_hour"`
	LimitPerDay    int       `gorm:"default:10000" json:"limit_per_day"`
	Enabled        bool      `gorm:"default:true" json:"enabled"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// Webhook Webhook配置模型
type Webhook struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	Name            string    `gorm:"not null" json:"name"`
	URL             string    `gorm:"not null" json:"url"`
	Events          string    `gorm:"type:jsonb" json:"events"` // ["version:published", "client:online"]
	Secret          string    `json:"secret"`
	Enabled         bool      `gorm:"default:true" json:"enabled"`
	LastTriggeredAt *time.Time `json:"last_triggered_at"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// DownloadStat 下载统计模型
type DownloadStat struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	VersionID       uint      `gorm:"not null;index" json:"version_id"`
	SoftwareIdentifier string `json:"software_identifier"`
	ClientVersion   string    `json:"client_version"`
	Platform        string    `json:"platform"`
	IPAddress       string    `json:"ip_address"`
	UserAgent       string    `json:"user_agent"`
	DownloadTime    time.Time `json:"download_time"`
	FileSize        int64     `json:"file_size"`
	DownloadDuration int      `json:"download_duration"` // 下载耗时（秒）
}

// IPWhitelist IP白名单模型
type IPWhitelist struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	IPAddress   string    `gorm:"not null" json:"ip_address"`
	Description string    `json:"description"`
	Enabled     bool      `gorm:"default:true" json:"enabled"`
	CreatedBy   uint      `json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// IPBlacklist IP黑名单模型
type IPBlacklist struct {
	ID         uint       `gorm:"primaryKey" json:"id"`
	IPAddress  string     `gorm:"not null" json:"ip_address"`
	Reason     string     `json:"reason"`
	BanType    string     `gorm:"default:temporary" json:"ban_type"` // temporary/permanent
	ExpiresAt  *time.Time `json:"expires_at"`
	AutoBanned bool       `gorm:"default:false" json:"auto_banned"`
	CreatedBy  uint       `json:"created_by"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
}

// SecurityLog 安全日志模型
type SecurityLog struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	IPAddress     string    `json:"ip_address"`
	UserAgent     string    `json:"user_agent"`
	Referer       string    `json:"referer"`
	RequestURL    string    `json:"request_url"`
	TokenValid    bool      `json:"token_valid"`
	SignatureValid bool    `json:"signature_valid"`
	Country       string    `json:"country"`
	BlockedReason string   `json:"blocked_reason"`
	Blocked       bool      `gorm:"default:false" json:"blocked"`
	CreatedAt     time.Time `json:"created_at"`
}
