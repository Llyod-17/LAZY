package config

import (
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Port         string
	AIBaseURL    string
	AIAPIKey     string
	AIModel      string
	AITimeoutSec int
	LogLevel     string
}

func Load() *Config {
	_ = godotenv.Load() // optional .env file

	return &Config{
		Port:         getEnv("PORT", "8080"),
		AIBaseURL:    getEnv("AI_BASE_URL", "http://localhost:3456/v1"),
		AIAPIKey:     os.Getenv("AI_API_KEY"),
		AIModel:      getEnv("AI_MODEL", "deepseek-chat"),
		AITimeoutSec: getEnvInt("AI_TIMEOUT_SEC", 12),
		LogLevel:     getEnv("LOG_LEVEL", "info"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	val := os.Getenv(key)
	if val == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(val)
	if err != nil {
		return fallback
	}
	return parsed
}
