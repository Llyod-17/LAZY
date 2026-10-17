# MASTER PROMPT — LAZY Software Architecture

You are a Senior Software Architect specializing in Flutter, Golang, local-first mobile applications, and AI-integrated systems.

Your task is to produce a comprehensive, implementation-ready Software Architecture Document named `ARCHITECTURE.md` for the LAZY application.

**IMPORTANT: Read the existing `PRD.md` first.** Treat the PRD as the primary source of truth for product requirements, feature scope, user journeys, and acceptance criteria.

Do not redesign the product or introduce unnecessary technologies.

If a technical decision conflicts with the PRD, explicitly identify the conflict and propose a resolution.

Write the final document in Bahasa Indonesia. Technical terminology, code identifiers, and architecture terminology may remain in English.

Do not implement application source code yet.

---

# 1. Project Context

Product Name: LAZY

Tagline: Less planning. More doing.

LAZY is an Android-first, AI-powered personal productivity assistant designed to reduce the friction of capturing thoughts, organizing activities, managing schedules, and deciding what to do next.

The application follows three architectural principles:

1. Local-first by default.
2. AI-assisted, not AI-dependent.
3. Simple modular architecture with clear separation of responsibilities.

This is initially a single-user personal project.

Avoid enterprise-level complexity.

---

# 2. Confirmed Technology Stack

## Mobile Application

- Flutter + Dart
- Riverpod
- GoRouter
- Drift + SQLite
- Native speech recognition integration
- flutter_local_notifications

## Backend

- Golang
- Gin HTTP framework
- Go net/http
- go-playground/validator
- log/slog
- Go testing + httptest

## AI Infrastructure

- 9Router as the AI gateway
- Cloud LLM through the configured 9Router route
- OpenAI-compatible API where supported
- Structured JSON extraction
- Backend-managed credentials

## Development

- Git + GitHub
- OpenCode as the primary AI coding agent
- Android-first development
- Modular monorepo structure

Do not introduce PostgreSQL, Redis, Firebase, message brokers, Kubernetes, or microservices without a clearly justified requirement.

---

# 3. Architecture Style

Design a Local-First Modular Architecture.

The application must have two main components:

### A. Flutter Mobile Application

Responsible for:

- Presentation layer.
- State management.
- Task management.
- Local database.
- Scheduling reminders.
- Voice capture and speech recognition.
- Energy check-in.
- Lazy Button scoring.
- Offline functionality.
- User confirmation before saving AI-generated data.

### B. Go + Gin Backend

Responsible for:

- API request handling.
- Input validation.
- AI orchestration.
- Prompt construction.
- Communication with 9Router.
- AI response validation.
- Normalized API responses.
- Timeouts and error handling.
- Secure credential management.

The backend must not become the primary storage location for personal tasks during MVP development.

The mobile application must remain functional without backend connectivity, except for features requiring cloud AI.

---

# 4. Required Architecture Documentation

Generate the following sections in detail.

## 4.1 System Context Diagram

Provide a Mermaid diagram showing:

Flutter Application → Go Backend → 9Router → Cloud LLM.

Also illustrate:

- Local SQLite database.
- Speech recognition.
- Local notification scheduler.
- Offline behavior.
- Security boundaries.

Explain the responsibility of each component.

## 4.2 Flutter Application Architecture

Use a feature-first modular architecture with clear separation between:

- Presentation.
- Application/state management.
- Domain logic where necessary.
- Data/repository layer.

Avoid excessive abstraction.

Propose a directory structure similar to:

```text
mobile/
├── lib/
│   ├── app/
│   ├── core/
│   │   ├── database/
│   │   ├── network/
│   │   ├── notifications/
│   │   ├── theme/
│   │   ├── errors/
│   │   └── utils/
│   ├── features/
│   │   ├── today/
│   │   ├── tasks/
│   │   ├── capture/
│   │   ├── inbox/
│   │   ├── reminders/
│   │   ├── lazy_engine/
│   │   └── settings/
│   └── main.dart
├── test/
└── pubspec.yaml
```

Explain how each feature should organize its widgets, providers, repositories, and models.

Define rules for shared components and dependencies between features.

Avoid creating unnecessary interfaces for simple implementations.

