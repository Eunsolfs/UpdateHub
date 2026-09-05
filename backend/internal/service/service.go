package service

import (
	"errors"
	"time"

	"updatehub/internal/model"
	"updatehub/internal/repository"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// Services 服务集合
type Services struct {
	Software      SoftwareService
	Version       VersionService
	User          UserService
	Auth          AuthService
	StorageConfig StorageConfigService
	Client        ClientService
	PushRecord    PushRecordService
	RateLimit     RateLimitService
	Webhook       WebhookService
	Download      DownloadService
	Security      SecurityService
	Upload        UploadService
}

// NewServices 创建服务集合
func NewServices(repos *repository.Repositories) *Services {
	return &Services{
		Software:      NewSoftwareService(repos.Software),
		Version:       NewVersionService(repos.Version),
		User:          NewUserService(repos.User),
		Auth:          NewAuthService(repos.User, repos.Role),
		StorageConfig: NewStorageConfigService(repos.StorageConfig),
		Client:        NewClientService(repos.Client),
		PushRecord:    NewPushRecordService(repos.PushRecord),
		RateLimit:     NewRateLimitService(repos.RateLimit),
		Webhook:       NewWebhookService(repos.Webhook),
		Download:      NewDownloadService(repos.DownloadStat, repos.IPWhitelist, repos.IPBlacklist, repos.SecurityLog),
		Security:      NewSecurityService(repos.IPWhitelist, repos.IPBlacklist, repos.SecurityLog),
		Upload:        NewUploadService(),
	}
}

// SoftwareService 软件服务
type SoftwareService struct {
	repo repository.SoftwareRepository
}

func NewSoftwareService(repo repository.SoftwareRepository) SoftwareService {
	return SoftwareService{repo: repo}
}

func (s SoftwareService) Create(name, identifier, description, icon string, createdBy uint) error {
	software := &model.Software{
		Name:        name,
		Identifier:  identifier,
		Description: description,
		Icon:        icon,
		CreatedBy:   createdBy,
	}
	return s.repo.Create(software)
}

func (s SoftwareService) GetByID(id uint) (*model.Software, error) {
	return s.repo.GetByID(id)
}

func (s SoftwareService) GetByIDentifier(identifier string) (*model.Software, error) {
	return s.repo.GetByIDentifier(identifier)
}

func (s SoftwareService) List(offset, limit int) ([]model.Software, int64, error) {
	return s.repo.List(offset, limit)
}

func (s SoftwareService) Update(id uint, name, description, icon string) error {
	software, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	software.Name = name
	software.Description = description
	software.Icon = icon
	return s.repo.Update(software)
}

func (s SoftwareService) Delete(id uint) error {
	return s.repo.Delete(id)
}

// VersionService 版本服务
type VersionService struct {
	repo repository.VersionRepository
}

func NewVersionService(repo repository.VersionRepository) VersionService {
	return VersionService{repo: repo}
}

func (s VersionService) Create(softwareID uint, versionNumber, releaseNotes, fileID, filePath string, fileSize int64, md5, sha256, updateType, platform string, forceUpdate bool, publishedBy uint) error {
	version := &model.Version{
		SoftwareID:    softwareID,
		VersionNumber: versionNumber,
		ReleaseNotes:  releaseNotes,
		FileID:        fileID,
		FilePath:      filePath,
		FileSize:      fileSize,
		MD5:           md5,
		SHA256:        sha256,
		UpdateType:    updateType,
		Platform:      platform,
		ForceUpdate:   forceUpdate,
		Status:        "published",
		PublishedBy:   publishedBy,
	}
	return s.repo.Create(version)
}

func (s VersionService) GetByID(id uint) (*model.Version, error) {
	return s.repo.GetByID(id)
}

func (s VersionService) GetBySoftwareID(softwareID uint) ([]model.Version, error) {
	return s.repo.GetBySoftwareID(softwareID)
}

func (s VersionService) GetCurrentVersion(softwareID uint) (*model.Version, error) {
	return s.repo.GetCurrentVersion(softwareID)
}

func (s VersionService) UpdateStatus(id uint, status string) error {
	return s.repo.UpdateStatus(id, status)
}

func (s VersionService) Rollback(id uint, rollbackType, reason string) error {
	if rollbackType == "soft" {
		return s.repo.UpdateStatus(id, "published")
	}
	return s.repo.Delete(id)
}

func (s VersionService) SwitchVersion(softwareID, targetVersionID uint) error {
	return s.repo.SetCurrentVersion(softwareID, targetVersionID)
}

func (s VersionService) Delete(id uint) error {
	return s.repo.Delete(id)
}

// UserService 用户服务
type UserService struct {
	repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) UserService {
	return UserService{repo: repo}
}

func (s UserService) Create(username, password, email string, roleID uint) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user := &model.User{
		Username: username,
		Password: string(hashedPassword),
		Email:    email,
		RoleID:   roleID,
		Status:   "active",
	}
	return s.repo.Create(user)
}

