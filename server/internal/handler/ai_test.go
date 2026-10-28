package handler_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"lazy/server/internal/handler"
	"lazy/server/internal/model"
	"lazy/server/internal/router"
)

type mockAIProvider struct {
	response string
	err      error
}

func (m *mockAIProvider) ChatCompletion(ctx context.Context, systemPrompt, userPrompt string) (string, error) {
	if m.err != nil {
		return "", m.err
	}
	return m.response, nil
}

func setupTestRouter(p *mockAIProvider) *gin.Engine {
	return router.Setup(router.RouterDeps{
		AIHandler: handler.NewAIHandler(p),
	})
}

func TestParseBrainDump_Success(t *testing.T) {
	mockP := &mockAIProvider{
		response: `{
			"items": [
				{
					"title": "Beli deterjen",
					"suggestedDate": "2025-10-20",
					"suggestedTime": "10:00",
					"priority": "low",
					"reason": "Belanja santai"
				}
			]
		}`,
	}

	r := setupTestRouter(mockP)

	reqBody := `{"text": "Beli deterjen tgl 20 jam 10", "timezone": "Asia/Jakarta", "nowMs": 1729000000000}`
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/ai/parse", bytes.NewBufferString(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d, body: %s", w.Code, w.Body.String())
	}

	var resp model.ParseResponse
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}

	if len(resp.Items) != 1 || resp.Items[0].Title != "Beli deterjen" {
		t.Errorf("unexpected extracted items: %+v", resp.Items)
	}
}

func TestParseBrainDump_ValidationError(t *testing.T) {
	mockP := &mockAIProvider{}
	r := setupTestRouter(mockP)

	// text too short
	reqBody := `{"text": "x", "timezone": "Asia/Jakarta", "nowMs": 1729000000000}`
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/ai/parse", bytes.NewBufferString(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for short text, got %d", w.Code)
	}

	var errResp model.ErrorResponse
	_ = json.Unmarshal(w.Body.Bytes(), &errResp)
	if errResp.Code != model.ErrValidation {
		t.Errorf("expected code validation_error, got %s", errResp.Code)
	}
}

func TestParseBrainDump_TimeoutError(t *testing.T) {
	mockP := &mockAIProvider{
		err: context.DeadlineExceeded,
	}
	r := setupTestRouter(mockP)

	reqBody := `{"text": "Kerjakan PR fisika besok", "timezone": "Asia/Jakarta", "nowMs": 1729000000000}`
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/ai/parse", bytes.NewBufferString(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusRequestTimeout {
		t.Errorf("expected 408 on timeout, got %d", w.Code)
	}

	var errResp model.ErrorResponse
	_ = json.Unmarshal(w.Body.Bytes(), &errResp)
	if errResp.Code != model.ErrTimeout {
		t.Errorf("expected code timeout, got %s", errResp.Code)
	}
}

func TestParseBrainDump_ProviderError(t *testing.T) {
	mockP := &mockAIProvider{
		err: errors.New("connection reset by peer"),
	}
	r := setupTestRouter(mockP)

	reqBody := `{"text": "Kerjakan PR fisika besok", "timezone": "Asia/Jakarta", "nowMs": 1729000000000}`
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/ai/parse", bytes.NewBufferString(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadGateway {
		t.Errorf("expected 502 on provider error, got %d", w.Code)
	}

	var errResp model.ErrorResponse
	_ = json.Unmarshal(w.Body.Bytes(), &errResp)
	if errResp.Code != model.ErrProvider {
		t.Errorf("expected code provider_error, got %s", errResp.Code)
	}
}

func TestParseBrainDump_AISchemaInvalid(t *testing.T) {
	mockP := &mockAIProvider{
		response: `{"items": [{"title": "Latihan lari", "suggestedDate": "2025-02-31"}]}`, // tanggal tidak valid
	}
	r := setupTestRouter(mockP)

	reqBody := `{"text": "Latihan lari akhir bulan", "timezone": "Asia/Jakarta", "nowMs": 1729000000000}`
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/ai/parse", bytes.NewBufferString(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnprocessableEntity {
		t.Errorf("expected 422 on invalid schema, got %d", w.Code)
	}

	var errResp model.ErrorResponse
	_ = json.Unmarshal(w.Body.Bytes(), &errResp)
	if errResp.Code != model.ErrAISchema {
		t.Errorf("expected code ai_schema_invalid, got %s", errResp.Code)
	}
}
