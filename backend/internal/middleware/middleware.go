package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// CORS 跨域中间件
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// Logger 日志中间件
func Logger() gin.HandlerFunc {
	return gin.Logger()
}

// Recovery 恢复中间件
func Recovery() gin.HandlerFunc {
	return gin.Recovery()
}

// RateLimit 限流中间件
func RateLimit() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 这里应该实现限流逻辑
		// 暂时简化处理
		c.Next()
	}
}