## 4.3 Backend Architecture

Use a simple modular Go architecture.

Suggested structure:

```text
server/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── config/
│   ├── handler/
│   ├── service/
│   ├── provider/
│   ├── model/
│   ├── middleware/
│   └── router/
├── tests/
├── go.mod
├── go.sum
└── .env.example
```

Explain the responsibilities of:

- Handler.
- Service.
- Provider/client.
- Model.
- Middleware.
- Configuration.

Define the dependency direction between modules.

Do not introduce complex dependency injection frameworks or unnecessary repository abstractions.

Use explicit constructor-based dependency injection where appropriate.

## 4.4 Data Architecture

Design a local SQLite schema using Drift.

Define essential entities based on the PRD, including:

- Tasks.
- Thought Inbox items.
- Reminders.
- User preferences.

Include additional entities only when necessary.

For each entity, specify:

- Field name.
- Data type.
- Nullability.
- Default values.
- Primary key.
- Relationships.
- Index requirements.
- Validation constraints.

Include conventions for:

- UUID generation.
- Date and time storage.
- Timezone interpretation.
- CreatedAt and UpdatedAt.
- Soft delete versus hard delete.
- Database schema versioning.
- Migration strategy.
- Data integrity.

Do not duplicate data unnecessarily.

Explain how task completion, snooze, and rescheduling affect persisted data.

## 4.5 API Contract

Design the initial REST API for the Go backend.

Initial endpoints:

- GET /api/v1/health
- POST /api/v1/ai/parse
- POST /api/v1/ai/briefing (post-MVP, if required by PRD)

For each endpoint, define:

- Purpose.
- HTTP method.
- Request schema.
- Response schema.
- HTTP status codes.
- Validation rules.
- Error response format.
- Timeout behavior.
- Security considerations.

Provide example request and response JSON.

Do not introduce server-side task CRUD endpoints unless justified by a concrete requirement.

## 4.6 AI Integration Architecture

Explain the complete AI processing pipeline:

1. Receive natural language input.
2. Validate request.
3. Obtain current date, time, and IANA timezone from the mobile client.
4. Construct a controlled system prompt.
5. Send request through 9Router.
6. Receive model output.
7. Validate structured JSON.
8. Normalize the response.
9. Return parsed task suggestions to Flutter.
10. Display confirmation UI.
11. Persist approved items locally.

The LLM must never directly modify the local database.

Define an AI output contract supporting:

- Multiple extracted tasks.
- Task title.
- Optional description.
- Optional date.
- Optional time.
- Optional duration.
- Optional priority.
- Item classification.
- Ambiguous or missing information.

Do not invent missing dates, deadlines, or user intentions.

Define handling for relative Indonesian expressions such as:

- Besok.
- Lusa.
- Nanti sore.
- Minggu depan.
- Kapan-kapan.

If an expression is ambiguous, preserve the uncertainty and request user confirmation.

Include fallback behavior when AI parsing fails.

Define an AI provider abstraction so that changing the configured 9Router model does not require modifying application business logic.

Do not assume all models support native JSON schema enforcement.

Validate responses independently of the model's claims.

## 4.7 9Router Connectivity

Explain development and deployment connectivity separately.

During local development, the Go backend may communicate with a locally running 9Router instance.

For Android testing, explain how the Flutter app connects to the backend using the appropriate emulator or LAN configuration.

Do not assume that localhost on Android refers to the developer's laptop.

For production-like personal usage, explain the requirement for a securely reachable backend and AI gateway.

Never expose 9Router administrative interfaces or API credentials publicly.

Do not hardcode localhost endpoints or secrets in application source code.

Use environment-based configuration.

## 4.8 Notification Architecture

Define the reminder scheduling architecture using flutter_local_notifications.

Cover:

- Scheduling a reminder.
- Updating a reminder.
- Cancelling a reminder.
- Snoozing.
- Task completion.
- Device reboot.
- Timezone changes.
- Notification permission denial.
- Android background execution restrictions.
- Exact alarm permission considerations.
- Duplicate notification prevention.

The database must remain the source of truth.

Explain how scheduled notifications are reconciled with stored reminder data.

Do not promise exact reminder delivery under every Android battery optimization policy.

