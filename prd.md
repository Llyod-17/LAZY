# MASTER PROMPT — LAZY Product Requirements Document

You are a Senior Product Manager, Mobile Software Architect, and Technical Product Designer.

Your task is to create a comprehensive, realistic, and implementation-ready Product Requirements Document (PRD) for a personal mobile application named **LAZY**.

Do not write application source code yet. Focus entirely on product planning, feature specifications, technical requirements, and implementation strategy.

The final PRD must be written in Bahasa Indonesia. Technical terminology may remain in English.

---

## 1. Product Identity

**Product Name:** LAZY

**Tagline:** Less planning. More doing.

**Platform:** Android-first mobile application.

**Product Category:** AI-powered Personal Productivity Assistant.

**Development Type:** Independent personal project.

LAZY is designed for users who frequently forget activities, struggle with planning, procrastinate, and dislike manually creating detailed to-do lists.

The application should minimize the effort required to capture thoughts, organize activities, and determine what to do next.

LAZY should not behave like a conventional productivity dashboard or a generic AI chatbot.

Its primary purpose is to reduce friction between having an intention and taking action.

### Core Product Principles

1. Capture first, organize later.
2. Minimize manual input.
3. One clear primary action at a time.
4. AI should assist, not control the entire application.
5. Local-first functionality.
6. Offline reliability for core task management.
7. Simple, predictable, and non-intrusive interactions.
8. Users must retain control over AI-generated tasks and schedule changes.

---

## 2. Target Users

Primary users include:

- Individuals who frequently forget planned activities.
- Students and developers managing personal projects.
- People who dislike traditional to-do list applications.
- Users who prefer voice input over manual typing.
- People who struggle to decide which task to start first.

This is initially a single-user personal application, not a multi-tenant SaaS product.

Do not introduce unnecessary enterprise features.

---

## 3. MVP Features — Version 1.0

Provide detailed functional requirements, user stories, acceptance criteria, edge cases, and expected behavior for each feature.

### F01 — Quick Capture
- Fast text input.
- Voice-to-text input.
- Minimal interaction.
- Task preview before saving.
- Fast access from the Today screen.

### F02 — AI Brain Dump
- Accept natural Indonesian language.
- Extract multiple tasks from a single input.
- Identify task titles, dates, times, priorities when explicitly stated, and relevant contextual information.
- Support relative dates using the user's local date and timezone.
- Never invent missing dates or deadlines.
- Classify unscheduled ideas into Thought Inbox.
- Present extracted items for user confirmation.
- Handle invalid or incomplete AI responses gracefully.

### F03 — Task Management
- Create, read, update, and delete tasks.
- Pending, In Progress, and Completed statuses.
- Optional deadline.
- Optional estimated duration.
- Low, Medium, and High priority.
- Rescheduling.
- Task editing and deletion.

### F04 — Today Dashboard
- Today's activities.
- Next recommended task.
- Upcoming reminders.
- Completed activities.
- Quick Capture entry point.

### F05 — Smart Reminder
- Local notifications.
- Configurable reminder timing.
- Snooze functionality.
- Missed-task handling.
- Manual rescheduling.
- Offline functionality.
- Handle Android notification permissions and scheduling limitations.

### F06 — Lazy Button
- Recommend one actionable task.
- Use a deterministic rule-based scoring system.
- Consider urgency, deadline proximity, estimated duration, and energy compatibility.
- Avoid unnecessary LLM calls.
- Allow users to request another recommendation.
- Explain the recommendation briefly.

### F07 — Energy Check-in
- Low, Medium, and High energy levels.
- Influence task recommendations.
- Avoid automatically modifying deadlines.

### F08 — Thought Inbox
- Capture ideas without deadlines.
- Allow conversion from idea to scheduled task.
- Support editing and deletion.

---

## 4. Post-MVP Features

### Version 1.1
- Daily Briefing.
- Auto Reschedule suggestions.
- Android Home Screen Widget.
- Recurring Tasks.
- AI Task Breakdown.
- Search and Filtering.
- Weekly Insights.

### Version 2.0
- Multi-device synchronization.
- Calendar integration.
- Backup and restore.
- Personalized activity recommendations.
- Optional conversational AI assistant.
- Wearable integration.

Clearly distinguish MVP requirements from future enhancements.

Do not allow future features to increase MVP implementation complexity unnecessarily.

---

## 5. Technology Stack

