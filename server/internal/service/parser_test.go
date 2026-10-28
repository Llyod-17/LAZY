package service_test

import (
	"errors"
	"strings"
	"testing"
	"time"

	"lazy/server/internal/service"
)

func TestCleanAndParseResponse_ValidPureJSON(t *testing.T) {
	raw := `{
		"items": [
			{
				"title": "Beli susu",
				"suggestedDate": "2025-10-25",
				"suggestedTime": "14:30",
				"priority": "high",
				"reason": "Disebutkan sore hari"
			}
		]
	}`

	resp, err := service.CleanAndParseResponse(raw)
	if err != nil {
		t.Fatalf("expected success, got: %v", err)
	}

	if len(resp.Items) != 1 {
		t.Fatalf("expected 1 item, got %d", len(resp.Items))
	}
	item := resp.Items[0]
	if item.Title != "Beli susu" {
		t.Errorf("expected title 'Beli susu', got '%s'", item.Title)
	}
	if *item.SuggestedDate != "2025-10-25" {
		t.Errorf("expected date 2025-10-25, got %v", item.SuggestedDate)
	}
	if *item.SuggestedTime != "14:30" {
		t.Errorf("expected time 14:30, got %v", item.SuggestedTime)
	}
	if *item.Priority != "high" {
		t.Errorf("expected priority high, got %v", item.Priority)
	}
}

func TestCleanAndParseResponse_WithMarkdownFences(t *testing.T) {
	raw := "```json\n" + `{
		"items": [
			{
				"title": "Nonton film",
				"suggestedDate": null,
				"suggestedTime": null,
				"priority": null,
				"reason": null
			}
		]
	}` + "\n```"

	resp, err := service.CleanAndParseResponse(raw)
	if err != nil {
		t.Fatalf("expected markdown fences to be stripped, got: %v", err)
	}
	if len(resp.Items) != 1 || resp.Items[0].Title != "Nonton film" {
		t.Errorf("unexpected parsed item: %+v", resp.Items)
	}
}

func TestCleanAndParseResponse_InvalidDate(t *testing.T) {
	raw := `{
		"items": [
			{
				"title": "Tugas kalender aneh",
				"suggestedDate": "2025-02-30"
			}
		]
	}`

	_, err := service.CleanAndParseResponse(raw)
	if err == nil || !errors.Is(err, service.ErrInvalidSchema) {
		t.Errorf("expected ErrInvalidSchema for Feb 30, got: %v", err)
	}
}

func TestCleanAndParseResponse_InvalidTime(t *testing.T) {
	raw := `{
		"items": [
			{
				"title": "Tugas jam aneh",
				"suggestedTime": "24:15"
			}
		]
	}`

	_, err := service.CleanAndParseResponse(raw)
	if err == nil || !errors.Is(err, service.ErrInvalidSchema) {
		t.Errorf("expected ErrInvalidSchema for invalid hour, got: %v", err)
	}
}

func TestCleanAndParseResponse_InvalidPriority(t *testing.T) {
	raw := `{
		"items": [
			{
				"title": "Tugas prioritas aneh",
				"priority": "urgent"
			}
		]
	}`

	_, err := service.CleanAndParseResponse(raw)
	if err == nil || !errors.Is(err, service.ErrInvalidSchema) {
		t.Errorf("expected ErrInvalidSchema for non-allowed priority, got: %v", err)
	}
}

func TestCleanAndParseResponse_EmptyTitle(t *testing.T) {
	raw := `{
		"items": [
			{
				"title": "   "
			}
		]
	}`

	_, err := service.CleanAndParseResponse(raw)
	if err == nil || !errors.Is(err, service.ErrInvalidSchema) {
		t.Errorf("expected ErrInvalidSchema for empty title, got: %v", err)
	}
}

func TestCleanAndParseResponse_MalformedJSON(t *testing.T) {
	raw := `{"items": [{"title": "rusak"`

	_, err := service.CleanAndParseResponse(raw)
	if err == nil || !errors.Is(err, service.ErrMalformedJSON) {
		t.Errorf("expected ErrMalformedJSON, got: %v", err)
	}
}

func TestBuildSystemPrompt_ContainsReferenceTime(t *testing.T) {
	fixedTime := time.Date(2025, 10, 16, 9, 30, 0, 0, time.UTC)
	nowMs := fixedTime.UnixMilli()

	prompt := service.BuildSystemPrompt(nowMs, "Asia/Jakarta")

	if !strings.Contains(prompt, "2025-10-16") {
		t.Errorf("expected prompt to contain date 2025-10-16, got:\n%s", prompt)
	}
	if !strings.Contains(prompt, "Asia/Jakarta") {
		t.Errorf("expected prompt to contain timezone Asia/Jakarta")
	}
	if !strings.Contains(prompt, "DILARANG MENGARANG TANGGAL") {
		t.Errorf("expected prompt to contain anti-hallucination instruction")
	}
}