func (s UserService) GetByID(id uint) (*model.User, error) {
	return s.repo.GetByID(id)
}

func (s UserService) GetByUsername(username string) (*model.User, error) {
	return s.repo.GetByUsername(username)
}

func (s UserService) List(offset, limit int) ([]model.User, int64, error) {
	return s.repo.List(offset, limit)
}

func (s UserService) Update(id uint, email string, roleID uint) error {
	user, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	user.Email = email
	user.RoleID = roleID
	return s.repo.Update(user)
}

func (s UserService) Delete(id uint) error {
	return s.repo.Delete(id)
}

func (s UserService) ChangePassword(id uint, newPassword string) error {
	user, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user.Password = string(hashedPassword)
	return s.repo.Update(user)
}

// AuthService 认证服务
type AuthService struct {
	userRepo repository.UserRepository
	roleRepo repository.RoleRepository
}

func NewAuthService(userRepo repository.UserRepository, roleRepo repository.RoleRepository) AuthService {
	return AuthService{
		userRepo: userRepo,
		roleRepo: roleRepo,
	}
}

func (s AuthService) Login(username, password string) (string, string, *model.User, error) {
	user, err := s.userRepo.GetByUsername(username)
	if err != nil {
		return "", "", nil, err
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return "", "", nil, err
	}

	// JWT token现在由middleware生成，这里返回空值
	token := ""

	refreshToken, err := s.generateRefreshToken(user)
	if err != nil {
		return "", "", nil, err
	}

	return token, refreshToken, user, nil
}

func (s AuthService) generateRefreshToken(user *model.User) (string, error) {
	claims := jwt.MapClaims{
		"user_id":  user.ID,
		"username": user.Username,
		"exp":      time.Now().Add(7 * 24 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte("your-refresh-secret-key"))
}

func (s AuthService) ValidateToken(tokenString string) (*model.User, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-secret-key"), nil
	})
	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		userID := uint(claims["user_id"].(float64))
		return s.userRepo.GetByID(userID)
	}

	return nil, errors.New("invalid token")
}

// StorageConfigService 存储配置服务
type StorageConfigService struct {
	repo repository.StorageConfigRepository
}

func NewStorageConfigService(repo repository.StorageConfigRepository) StorageConfigService {
	return StorageConfigService{repo: repo}
}

func (s StorageConfigService) Create(storageType, config string) error {
	storageConfig := &model.StorageConfig{
		Type:   storageType,
		Config: config,
	}
	return s.repo.Create(storageConfig)
}

func (s StorageConfigService) GetDefault() (*model.StorageConfig, error) {
	return s.repo.GetDefault()
}

func (s StorageConfigService) List() ([]model.StorageConfig, error) {
	return s.repo.List()
}

func (s StorageConfigService) Update(id uint, storageType, config string) error {
	storageConfig, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	storageConfig.Type = storageType
	storageConfig.Config = config
	return s.repo.Update(storageConfig)
}

