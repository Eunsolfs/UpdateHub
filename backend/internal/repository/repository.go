package repository

import (
	"updatehub/internal/model"

	"gorm.io/gorm"
)

// Repositories 仓储集合
type Repositories struct {
	Software      SoftwareRepository
	Version       VersionRepository
	User          UserRepository
	Role          RoleRepository
	StorageConfig StorageConfigRepository
	Client        ClientRepository
	PushRecord    PushRecordRepository
	RateLimit     RateLimitRepository
	Webhook       WebhookRepository
	DownloadStat  DownloadStatRepository
	IPWhitelist   IPWhitelistRepository
	IPBlacklist   IPBlacklistRepository
	SecurityLog   SecurityLogRepository
}

// NewRepositories 创建仓储集合
func NewRepositories(db *gorm.DB) *Repositories {
	return &Repositories{
		Software:      NewSoftwareRepository(db),
		Version:       NewVersionRepository(db),
		User:          NewUserRepository(db),
		Role:          NewRoleRepository(db),
		StorageConfig: NewStorageConfigRepository(db),
		Client:        NewClientRepository(db),
		PushRecord:    NewPushRecordRepository(db),
		RateLimit:     NewRateLimitRepository(db),
		Webhook:       NewWebhookRepository(db),
		DownloadStat:  NewDownloadStatRepository(db),
		IPWhitelist:   NewIPWhitelistRepository(db),
		IPBlacklist:   NewIPBlacklistRepository(db),
		SecurityLog:   NewSecurityLogRepository(db),
	}
}

// SoftwareRepository 软件仓储
type SoftwareRepository struct {
	db *gorm.DB
}

func NewSoftwareRepository(db *gorm.DB) SoftwareRepository {
	return SoftwareRepository{db: db}
}

func (r SoftwareRepository) Create(software *model.Software) error {
	return r.db.Create(software).Error
}

func (r SoftwareRepository) GetByID(id uint) (*model.Software, error) {
	var software model.Software
	err := r.db.Preload("Versions").First(&software, id).Error
	return &software, err
}

func (r SoftwareRepository) GetByIDentifier(identifier string) (*model.Software, error) {
	var software model.Software
	err := r.db.Preload("Versions").Where("identifier = ?", identifier).First(&software).Error
	return &software, err
}

func (r SoftwareRepository) List(offset, limit int) ([]model.Software, int64, error) {
	var software []model.Software
	var total int64
	err := r.db.Model(&model.Software{}).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = r.db.Offset(offset).Limit(limit).Find(&software).Error
	return software, total, err
}

func (r SoftwareRepository) Update(software *model.Software) error {
	return r.db.Save(software).Error
}

func (r SoftwareRepository) Delete(id uint) error {
	return r.db.Delete(&model.Software{}, id).Error
}

// VersionRepository 版本仓储
type VersionRepository struct {
	db *gorm.DB
}

func NewVersionRepository(db *gorm.DB) VersionRepository {
	return VersionRepository{db: db}
}

func (r VersionRepository) Create(version *model.Version) error {
	return r.db.Create(version).Error
}

func (r VersionRepository) GetByID(id uint) (*model.Version, error) {
	var version model.Version
	err := r.db.Preload("Software").First(&version, id).Error
	return &version, err
}

func (r VersionRepository) GetBySoftwareID(softwareID uint) ([]model.Version, error) {
	var versions []model.Version
	err := r.db.Where("software_id = ?", softwareID).Order("created_at DESC").Find(&versions).Error
	return versions, err
}

func (r VersionRepository) GetCurrentVersion(softwareID uint) (*model.Version, error) {
	var version model.Version
	err := r.db.Where("software_id = ? AND is_current = true", softwareID).First(&version).Error
	return &version, err
}

func (r VersionRepository) Update(version *model.Version) error {
	return r.db.Save(version).Error
}

func (r VersionRepository) Delete(id uint) error {
	return r.db.Delete(&model.Version{}, id).Error
}

func (r VersionRepository) UpdateStatus(id uint, status string) error {
	return r.db.Model(&model.Version{}).Where("id = ?", id).Update("status", status).Error
}

