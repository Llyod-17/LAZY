package router

import (
	"log/slog"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	"lazy/server/internal/handler"
	"lazy/server/internal/middleware"
	"lazy/server/internal/model"
)

type RouterDeps struct {
	Logger        *slog.Logger
	HealthHandler *handler.HealthHandler
	AIHandler     *handler.AIHandler
}

func Setup(deps RouterDeps) *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()

	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		_ = v.RegisterValidation("ianatimezone", model.ValidateIANATimezone)
	}

	r.Use(gin.Recovery())
	if deps.Logger != nil {
		r.Use(middleware.Logger(deps.Logger))
	}

	api := r.Group("/api/v1")
	{
		if deps.HealthHandler != nil {
			api.GET("/health", deps.HealthHandler.Health)
		}
		if deps.AIHandler != nil {
			api.POST("/ai/parse", deps.AIHandler.ParseBrainDump)
		}
	}

	return r
}
