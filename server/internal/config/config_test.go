package config_test

import (
	"os"
	"testing"

	"lazy/server/internal/config"
)

func TestConfigLoadDefaults(t *testing.T) {
	os.Clearenv()
	cfg := config.Load()

	if cfg.Port != "8080" {
		t.Errorf("expected default port 8080, got %s", cfg.Port)
	}
	if cfg.AIBaseURL != "http://localhost:3456/v1" {
		t.Errorf("expected default base url, got %s", cfg.AIBaseURL)
	}
	if cfg.AIModel != "deepseek-chat" {
		t.Errorf("expected default model deepseek-chat, got %s", cfg.AIModel)
	}
	if cfg.AITimeoutSec != 12 {
		t.Errorf("expected default timeout 12, got %d", cfg.AITimeoutSec)
	}
}

func TestConfigLoadCustom(t *testing.T) {
	os.Setenv("PORT", "9090")
	os.Setenv("AI_TIMEOUT_SEC", "20")
	defer os.Clearenv()

	cfg := config.Load()
	if cfg.Port != "9090" {
		t.Errorf("expected port 9090, got %s", cfg.Port)
	}
	if cfg.AITimeoutSec != 20 {
		t.Errorf("expected timeout 20, got %d", cfg.AITimeoutSec)
	}
}