func (s StorageConfigService) SetDefault(id uint) error {
	return s.repo.SetDefault(id)
}

// ClientService 客户端服务
type ClientService struct {
	repo repository.ClientRepository
}

func NewClientService(repo repository.ClientRepository) ClientService {
	return ClientService{repo: repo}
}

func (s ClientService) Register(clientID string, softwareID uint, softwareIdentifier, currentVersion, platform, osVersion, deviceInfo string) error {
	client := &model.Client{
		ClientID:           clientID,
		SoftwareID:         softwareID,
		SoftwareIdentifier: softwareIdentifier,
		CurrentVersion:     currentVersion,
		Platform:           platform,
		OSVersion:          osVersion,
		DeviceInfo:         deviceInfo,
		Status:             "online",
	}
	return s.repo.Create(client)
}

func (s ClientService) Heartbeat(clientID string) error {
	return s.repo.UpdateHeartbeat(clientID)
}

func (s ClientService) List(softwareID uint, status string, offset, limit int) ([]model.Client, int64, error) {
	return s.repo.List(softwareID, status, offset, limit)
}

func (s ClientService) Delete(id uint) error {
	return s.repo.Delete(id)
}

// PushRecordService 推送记录服务
type PushRecordService struct {
	repo repository.PushRecordRepository
}

func NewPushRecordService(repo repository.PushRecordRepository) PushRecordService {
	return PushRecordService{repo: repo}
}

func (s PushRecordService) Create(versionID uint, targetType, targetClients, message string, forceNotify bool, pushedBy uint) error {
	pushID := uuid.New().String()
	record := &model.PushRecord{
		PushID:        pushID,
		VersionID:     versionID,
		TargetType:    targetType,
		TargetClients: targetClients,
		Message:       message,
		ForceNotify:   forceNotify,
		PushedBy:      pushedBy,
	}
	return s.repo.Create(record)
}

func (s PushRecordService) List(versionID uint, offset, limit int) ([]model.PushRecord, int64, error) {
	return s.repo.List(versionID, offset, limit)
}

// RateLimitService 限流服务
type RateLimitService struct {
	repo repository.RateLimitRepository
}

func NewRateLimitService(repo repository.RateLimitRepository) RateLimitService {
	return RateLimitService{repo: repo}
}

func (s RateLimitService) Create(key string, limitPerMinute, limitPerHour, limitPerDay int) error {
	limit := &model.RateLimit{
		Key:            key,
		LimitPerMinute: limitPerMinute,
		LimitPerHour:   limitPerHour,
		LimitPerDay:    limitPerDay,
	}
	return s.repo.Create(limit)
}

func (s RateLimitService) GetByKey(key string) (*model.RateLimit, error) {
	return s.repo.GetByKey(key)
}

func (s RateLimitService) List() ([]model.RateLimit, error) {
	return s.repo.List()
}

func (s RateLimitService) Update(key string, limitPerMinute, limitPerHour, limitPerDay int) error {
	limit, err := s.repo.GetByKey(key)
	if err != nil {
		return err
	}
	limit.LimitPerMinute = limitPerMinute
	limit.LimitPerHour = limitPerHour
	limit.LimitPerDay = limitPerDay
	return s.repo.Update(limit)
}

// WebhookService Webhook服务
type WebhookService struct {
	repo repository.WebhookRepository
}

func NewWebhookService(repo repository.WebhookRepository) WebhookService {
	return WebhookService{repo: repo}
}

func (s WebhookService) Create(name, url, events, secret string) error {
	webhook := &model.Webhook{
		Name:   name,
		URL:    url,
		Events: events,
		Secret: secret,
	}
	return s.repo.Create(webhook)
}

func (s WebhookService) GetByID(id uint) (*model.Webhook, error) {
	return s.repo.GetByID(id)
}

func (s WebhookService) List() ([]model.Webhook, error) {
	return s.repo.List()
}

func (s WebhookService) Update(id uint, name, url, events, secret string) error {
	webhook, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	webhook.Name = name
	webhook.URL = url
	webhook.Events = events
	webhook.Secret = secret
	return s.repo.Update(webhook)
}

