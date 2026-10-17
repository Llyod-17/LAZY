# MASTER PROMPT — LAZY Implementation Plan

You are a Senior Technical Lead, Software Architect, and AI-Assisted Development Planning Specialist.

Your task is to create a comprehensive, execution-ready implementation plan for an Android-first AI personal assistant application named **LAZY**.

The output document must be:

`docs/IMPLEMENTATION_PLAN.md`

This implementation plan will be used by OpenCode as the primary development roadmap.

Your responsibility is to translate the approved product requirements, architecture, and design specifications into small, independently verifiable development tasks.

Do not write application source code yet.

Write the final document in Bahasa Indonesia. Technical terminology, task identifiers, commands, and code references may remain in English.

---

# 1. Mandatory Context Review

Before generating the implementation plan, read these documents completely:

1. `docs/PRD.md`
2. `docs/ARCHITECTURE.md`
3. `docs/DESIGN_SYSTEM.md`

Treat them as the primary sources of truth.

Do not invent additional product features, change the confirmed technology stack, or introduce new architectural patterns without justification.

If requirements conflict, document the conflict explicitly under an Open Questions or Architecture Conflict section.

Do not silently resolve major conflicts through assumptions.

If a required document is missing, request it rather than inventing its contents.

---

# 2. Product Context

Product: LAZY

Tagline: Less planning. More doing.

Platform: Android-first mobile application.

Development approach: Solo developer assisted by OpenCode.

Product philosophy:

- Local-first.
- Voice-first capture.
- Minimal manual input.
- AI-assisted, not AI-dependent.
- Simple and predictable user interactions.
- One clear next action.
- Reliable offline task management.

The objective is to produce a genuinely usable personal productivity application, not merely a UI prototype or technical demonstration.

---

# 3. Confirmed Technology Stack

## Mobile

- Flutter + Dart.
- Riverpod.
- GoRouter.
- Drift + SQLite.
- Native speech recognition.
- flutter_local_notifications.

## Backend

- Golang.
- Gin.
- Go net/http.
- go-playground/validator.
- log/slog.
- Go testing and httptest.

## AI

- 9Router as the LLM gateway.
- Cloud LLM through the configured route.
- OpenAI-compatible API where supported.
- Backend-managed credentials.
- Structured JSON output.
- Strict response validation.

## Development

- Git + GitHub.
- OpenCode.
- Android emulator and physical-device testing.
- Monorepo structure.

Do not introduce unnecessary infrastructure such as Redis, PostgreSQL, Kubernetes, message brokers, or microservices during MVP development.

---

# 4. Development Methodology

Use Vertical Slice Development combined with milestone-based execution.

Each task must:

1. Have a unique task ID.
2. Have a clear objective.
3. Have explicit dependencies.
4. Define expected deliverables.
5. Specify affected modules or directories.
6. Include implementation steps.
7. Include acceptance criteria.
8. Include verification commands.
9. Include required tests.
10. Define its completion criteria.

Prefer tasks small enough for one focused OpenCode session.

Avoid large tasks such as:

"Implement the entire Flutter application."

Instead, break them into atomic tasks such as:

- Configure Flutter theme.
- Implement Task database schema.
- Implement TaskRepository.
- Create Task screen.
- Connect TaskRepository to Riverpod.
- Add Task creation tests.

Do not combine unrelated features in one task.

---

# 5. Required Milestones

Create a detailed implementation plan using the following milestones.

## M00 — Project Foundation

Tasks must cover:

- Repository initialization.
- Monorepo structure.
- Flutter project initialization.
- Go module initialization.
- Environment configuration.
- Git ignore rules.
- Development documentation.
- Basic CI configuration.
- Development environment verification.

Deliverable:

A reproducible project foundation where Flutter and Go can be built independently.

## M01 — Design System & App Shell

Tasks must cover:

- Design tokens.
- Flutter ThemeData.
- Typography configuration.
- Shared UI components.
- GoRouter configuration.
- Application shell.
- Bottom navigation.
- Screen placeholders.
- Accessibility foundation.
- Basic widget tests.

Use DESIGN_SYSTEM.md as the visual source of truth.

Do not implement unrelated business logic.

Deliverable:

A navigable application shell with a consistent design system.

## M02 — Local Database & Task Management

Tasks must cover:

