package provider_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"lazy/server/internal/provider"
)

func TestRouterClient_Success(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintln(w, `{"choices": [{"message": {"role": "assistant", "content": "hello world"}}]}`)
	}))
	defer ts.Close()

	client := provider.NewRouterClient(ts.URL, "test-key", "test-model", 1*time.Second)
	content, err := client.ChatCompletion(context.Background(), "sys", "usr")
	if err != nil {
		t.Fatalf("expected success, got err: %v", err)
	}
	if content != "hello world" {
		t.Errorf("expected 'hello world', got '%s'", content)
	}
}

func TestRouterClient_Timeout(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(100 * time.Millisecond)
		w.WriteHeader(http.StatusOK)
	}))
	defer ts.Close()

	client := provider.NewRouterClient(ts.URL, "test-key", "test-model", 50*time.Millisecond)
	_, err := client.ChatCompletion(context.Background(), "sys", "usr")
	if err == nil {
		t.Error("expected timeout error, got nil")
	}
}

func TestRouterClient_ProviderError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintln(w, `{"error": {"message": "invalid model"}}`)
	}))
	defer ts.Close()

	client := provider.NewRouterClient(ts.URL, "test-key", "test-model", 1*time.Second)
	_, err := client.ChatCompletion(context.Background(), "sys", "usr")
	if err == nil || !strings.Contains(err.Error(), "invalid model") {
		t.Errorf("expected error containing 'invalid model', got: %v", err)
	}
}
