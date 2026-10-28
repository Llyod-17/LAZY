package service

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"lazy/server/internal/model"
)

var (
	ErrMalformedJSON = errors.New("malformed_json")
	ErrInvalidSchema = errors.New("invalid_schema")
)

// CleanAndParseResponse membersihkan markdown fence dan memvalidasi skema JSON AI.
func CleanAndParseResponse(raw string) (*model.ParseResponse, error) {
	cleaned := stripMarkdownFences(raw)

	var resp model.ParseResponse
	if err := json.Unmarshal([]byte(cleaned), &resp); err != nil {
		return nil, fmt.Errorf("%w: failed to parse json: %v", ErrMalformedJSON, err)
	}

	if len(resp.Items) == 0 {
		return nil, fmt.Errorf("%w: items array cannot be empty", ErrInvalidSchema)
	}

	for i, item := range resp.Items {
		trimmedTitle := strings.TrimSpace(item.Title)
		if len(trimmedTitle) < 1 || len(trimmedTitle) > 100 {
			return nil, fmt.Errorf("%w: item [%d] title length must be between 1 and 100 characters", ErrInvalidSchema, i)
		}
		resp.Items[i].Title = trimmedTitle

		if item.SuggestedDate != nil {
			dateStr := strings.TrimSpace(*item.SuggestedDate)
			if dateStr == "" {
				resp.Items[i].SuggestedDate = nil
			} else {
				parsedDate, err := time.Parse("2006-01-02", dateStr)
				if err != nil || parsedDate.Format("2006-01-02") != dateStr {
					return nil, fmt.Errorf("%w: item [%d] suggestedDate '%s' is not a valid YYYY-MM-DD date", ErrInvalidSchema, i, dateStr)
				}
				resp.Items[i].SuggestedDate = &dateStr
			}
		}

		if item.SuggestedTime != nil {
			timeStr := strings.TrimSpace(*item.SuggestedTime)
			if timeStr == "" {
				resp.Items[i].SuggestedTime = nil
			} else {
				parsedTime, err := time.Parse("15:04", timeStr)
				if err != nil || parsedTime.Format("15:04") != timeStr {
					return nil, fmt.Errorf("%w: item [%d] suggestedTime '%s' is not a valid HH:MM 24h time", ErrInvalidSchema, i, timeStr)
				}
				resp.Items[i].SuggestedTime = &timeStr
			}
		}

		if item.Priority != nil {
			p := strings.ToLower(strings.TrimSpace(*item.Priority))
			if p == "" {
				resp.Items[i].Priority = nil
			} else if p != "low" && p != "medium" && p != "high" {
				return nil, fmt.Errorf("%w: item [%d] priority '%s' must be low, medium, high, or null", ErrInvalidSchema, i, p)
			} else {
				resp.Items[i].Priority = &p
			}
		}
	}

	return &resp, nil
}

func stripMarkdownFences(s string) string {
	trimmed := strings.TrimSpace(s)
	// Strip leading ```json or ```
	if strings.HasPrefix(trimmed, "```") {
		firstNewline := strings.Index(trimmed, "\n")
		if firstNewline != -1 {
			trimmed = trimmed[firstNewline+1:]
		} else {
			trimmed = strings.TrimPrefix(trimmed, "```")
		}
	}
	// Strip trailing ```
	if strings.HasSuffix(trimmed, "```") {
		trimmed = strings.TrimSuffix(trimmed, "```")
	}
	return strings.TrimSpace(trimmed)
}