Use the following technology decisions.

### Mobile
- Flutter + Dart.
- Riverpod for state management.
- GoRouter for navigation.
- Drift + SQLite for local persistence.
- Native speech recognition integration.
- flutter_local_notifications for reminders.

### Backend
- Golang.
- Gin HTTP framework.
- Go net/http client.
- go-playground/validator.
- log/slog.
- Go testing and httptest.

### AI
- 9Router as the LLM gateway.
- Cloud-based LLM accessed through an OpenAI-compatible API, subject to the actual configured route capabilities.
- Backend-managed API credentials.
- Structured JSON extraction.
- Strict response validation.
- Explicit handling of AI errors, timeouts, and unavailable providers.

### Architecture Requirements
- Flutter owns local task data and notification scheduling.
- Go + Gin acts as the AI orchestration backend.
- The backend communicates with 9Router.
- Do not expose provider credentials inside the mobile application.
- Do not assume 9Router is publicly accessible or continuously available.
- Core functionality must remain usable when the AI backend is unavailable.
- Avoid PostgreSQL, Redis, microservices, and unnecessary infrastructure during MVP development.

---

## 6. Design System

Design Direction: Warm Minimalism + Playful Utility.

### Color Palette
- Background: #F7F5EF
- Primary Text: #20211F
- Accent Yellow: #F2D66D
- Secondary Sage: #A9B9A0
- Neutral: #E7E5DF

### Design Principles
- Clean and minimal.
- Generous whitespace.
- Clear visual hierarchy.
- Large, accessible interaction targets.
- Rounded but restrained components.
- Minimal cognitive load.
- One primary action per screen.
- Calm, friendly microcopy.
- Accessible contrast and typography.

Avoid:
- Excessive gradients.
- Glassmorphism.
- Overly complex dashboards.
- Unnecessary gamification.
- Generic chatbot-first interfaces.
- Excessive animations.

Define recommended screens, navigation structure, reusable components, loading states, empty states, error states, and confirmation interactions.

---

## 7. Required PRD Sections

Generate a complete PRD containing:

1. Executive Summary.
2. Product Vision and Problem Statement.
3. Goals and Non-Goals.
4. Target Users and User Personas.
5. Core User Journeys.
6. Feature Requirements.
7. Functional Requirements.
8. Non-Functional Requirements.
9. MVP Scope and Future Roadmap.
10. Information Architecture.
11. Screen-by-Screen Specifications.
12. UX and Design System Guidelines.
13. High-Level System Architecture.
14. Data Models and Database Requirements.
15. Backend API Requirements.
16. AI Integration and Prompt Processing Flow.
17. Notification and Background Execution Strategy.
18. Offline and Error Handling Strategy.
19. Security and Privacy Requirements.
20. Testing and Quality Assurance Strategy.
21. Performance and Reliability Requirements.
22. Development Milestones.
23. Risks, Constraints, and Mitigations.
24. MVP Definition of Done.
25. Success Metrics.

---

## 8. Additional Requirements

For each major feature, provide:

- Feature ID.
- Feature description.
- User story.
- Priority (Must Have / Should Have / Could Have).
- Dependencies.
- Acceptance criteria.
- Edge cases.
- Expected UI behavior.

For technical architecture, include Mermaid diagrams where appropriate.

For backend requirements, propose initial REST endpoints with request and response structures.

For data requirements, define the essential SQLite entities and relationships without overengineering.

For AI integration, define a consistent structured output contract and validation requirements.

Consider:
- Indonesian natural language input.
- Relative date interpretation.
- Timezone handling.
- Android notification permissions.
- Device restart and reminder recovery.
- Network failures.
- API timeouts.
- Duplicate task prevention.
- Data privacy.
- Local-first operation.

Make implementation milestones small enough for an AI coding agent such as OpenCode to execute and verify independently.

---

## 9. Important Constraints

Do not:
- Generate application source code.
- Introduce unnecessary technologies.
- Assume unlimited AI API usage.
- Make every feature dependent on LLM inference.
- Expand the MVP into an enterprise productivity platform.
- Automatically implement features planned for V1.1 or V2.0.

Make reasonable assumptions when requirements are incomplete, and document those assumptions explicitly.

The result must be a professional, detailed, and actionable PRD that can serve as the primary source of truth for subsequent AI-assisted software development.

Output the document in well-structured Markdown, ready to be saved as `docs/PRD.md`.
