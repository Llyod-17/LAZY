package provider

import (
	"context"
)

type AIProvider interface {
	ChatCompletion(ctx context.Context, systemPrompt, userPrompt string) (string, error)
}