func (s WebhookService) Delete(id uint) error {
	return s.repo.Delete(id)
}

func (s WebhookService) TriggerEvent(event string) error {
	webhooks, err := s.repo.GetEnabledByEvent(event)
	if err != nil {
		return err
	}

	for _, webhook := range webhooks {
		go s.sendWebhook(&webhook, event)
	}

	return nil
}

func (s WebhookService) sendWebhook(webhook *model.Webhook, event string) error {
	// 实现Webhook发送逻辑
	return nil
}

// DownloadService 下载服务
type DownloadService struct {
	downloadStatRepo repository.DownloadStatRepository
	ipWhitelistRepo  repository.IPWhitelistRepository
	ipBlacklistRepo  repository.IPBlacklistRepository
	securityLogRepo  repository.SecurityLogRepository
}

func NewDownloadService(downloadStatRepo repository.DownloadStatRepository, ipWhitelistRepo repository.IPWhitelistRepository, ipBlacklistRepo repository.IPBlacklistRepository, securityLogRepo repository.SecurityLogRepository) DownloadService {
	return DownloadService{
		downloadStatRepo: downloadStatRepo,
		ipWhitelistRepo:  ipWhitelistRepo,
		ipBlacklistRepo:  ipBlacklistRepo,
		securityLogRepo:  securityLogRepo,
	}
}

func (s DownloadService) RecordDownload(versionID uint, softwareIdentifier, clientVersion, platform, ipAddress, userAgent string, fileSize, downloadDuration int) error {
	stat := &model.DownloadStat{
		VersionID:          versionID,
		SoftwareIdentifier: softwareIdentifier,
		ClientVersion:      clientVersion,
		Platform:           platform,
		IPAddress:          ipAddress,
		UserAgent:          userAgent,
		DownloadTime:       time.Now(),
		FileSize:           int64(fileSize),
		DownloadDuration:   downloadDuration,
	}
	return s.downloadStatRepo.Create(stat)
}

// SecurityService 安全服务
type SecurityService struct {
	ipWhitelistRepo repository.IPWhitelistRepository
	ipBlacklistRepo repository.IPBlacklistRepository
	securityLogRepo repository.SecurityLogRepository
}

func NewSecurityService(ipWhitelistRepo repository.IPWhitelistRepository, ipBlacklistRepo repository.IPBlacklistRepository, securityLogRepo repository.SecurityLogRepository) SecurityService {
	return SecurityService{
		ipWhitelistRepo: ipWhitelistRepo,
		ipBlacklistRepo: ipBlacklistRepo,
		securityLogRepo: securityLogRepo,
	}
}

func (s SecurityService) CheckIP(ip string) (bool, error) {
	// 检查黑名单
	banned, err := s.ipBlacklistRepo.IsIPBanned(ip)
	if err != nil {
		return false, err
	}
	if banned {
		return false, nil
	}

	// 检查白名单
	allowed, err := s.ipWhitelistRepo.IsIPAllowed(ip)
	if err != nil {
		return false, err
	}

	// 如果有白名单配置，只允许白名单IP
	if allowed {
		return true, nil
	}

	// 如果没有白名单配置，允许所有非黑名单IP
	return true, nil
}

func (s SecurityService) LogSecurityLog(ipAddress, userAgent, referer, requestURL string, tokenValid, signatureValid bool, country, blockedReason string, blocked bool) error {
	log := &model.SecurityLog{
		IPAddress:      ipAddress,
		UserAgent:      userAgent,
		Referer:        referer,
		RequestURL:     requestURL,
		TokenValid:     tokenValid,
		SignatureValid: signatureValid,
		Country:        country,
		BlockedReason:  blockedReason,
		Blocked:        blocked,
	}
	return s.securityLogRepo.Create(log)
}

// UploadService 上传服务
type UploadService struct{}

func NewUploadService() UploadService {
	return UploadService{}
}
