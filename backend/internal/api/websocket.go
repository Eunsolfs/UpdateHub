package api

import (
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // 允许所有来源
	},
}

// WebSocketHub WebSocket连接管理器
type WebSocketHub struct {
	clients    map[*websocket.Conn]bool
	broadcast  chan []byte
	register   chan *websocket.Conn
	unregister chan *websocket.Conn
	mutex      sync.RWMutex
}

var hub = &WebSocketHub{
	clients:    make(map[*websocket.Conn]bool),
	broadcast:  make(chan []byte),
	register:   make(chan *websocket.Conn),
	unregister: make(chan *websocket.Conn),
}

// Run 运行WebSocket Hub
func (h *WebSocketHub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mutex.Lock()
			h.clients[client] = true
			h.mutex.Unlock()
			log.Println("WebSocket client connected")

		case client := <-h.unregister:
			h.mutex.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				client.Close()
			}
			h.mutex.Unlock()
			log.Println("WebSocket client disconnected")

		case message := <-h.broadcast:
			h.mutex.RLock()
			for client := range h.clients {
				err := client.WriteMessage(websocket.TextMessage, message)
				if err != nil {
					h.unregister <- client
				}
			}
			h.mutex.RUnlock()
		}
	}
}

// BroadcastMessage 广播消息给所有客户端
func BroadcastMessage(message []byte) {
	hub.broadcast <- message
}

// WebSocketHandler WebSocket处理器
type WebSocketHandler struct{}

func NewWebSocketHandler() WebSocketHandler {
	return WebSocketHandler{}
}

// 启动WebSocket Hub
func init() {
	go hub.Run()
}

func (h WebSocketHandler) ClientWebSocket(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}

	hub.register <- conn

	// 处理客户端消息
	go func() {
		defer func() {
			hub.unregister <- conn
		}()

		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				break
			}

			// 处理客户端消息
			log.Printf("Received message: %s", string(message))

			// 示例：回复消息
			response := []byte(`{"type":"ack","data":"message received"}`)
			err = conn.WriteMessage(websocket.TextMessage, response)
			if err != nil {
				break
			}
		}
	}()
}

func (h WebSocketHandler) AdminWebSocket(c *gin.Context) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}

	hub.register <- conn

	// 处理管理后台消息
	go func() {
		defer func() {
			hub.unregister <- conn
		}()

		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				break
			}

			// 处理管理后台消息
			log.Printf("Admin received message: %s", string(message))

			// 示例：发送系统状态
			stats := `{"type":"stats","data":{"online_clients":150,"total_downloads":1250}}`
			response := []byte(stats)
			err = conn.WriteMessage(websocket.TextMessage, response)
			if err != nil {
				break
			}
		}
	}()
}
