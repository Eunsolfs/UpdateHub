package main

import (
	"log"
	"updatehub/internal/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	// 创建路由
	r := gin.Default()

	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())
	r.Use(middleware.Recovery())

	// 简单的健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "UpdateHub server is running"})
	})

	// API 路由
	v1 := r.Group("/api/v1")
	{
		// 认证接口
		v1.POST("/auth/login", func(c *gin.Context) {
			var req struct {
				Username string `json:"username"`
				Password string `json:"password"`
			}
			if err := c.ShouldBindJSON(&req); err != nil {
				c.JSON(400, gin.H{"code": 400, "message": err.Error()})
				return
			}

			// 简化认证逻辑
			if req.Username == "admin" && req.Password == "admin123" {
				token, err := middleware.GenerateToken(1, "admin", 1)
				if err != nil {
					c.JSON(500, gin.H{"code": 500, "message": "failed to generate token"})
					return
				}
				c.JSON(200, gin.H{
					"code":    0,
					"message": "success",
					"data": gin.H{
						"token": token,
						"user": gin.H{
							"id":       1,
							"username": "admin",
							"email":    "admin@updatehub.com",
						},
					},
				})
			} else {
				c.JSON(401, gin.H{"code": 401, "message": "invalid credentials"})
			}
		})

		// 软件管理接口（需要认证）
		auth := v1.Group("")
		auth.Use(middleware.Auth())
		{
			auth.GET("/software", func(c *gin.Context) {
				c.JSON(200, gin.H{
					"code":    0,
					"message": "success",
					"data": gin.H{
						"software": []gin.H{
							{"id": 1, "name": "MyApp", "identifier": "my-app", "description": "示例应用"},
						},
						"total": 1,
					},
				})
			})

			auth.POST("/software", func(c *gin.Context) {
				c.JSON(200, gin.H{"code": 0, "message": "success"})
			})
		}

		// WebSocket
		v1.GET("/ws/client", func(c *gin.Context) {
			c.JSON(200, gin.H{"code": 0, "message": "WebSocket endpoint"})
		})
		v1.GET("/ws/admin", func(c *gin.Context) {
			c.JSON(200, gin.H{"code": 0, "message": "WebSocket endpoint"})
		})
	}

	// 启动服务器
	log.Println("UpdateHub server starting on :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