func (r VersionRepository) SetCurrentVersion(softwareID, versionID uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// 取消当前版本
		if err := tx.Model(&model.Version{}).Where("software_id = ? AND is_current = true", softwareID).Update("is_current", false).Error; err != nil {
			return err
		}
		// 设置新当前版本
		return tx.Model(&model.Version{}).Where("id = ?", versionID).Update("is_current", true).Error
	})
}

// UserRepository 用户仓储
type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return UserRepository{db: db}
}

func (r UserRepository) Create(user *model.User) error {
	return r.db.Create(user).Error
}

func (r UserRepository) GetByID(id uint) (*model.User, error) {
	var user model.User
	err := r.db.Preload("Role").First(&user, id).Error
	return &user, err
}

func (r UserRepository) GetByUsername(username string) (*model.User, error) {
	var user model.User
	err := r.db.Preload("Role").Where("username = ?", username).First(&user).Error
	return &user, err
}

func (r UserRepository) List(offset, limit int) ([]model.User, int64, error) {
	var users []model.User
	var total int64
	err := r.db.Model(&model.User{}).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = r.db.Preload("Role").Offset(offset).Limit(limit).Find(&users).Error
	return users, total, err
}

func (r UserRepository) Update(user *model.User) error {
	return r.db.Save(user).Error
}

func (r UserRepository) Delete(id uint) error {
	return r.db.Delete(&model.User{}, id).Error
}

// RoleRepository 角色仓储
type RoleRepository struct {
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) RoleRepository {
	return RoleRepository{db: db}
}

func (r RoleRepository) Create(role *model.Role) error {
	return r.db.Create(role).Error
}

func (r RoleRepository) GetByID(id uint) (*model.Role, error) {
	var role model.Role
	err := r.db.Preload("Permissions").First(&role, id).Error
	return &role, err
}

func (r RoleRepository) List() ([]model.Role, error) {
	var roles []model.Role
	err := r.db.Preload("Permissions").Find(&roles).Error
	return roles, err
}

func (r RoleRepository) Update(role *model.Role) error {
	return r.db.Save(role).Error
}

func (r RoleRepository) Delete(id uint) error {
	return r.db.Delete(&model.Role{}, id).Error
}

// StorageConfigRepository 存储配置仓储
type StorageConfigRepository struct {
	db *gorm.DB
}

func NewStorageConfigRepository(db *gorm.DB) StorageConfigRepository {
	return StorageConfigRepository{db: db}
}

func (r StorageConfigRepository) Create(config *model.StorageConfig) error {
	return r.db.Create(config).Error
}

func (r StorageConfigRepository) GetByID(id uint) (*model.StorageConfig, error) {
	var config model.StorageConfig
	err := r.db.First(&config, id).Error
	return &config, err
}

func (r StorageConfigRepository) GetDefault() (*model.StorageConfig, error) {
	var config model.StorageConfig
	err := r.db.Where("is_default = true").First(&config).Error
	return &config, err
}

func (r StorageConfigRepository) List() ([]model.StorageConfig, error) {
	var configs []model.StorageConfig
	err := r.db.Find(&configs).Error
	return configs, err
}

func (r StorageConfigRepository) Update(config *model.StorageConfig) error {
	return r.db.Save(config).Error
}

func (r StorageConfigRepository) SetDefault(id uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&model.StorageConfig{}).Where("is_default = true").Update("is_default", false).Error; err != nil {
			return err
		}
		return tx.Model(&model.StorageConfig{}).Where("id = ?", id).Update("is_default", true).Error
	})
}

// ClientRepository 客户端仓储
type ClientRepository struct {
	db *gorm.DB
}

func NewClientRepository(db *gorm.DB) ClientRepository {
	return ClientRepository{db: db}
}

func (r ClientRepository) Create(client *model.Client) error {
	return r.db.Create(client).Error
}

func (r ClientRepository) GetByClientID(clientID string) (*model.Client, error) {
	var client model.Client
	err := r.db.Where("client_id = ?", clientID).First(&client).Error
	return &client, err
}

func (r ClientRepository) List(softwareID uint, status string, offset, limit int) ([]model.Client, int64, error) {
	var clients []model.Client
	var total int64
	query := r.db.Model(&model.Client{})
	
	if softwareID > 0 {
		query = query.Where("software_id = ?", softwareID)
	}
	if status != "" {
		query = query.Where("status = ?", status)
	}
	
	err := query.Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = query.Offset(offset).Limit(limit).Find(&clients).Error
	return clients, total, err
}