- Drift initialization.
- SQLite schema.
- Task model.
- TaskRepository.
- Database migrations.
- Task creation.
- Task editing.
- Task deletion.
- Task completion.
- Reactive task providers.
- Task list screen.
- Task detail screen.
- Database and repository tests.

Deliverable:

A functional offline task management application.

## M03 — Today Dashboard & Lazy Engine

Tasks must cover:

- Today task queries.
- Recommended Task Card.
- Upcoming activities.
- Energy Check-in.
- Deterministic Lazy Button scoring.
- Recommendation explanation.
- Empty state handling.
- Recommendation unit tests.
- Today screen widget tests.

The Lazy Engine must not depend on LLM inference.

Deliverable:

A working Today Dashboard that recommends one actionable task.

## M04 — Reminder System & Thought Inbox

Tasks must cover:

- Android notification permission handling.
- Local notification service.
- Reminder scheduling.
- Reminder cancellation.
- Snooze functionality.
- Rescheduling.
- Missed reminder handling.
- Reminder reconciliation.
- Device reboot considerations.
- Thought Inbox database model.
- Thought Inbox UI.
- Convert thought to task.
- Notification and Inbox tests.

Deliverable:

Reliable local reminders and unscheduled idea capture.

## M05 — Go Backend & 9Router Integration

Tasks must cover:

- Gin router setup.
- Configuration management.
- Environment variable validation.
- Health endpoint.
- AI request and response DTOs.
- Input validation.
- AI service layer.
- 9Router HTTP client.
- Request timeout.
- Context cancellation.
- Error normalization.
- Structured JSON validation.
- Authentication or access control for the personal backend.
- Request body limits.
- Rate limiting where appropriate.
- Unit tests.
- Handler tests.
- Mock provider integration tests.

Do not hardcode provider credentials.

Do not assume 9Router is publicly reachable.

Deliverable:

A tested Go backend capable of communicating securely with the configured 9Router endpoint.

## M06 — Voice Capture & AI Brain Dump

Tasks must cover:

- Microphone permission handling.
- Speech recognition integration.
- Voice capture UI.
- Transcription editing.
- Flutter HTTP client integration.
- AI parsing request.
- AI response handling.
- Multiple-task extraction.
- AI-generated task preview.
- Ambiguous date handling.
- User confirmation.
- Local persistence.
- Offline fallback.
- Invalid AI response handling.
- Integration tests.

The LLM must never write directly to SQLite.

Deliverable:

A complete flow from spoken input to user-approved, locally stored tasks.

## M07 — QA, Optimization & Android Release

Tasks must cover:

- End-to-end user journey testing.
- Flutter analyzer.
- Flutter unit and widget tests.
- Go unit and integration tests.
- Android notification testing.
- Offline behavior verification.
- AI failure simulation.
- Permission denial scenarios.
- Timezone and date handling.
- Accessibility review.
- Performance review.
- Release configuration.
- APK generation.
- Final README.
- Known limitations documentation.

Deliverable:

A stable Android MVP that can be installed and used independently.

---

# 6. Atomic Task Specification

For every implementation task, use the following template:

### [TASK-ID] — Task Title

**Milestone:** MXX

**Priority:** Must Have / Should Have / Could Have

**Dependencies:** List task IDs.

**Objective:**
Explain the exact outcome expected.

**Scope:**
Define what must be implemented.

**Out of Scope:**
Explicitly state what must not be implemented.

**Expected Files / Modules:**
Identify relevant directories and modules where possible.

**Implementation Steps:**
Provide a concise ordered sequence.

**Acceptance Criteria:**
Use objective, verifiable statements.

**Testing Requirements:**
Define unit, widget, integration, or manual tests as appropriate.

**Verification Commands:**
Provide commands relevant to the actual project configuration.

**Definition of Done:**
Specify the conditions required before marking the task complete.

**Suggested Commit Message:**
Use Conventional Commits.

Tasks should not be marked complete based solely on the coding agent's written summary.

---

# 7. Dependency Management

Provide a dependency graph using Mermaid.

Ensure tasks are ordered correctly.

Examples:

- Database initialization before TaskRepository.
- TaskRepository before task-related Riverpod providers.
- TaskRepository before task CRUD UI integration.
- Notification service before reminder scheduling.
- Backend configuration before 9Router integration.
- AI response contract before Flutter AI integration.
- Speech recognition before voice-to-task integration.

