package handler

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"lazy/server/internal/model"
	"lazy/server/internal/provider"
	"lazy/server/internal/service"
)

type AIHandler struct {
	provider provider.AIProvider
}

func NewAIHandler(p provider.AIProvider) *AIHandler {
	return &AIHandler{
		provider: p,
	}
}

func (h *AIHandler) ParseBrainDump(c *gin.Context) {
	var req model.ParseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		errResp := model.NewErrorResponse(
			model.ErrValidation,
			"Request tidak valid atau format salah",
			err.Error(),
		)
		c.JSON(errResp.HTTPStatus(), errResp)
		return
	}

	systemPrompt := service.BuildSystemPrompt(req.NowMs, req.Timezone)

	rawResponse, err := h.provider.ChatCompletion(c.Request.Context(), systemPrompt, req.Text)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) || strings.Contains(strings.ToLower(err.Error()), "timeout") {
			errResp := model.NewErrorResponse(
				model.ErrTimeout,
				"Permintaan ke penyedia AI memakan waktu terlalu lama (timeout)",
				nil,
			)
			c.JSON(errResp.HTTPStatus(), errResp)
			return
		}

		errResp := model.NewErrorResponse(
			model.ErrProvider,
			"Gagal berkomunikasi dengan penyedia AI",
			err.Error(),
		)
		c.JSON(errResp.HTTPStatus(), errResp)
		return
	}

	parsed, err := service.CleanAndParseResponse(rawResponse)
	if err != nil {
		errResp := model.NewErrorResponse(
			model.ErrAISchema,
			"Format keluaran dari model AI tidak sesuai spesifikasi",
			err.Error(),
		)
		c.JSON(errResp.HTTPStatus(), errResp)
		return
	}

	c.JSON(http.StatusOK, parsed)
}
