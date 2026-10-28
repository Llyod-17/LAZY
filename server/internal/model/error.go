package model

import "net/http"

type ErrorCode string

const (
	ErrValidation  ErrorCode = "validation_error"
	ErrTimeout     ErrorCode = "timeout"
	ErrAISchema    ErrorCode = "ai_schema_invalid"
	ErrProvider    ErrorCode = "provider_error"
	ErrUnavailable ErrorCode = "unavailable"
)

type ErrorResponse struct {
	Code    ErrorCode `json:"code"`
	Message string    `json:"message"`
	Details any       `json:"details,omitempty"`
}

func (e *ErrorResponse) HTTPStatus() int {
	switch e.Code {
	case ErrValidation:
		return http.StatusBadRequest // 400
	case ErrTimeout:
		return http.StatusRequestTimeout // 408
	case ErrAISchema:
		return http.StatusUnprocessableEntity // 422
	case ErrProvider:
		return http.StatusBadGateway // 502
	case ErrUnavailable:
		return http.StatusServiceUnavailable // 503
	default:
		return http.StatusInternalServerError
	}
}

func NewErrorResponse(code ErrorCode, message string, details any) *ErrorResponse {
	return &ErrorResponse{
		Code:    code,
		Message: message,
		Details: details,
	}
}