## 4.9 Lazy Engine Architecture

Design the Lazy Button as a deterministic recommendation engine.

Do not use LLM inference for routine task ranking.

Define:

- Candidate task filtering.
- Urgency calculation.
- Deadline proximity.
- Energy compatibility.
- Estimated duration.
- Scoring normalization.
- Tie-breaking behavior.
- Handling tasks without deadlines.
- Handling empty task lists.

The recommendation algorithm must be independently unit-testable.

## 4.10 State Management

Explain how Riverpod manages:

- Today screen state.
- Task state.
- Thought Inbox state.
- Energy selection.
- AI parsing state.
- Notification state.

Avoid creating multiple competing sources of truth.

SQLite should remain the authoritative source for persisted task data.

Use reactive database queries where appropriate.

## 4.11 Security and Privacy

Document:

- Backend-managed API credentials.
- Request validation.
- Secure transport.
- Authentication/access control appropriate for a personal backend.
- Rate limiting.
- Request body limits.
- Secret management.
- Logging without leaking personal task contents.
- AI provider data exposure.
- Safe handling of untrusted LLM output.
- Development versus production configuration.

A public deployment must not expose unauthenticated AI endpoints.

## 4.12 Error Handling and Offline Strategy

Define expected behavior for:

- No internet.
- Backend unavailable.
- 9Router unavailable.
- LLM timeout.
- Invalid JSON.
- Speech recognition failure.
- Database error.
- Notification permission denied.
- App termination during task creation.

Core task management must remain available offline.

Provide a consistent error taxonomy for both Flutter and Go.

## 4.13 Testing Architecture

Define:

Flutter:
- Unit tests.
- Widget tests.
- Database tests.
- Provider tests.
- Notification integration tests.

Go:
- Handler tests.
- Service tests.
- Provider client tests.
- Mock HTTP server tests.
- JSON validation tests.
- Timeout and failure tests.

Include testable acceptance criteria and a testing strategy for AI outputs.

## 4.14 Performance Requirements

Propose realistic, measurable targets for:

- Application startup.
- Local task creation.
- Database queries.
- UI responsiveness.
- AI request timeout.
- Notification scheduling.

Clearly distinguish proposed engineering targets from measured performance.

## 4.15 Architecture Decision Records

Document important decisions using concise ADR entries:

- Why Flutter?
- Why Gin instead of Fiber?
- Why Drift + SQLite?
- Why local-first?
- Why Go backend only for AI orchestration?
- Why 9Router?
- Why deterministic Lazy Button scoring?
- Why no server-side database for MVP?

Each ADR must contain:

- Context.
- Decision.
- Consequences.
- Alternatives considered.

---

# 5. Required Diagrams

Include valid Mermaid diagrams for:

1. High-Level System Architecture.
2. Flutter Module Dependency Diagram.
3. Backend Request Flow.
4. AI Brain Dump Sequence Diagram.
5. Local Notification Lifecycle.
6. Data Relationship Diagram.

All diagrams must reflect the actual proposed architecture.

---

# 6. Architecture Constraints

Follow these rules strictly:

- Keep the architecture simple enough for a solo developer.
- Prefer established packages over custom infrastructure.
- Avoid premature optimization.
- Avoid unnecessary design patterns.
- Do not create microservices.
- Do not make cloud AI mandatory for core functionality.
- Do not implement application source code yet.
- Do not introduce unrelated product features.
- Ensure architectural decisions remain consistent with PRD.md.

Where implementation choices remain uncertain, clearly document the alternatives and recommend one with technical justification.

---

# 7. Expected Output

Produce a complete, professional Software Architecture Document ready to be saved as:

`docs/ARCHITECTURE.md`

The document must be sufficiently detailed for an AI coding agent such as OpenCode to implement the project incrementally without repeatedly making major architectural decisions.

At the end, include:

1. Final architecture summary.
2. Confirmed technology stack.
3. Important technical decisions.
4. Known architectural risks.
5. Unresolved questions.
6. Recommended implementation order.

Do not start coding.

Do not generate IMPLEMENTATION_PLAN.md yet.

Focus exclusively on delivering a technically consistent and implementation-ready ARCHITECTURE.md.