func (r ClientRepository) Update(client *model.Client) error {
	return r.db.Save(client).Error
}

func (r ClientRepository) Delete(id uint) error {
	return r.db.Delete(&model.Client{}, id).Error
}

func (r ClientRepository) UpdateHeartbeat(clientID string) error {
	return r.db.Model(&model.Client{}).Where("client_id = ?", clientID).Updates(map[string]interface{}{
		"last_heartbeat": gorm.Expr("NOW()"),
		"status": "online",
	}).Error
}

// PushRecordRepository 推送记录仓储
type PushRecordRepository struct {
	db *gorm.DB
}

func NewPushRecordRepository(db *gorm.DB) PushRecordRepository {
	return PushRecordRepository{db: db}
}

func (r PushRecordRepository) Create(record *model.PushRecord) error {
	return r.db.Create(record).Error
}

func (r PushRecordRepository) GetByPushID(pushID string) (*model.PushRecord, error) {
	var record model.PushRecord
	err := r.db.Where("push_id = ?", pushID).First(&record).Error
	return &record, err
}

func (r PushRecordRepository) List(versionID uint, offset, limit int) ([]model.PushRecord, int64, error) {
	var records []model.PushRecord
	var total int64
	query := r.db.Model(&model.PushRecord{})
	
	if versionID > 0 {
		query = query.Where("version_id = ?", versionID)
	}
	
	err := query.Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = query.Offset(offset).Limit(limit).Order("pushed_at DESC").Find(&records).Error
	return records, total, err
}

// RateLimitRepository 限流配置仓储
type RateLimitRepository struct {
	db *gorm.DB
}

func NewRateLimitRepository(db *gorm.DB) RateLimitRepository {
	return RateLimitRepository{db: db}
}

func (r RateLimitRepository) Create(limit *model.RateLimit) error {
	return r.db.Create(limit).Error
}

func (r RateLimitRepository) GetByKey(key string) (*model.RateLimit, error) {
	var limit model.RateLimit
	err := r.db.Where("key = ?", key).First(&limit).Error
	return &limit, err
}

func (r RateLimitRepository) List() ([]model.RateLimit, error) {
	var limits []model.RateLimit
	err := r.db.Find(&limits).Error
	return limits, err
}

func (r RateLimitRepository) Update(limit *model.RateLimit) error {
	return r.db.Save(limit).Error
}

// WebhookRepository Webhook仓储
type WebhookRepository struct {
	db *gorm.DB
}

func NewWebhookRepository(db *gorm.DB) WebhookRepository {
	return WebhookRepository{db: db}
}

func (r WebhookRepository) Create(webhook *model.Webhook) error {
	return r.db.Create(webhook).Error
}

func (r WebhookRepository) GetByID(id uint) (*model.Webhook, error) {
	var webhook model.Webhook
	err := r.db.First(&webhook, id).Error
	return &webhook, err
}

func (r WebhookRepository) List() ([]model.Webhook, error) {
	var webhooks []model.Webhook
	err := r.db.Find(&webhooks).Error
	return webhooks, err
}

func (r WebhookRepository) Update(webhook *model.Webhook) error {
	return r.db.Save(webhook).Error
}

func (r WebhookRepository) Delete(id uint) error {
	return r.db.Delete(&model.Webhook{}, id).Error
}

func (r WebhookRepository) GetEnabledByEvent(event string) ([]model.Webhook, error) {
	var webhooks []model.Webhook
	err := r.db.Where("enabled = true AND events @> ?", `["`+event+`"]`).Find(&webhooks).Error
	return webhooks, err
}

// DownloadStatRepository 下载统计仓储
type DownloadStatRepository struct {
	db *gorm.DB
}

func NewDownloadStatRepository(db *gorm.DB) DownloadStatRepository {
	return DownloadStatRepository{db: db}
}

func (r DownloadStatRepository) Create(stat *model.DownloadStat) error {
	return r.db.Create(stat).Error
}

func (r DownloadStatRepository) GetStatsByVersionID(versionID uint, offset, limit int) ([]model.DownloadStat, int64, error) {
	var stats []model.DownloadStat
	var total int64
	err := r.db.Model(&model.DownloadStat{}).Where("version_id = ?", versionID).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = r.db.Where("version_id = ?", versionID).Offset(offset).Limit(limit).Order("download_time DESC").Find(&stats).Error
	return stats, total, err
}

