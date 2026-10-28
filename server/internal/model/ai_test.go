package model_test

import (
	"net/http"
	"testing"

	"github.com/go-playground/validator/v10"
	"lazy/server/internal/model"
)

func newTestValidator() *validator.Validate {
	v := validator.New()
	_ = v.RegisterValidation("ianatimezone", model.ValidateIANATimezone)
	return v
}

func TestParseRequestValidation_Success(t *testing.T) {
	v := newTestValidator()

	req := model.ParseRequest{
		Text:     "Meeting besok jam 9 pagi lalu beli kopi",
		Timezone: "Asia/Jakarta",
		NowMs:    1729000000000,
	}

	if err := v.Struct(req); err != nil {
		t.Fatalf("expected valid request, got err: %v", err)
	}
}

func TestParseRequestValidation_TextConstraints(t *testing.T) {
	v := newTestValidator()

	// Text too short (< 3)
	req := model.ParseRequest{
		Text:     "hi",
		Timezone: "Asia/Jakarta",
		NowMs:    1729000000000,
	}
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for text < 3 chars")
	}

	// Text empty
	req.Text = ""
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for empty text")
	}

	// Text too long (> 2000)
	longText := make([]byte, 2001)
	for i := range longText {
		longText[i] = 'a'
	}
	req.Text = string(longText)
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for text > 2000 chars")
	}
}

func TestParseRequestValidation_Timezone(t *testing.T) {
	v := newTestValidator()

	req := model.ParseRequest{
		Text:     "Beli susu",
		Timezone: "Invalid/Fake_Zone",
		NowMs:    1729000000000,
	}
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for invalid timezone")
	}

	req.Timezone = "UTC"
	if err := v.Struct(req); err != nil {
		t.Errorf("expected UTC to be valid, got: %v", err)
	}

	req.Timezone = "America/New_York"
	if err := v.Struct(req); err != nil {
		t.Errorf("expected America/New_York to be valid, got: %v", err)
	}
}

func TestParseRequestValidation_NowMs(t *testing.T) {
	v := newTestValidator()

	req := model.ParseRequest{
		Text:     "Beli susu",
		Timezone: "Asia/Jakarta",
		NowMs:    0,
	}
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for nowMs <= 0")
	}

	req.NowMs = -100
	if err := v.Struct(req); err == nil {
		t.Errorf("expected error for negative nowMs")
	}
}

func TestErrorResponseHTTPStatusMapping(t *testing.T) {
	cases := []struct {
		code   model.ErrorCode
		status int
	}{
		{model.ErrValidation, http.StatusBadRequest},
		{model.ErrTimeout, http.StatusRequestTimeout},
		{model.ErrAISchema, http.StatusUnprocessableEntity},
		{model.ErrProvider, http.StatusBadGateway},
		{model.ErrUnavailable, http.StatusServiceUnavailable},
		{model.ErrorCode("unknown"), http.StatusInternalServerError},
	}

	for _, tc := range cases {
		errResp := model.NewErrorResponse(tc.code, "msg", nil)
		if errResp.HTTPStatus() != tc.status {
			t.Errorf("expected code %s -> status %d, got %d", tc.code, tc.status, errResp.HTTPStatus())
		}
	}
}