Identify tasks that can be developed independently.

Do not create unnecessary dependencies between unrelated modules.

---

# 8. Verification Strategy

Define verification requirements for every milestone.

Flutter:

- dart format.
- flutter analyze.
- flutter test.
- Relevant integration tests.
- Manual Android testing when required.

Go:

- gofmt.
- go vet.
- go test ./...
- go test -race ./... where supported.
- Mock HTTP integration tests.

Security:

- No committed secrets.
- No hardcoded API credentials.
- No exposed administrative endpoints.
- No unvalidated LLM output.
- No unauthenticated public AI endpoint.

A task is complete only when its acceptance criteria are satisfied and its required verification passes.

If a test cannot be executed, explicitly record it as unverified.

Never fabricate test results.

---

# 9. Git Workflow

Use small, focused commits.

Recommended commit format:

- chore: initialize flutter project
- feat: implement task repository
- feat: add today dashboard
- feat: implement lazy recommendation engine
- feat: integrate local reminders
- feat: add gin ai endpoint
- feat: integrate 9router client
- test: cover ai parsing failures

Define:

- Commit checkpoints.
- Branching recommendations.
- Code review checklist.
- Rollback strategy.
- Rules for handling unrelated working-tree changes.

Do not allow destructive Git commands without explicit developer approval.

---

# 10. AI Coding Agent Execution Rules

The implementation plan must be suitable for OpenCode.

Define rules requiring the agent to:

1. Read AGENTS.md and relevant documentation.
2. Identify the next approved task.
3. Inspect existing implementation before editing.
4. Create a short implementation plan.
5. Modify only files relevant to the task.
6. Reuse existing project conventions.
7. Avoid unnecessary dependencies.
8. Implement appropriate tests.
9. Run verification commands.
10. Review the resulting diff.
11. Report completed work and unresolved issues.
12. Update task status only after verification.

Do not allow the agent to:

- Rewrite unrelated modules.
- Change architecture silently.
- Implement future features prematurely.
- Remove tests to make builds pass.
- Claim tests passed without execution.
- Commit secrets.
- Modify unrelated user files.
- Perform destructive Git operations without approval.

---

# 11. Risk Management

Identify implementation risks, including:

- Android notification restrictions.
- Device reboot behavior.
- Speech recognition availability.
- AI response inconsistency.
- 9Router connectivity.
- API rate limits.
- Invalid date interpretation.
- SQLite migration failures.
- Flutter dependency incompatibilities.
- Excessive AI coding agent context consumption.

For each risk, define:

- Probability.
- Impact.
- Mitigation.
- Verification approach.

---

# 12. Definition of MVP Completion

The MVP is considered complete only when:

1. Users can create, edit, complete, and delete tasks.
2. Tasks persist locally after application restart.
3. Today Dashboard displays relevant activities.
4. Lazy Button recommends one actionable task.
5. Users can configure and receive local reminders.
6. Users can capture unscheduled ideas.
7. Voice input can be converted into editable text on supported devices.
8. AI Brain Dump can extract multiple activities through 9Router.
9. AI-generated activities require confirmation before saving.
10. Core task management remains usable without internet.
11. API failures do not corrupt local data.
12. Required automated tests pass.
13. The application can be built into an installable Android APK.

---

# 13. Required Final Output

Generate a complete IMPLEMENTATION_PLAN.md containing:

1. Development Strategy.
2. Confirmed Technical Scope.
3. Milestone Overview.
4. Detailed Atomic Task Breakdown.
5. Task Dependency Graph.
6. Verification Strategy.
7. Git Workflow.
8. OpenCode Execution Rules.
9. Risk Register.
10. MVP Definition of Done.
11. Recommended Development Order.
12. Final Release Checklist.

Additionally, include a compact Master Task Index table containing:

- Task ID.
- Task Name.
- Milestone.
- Priority.
- Dependencies.
- Status.

Use the following status values:

- TODO
- IN_PROGRESS
- BLOCKED
- DONE

Initialize all implementation tasks as TODO unless there is verifiable evidence that they have already been completed.

The document must be sufficiently detailed to let OpenCode execute tasks sequentially without repeatedly redesigning the system.

Do not generate application source code.

Do not create AGENTS.md yet.

The only required deliverable is:

docs/IMPLEMENTATION_PLAN.md