func (r DownloadStatRepository) GetStatsByDateRange(startDate, endDate string) ([]model.DownloadStat, error) {
	var stats []model.DownloadStat
	err := r.db.Where("download_time BETWEEN ? AND ?", startDate, endDate).Find(&stats).Error
	return stats, err
}

// IPWhitelistRepository IP白名单仓储
type IPWhitelistRepository struct {
	db *gorm.DB
}

func NewIPWhitelistRepository(db *gorm.DB) IPWhitelistRepository {
	return IPWhitelistRepository{db: db}
}

func (r IPWhitelistRepository) Create(whitelist *model.IPWhitelist) error {
	return r.db.Create(whitelist).Error
}

func (r IPWhitelistRepository) GetByID(id uint) (*model.IPWhitelist, error) {
	var whitelist model.IPWhitelist
	err := r.db.First(&whitelist, id).Error
	return &whitelist, err
}

func (r IPWhitelistRepository) List() ([]model.IPWhitelist, error) {
	var whitelists []model.IPWhitelist
	err := r.db.Find(&whitelists).Error
	return whitelists, err
}

func (r IPWhitelistRepository) Delete(id uint) error {
	return r.db.Delete(&model.IPWhitelist{}, id).Error
}

func (r IPWhitelistRepository) IsIPAllowed(ip string) (bool, error) {
	var count int64
	err := r.db.Model(&model.IPWhitelist{}).Where("ip_address = ? AND enabled = true", ip).Count(&count).Error
	return count > 0, err
}

// IPBlacklistRepository IP黑名单仓储
type IPBlacklistRepository struct {
	db *gorm.DB
}

func NewIPBlacklistRepository(db *gorm.DB) IPBlacklistRepository {
	return IPBlacklistRepository{db: db}
}

func (r IPBlacklistRepository) Create(blacklist *model.IPBlacklist) error {
	return r.db.Create(blacklist).Error
}

func (r IPBlacklistRepository) GetByID(id uint) (*model.IPBlacklist, error) {
	var blacklist model.IPBlacklist
	err := r.db.First(&blacklist, id).Error
	return &blacklist, err
}

func (r IPBlacklistRepository) List() ([]model.IPBlacklist, error) {
	var blacklists []model.IPBlacklist
	err := r.db.Find(&blacklists).Error
	return blacklists, err
}

func (r IPBlacklistRepository) Delete(id uint) error {
	return r.db.Delete(&model.IPBlacklist{}, id).Error
}

func (r IPBlacklistRepository) IsIPBanned(ip string) (bool, error) {
	var count int64
	err := r.db.Model(&model.IPBlacklist{}).Where("ip_address = ? AND (ban_type = 'permanent' OR expires_at > NOW())").Count(&count).Error
	return count > 0, err
}

// SecurityLogRepository 安全日志仓储
type SecurityLogRepository struct {
	db *gorm.DB
}

func NewSecurityLogRepository(db *gorm.DB) SecurityLogRepository {
	return SecurityLogRepository{db: db}
}

func (r SecurityLogRepository) Create(log *model.SecurityLog) error {
	return r.db.Create(log).Error
}

func (r SecurityLogRepository) GetLogs(startDate, endDate string, offset, limit int) ([]model.SecurityLog, int64, error) {
	var logs []model.SecurityLog
	var total int64
	query := r.db.Model(&model.SecurityLog{})
	
	if startDate != "" && endDate != "" {
		query = query.Where("created_at BETWEEN ? AND ?", startDate, endDate)
	}
	
	err := query.Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&logs).Error
	return logs, total, err
}

func (r SecurityLogRepository) GetSuspiciousLogs(offset, limit int) ([]model.SecurityLog, int64, error) {
	var logs []model.SecurityLog
	var total int64
	err := r.db.Model(&model.SecurityLog{}).Where("blocked = true OR token_valid = false OR signature_valid = false").Count(&total).Error
	if err != nil {
		return nil, 0, err
	}
	err = r.db.Where("blocked = true OR token_valid = false OR signature_valid = false").Offset(offset).Limit(limit).Order("created_at DESC").Find(&logs).Error
	return logs, total, err
}
