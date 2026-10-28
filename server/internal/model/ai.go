package model

import (
	"time"

	"github.com/go-playground/validator/v10"
)

type ParseRequest struct {
	Text     string `json:"text" binding:"required,min=3,max=2000" validate:"required,min=3,max=2000"`
	Timezone string `json:"timezone" binding:"required,ianatimezone" validate:"required,ianatimezone"`
	NowMs    int64  `json:"nowMs" binding:"required,gt=0" validate:"required,gt=0"`
}

type ExtractedTaskItem struct {
	Title         string  `json:"title"`
	SuggestedDate *string `json:"suggestedDate"` // YYYY-MM-DD or null
	SuggestedTime *string `json:"suggestedTime"` // HH:MM or null
	Priority      *string `json:"priority"`      // low, medium, high, or null
	Reason        *string `json:"reason"`
}

type ParseResponse struct {
	Items []ExtractedTaskItem `json:"items"`
}

// ValidateIANATimezone memverifikasi string timezone valid menurut IANA database.
func ValidateIANATimezone(fl validator.FieldLevel) bool {
	tz := fl.Field().String()
	if tz == "" {
		return false
	}
	_, err := time.LoadLocation(tz)
	return err == nil
}
