# MASTER PROMPT — LAZY Design System & UX Specification

You are a Senior Product Designer, Mobile UX Architect, and Flutter Design System Engineer.

Your task is to create a complete, implementation-ready Design System and UX Specification for an Android-first mobile application called **LAZY**.

The output must be a professional Markdown document named:

`docs/DESIGN_SYSTEM.md`

IMPORTANT: Before creating the document, read and analyze:

1. `docs/PRD.md`
2. `docs/ARCHITECTURE.md`

These documents are the primary sources of truth.

Do not introduce features that are outside the approved product scope. If a UX decision conflicts with an existing requirement, identify the conflict explicitly.

Write the final document in Bahasa Indonesia. Technical design terminology may remain in English.

Do not implement Flutter source code yet.

---

# 1. Product Identity

Product: LAZY

Tagline: Less planning. More doing.

Category: AI-powered Personal Productivity Assistant.

Platform: Android-first.

Core philosophy:

LAZY should reduce the cognitive effort required to capture thoughts, manage activities, and decide what to do next.

The interface must feel calm, effortless, functional, and slightly playful.

Avoid making users feel overwhelmed by unfinished tasks or excessive productivity metrics.

The application should behave like a helpful personal companion rather than a complicated productivity management dashboard.

---

# 2. Visual Design Direction

Use the following combined design language:

**Warm Minimalism + Playful Utility + Editorial Typography**

Interpretation:

- Warm and approachable.
- Minimal without feeling empty.
- Functional without looking corporate.
- Playful without becoming childish.
- Strong typography and visual hierarchy.
- Generous whitespace.
- Restrained use of color.
- Clear interaction feedback.
- Minimal cognitive load.

The interface should have a distinctive product identity rather than resembling a generic Material Design template.

Use Material 3 as the underlying Flutter component foundation where appropriate, but customize the visual tokens and components.

Avoid:

- Glassmorphism.
- Excessive gradients.
- Neon colors.
- Heavy shadows.
- Overly decorative illustrations.
- Complex productivity dashboards.
- Excessive gamification.
- Unnecessary animations.
- Generic chatbot-first layouts.
- Neo-brutalist styling.

---

# 3. Color System

Use the following palette as the initial visual foundation.

Primary colors:

- Warm Ivory: #F7F5EF
- Near Black / Ink: #20211F
- Butter Yellow: #F2D66D
- Soft Sage: #A9B9A0
- Neutral Gray: #E7E5DF

Create a complete semantic color system based on this palette.

Define tokens for:

- Background.
- Surface.
- Elevated surface.
- Primary text.
- Secondary text.
- Disabled text.
- Primary action.
- Secondary action.
- Accent.
- Border.
- Divider.
- Success.
- Warning.
- Error.
- Focus indicator.
- Selected state.
- Pressed state.

Provide exact HEX values.

Ensure accessible contrast ratios, particularly for small text and interactive controls.

Do not use Butter Yellow or Sage automatically as text colors without verifying contrast.

Use Near Black as the preferred text color on Butter Yellow surfaces.

Light mode is the initial MVP priority.

Dark mode is not required for MVP unless explicitly justified.

---

# 4. Typography System

Recommended primary typeface:

Plus Jakarta Sans.

Alternative:

DM Sans.

Optional monospace:

JetBrains Mono, restricted to appropriate metadata or technical elements.

Define a typography scale covering:

- Display.
- Headline Large.
- Headline Medium.
- Title Large.
- Title Medium.
- Body Large.
- Body Medium.
- Body Small.
- Label Large.
- Label Medium.
- Caption.

For each token specify:

- Font family.
- Font size.
- Font weight.
- Line height.
- Letter spacing.
- Recommended usage.

Prioritize readability on mobile screens.

Support Android font scaling and avoid fixed-height text containers that may clip content.

---

# 5. Layout and Spacing

Use a consistent 4-point spacing foundation.

Suggested spacing tokens:

- 4px.
- 8px.
- 12px.
- 16px.
- 20px.
- 24px.
- 32px.
- 40px.
- 48px.

Define:

- Screen horizontal padding.
- Vertical section spacing.
- Card padding.
- Component spacing.
- Navigation spacing.
- Bottom safe-area behavior.
- Responsive layout rules.
- Keyboard-aware layout behavior.

Use whitespace intentionally to reduce visual clutter.

Define a consistent border-radius scale for:

- Small controls.
- Input fields.
- Cards.
- Bottom sheets.
- Buttons.
- Modal surfaces.

Avoid excessive rounding on every component.

---

# 6. Component Library

Specify the design and behavior of the following reusable Flutter components:

1. LazyButton.
2. PrimaryButton.
3. SecondaryButton.
4. IconButton.
5. TaskCard.
6. RecommendedTaskCard.
7. QuickCaptureBar.
8. VoiceCaptureButton.
9. EnergySelector.
10. PriorityIndicator.
11. ReminderChip.
12. StatusBadge.
13. EmptyState.
14. ErrorState.
15. LoadingIndicator.
16. ConfirmationBottomSheet.
17. TaskPreviewCard.
18. ThoughtInboxItem.
19. DateTimeSelector.
20. AppNavigationBar.

For each component define:

- Purpose.
- Visual appearance.
- Dimensions.
- Padding.
- Typography.
- Color tokens.
- Interaction states.
- Disabled behavior.
- Accessibility considerations.
- Flutter implementation recommendations.

Do not create unnecessary component variants.

Prioritize reuse and consistency.

---

# 7. Information Architecture

Design a simple navigation structure suitable for LAZY.

Recommended primary destinations:

1. Today.
2. Inbox.
3. Tasks.
4. Settings.

Quick Capture should be globally accessible as a prominent action.

The Lazy Button should be highly visible on the Today screen.

Avoid excessive bottom navigation items.

Define navigation behavior using GoRouter.

Specify how users access:

- Task details.
- Task editing.
- Voice capture.
- AI-generated task preview.
- Reminder settings.
- Energy check-in.

Provide a Mermaid navigation diagram.

---

# 8. Screen-by-Screen UX Specification

Create detailed UI specifications for all MVP screens.

## Screen 01 — Splash / App Initialization

- Minimal branding.
- Avoid unnecessary waiting animations.
- Handle database initialization.
- Define error and recovery states.

## Screen 02 — Today Dashboard

Must include:

- Current date.
- Contextual greeting.
- Recommended next task.
- Lazy Button.
- Upcoming activities.
- Quick Capture entry point.
- Energy check-in.

The screen should not become an overwhelming productivity dashboard.

## Screen 03 — Quick Capture

- Fast text entry.
- Voice input option.
- Minimal form fields.
- Clear save action.
- Keyboard-aware layout.
- Cancel and retry behavior.

## Screen 04 — Voice Capture

- Clear recording state.
- Minimal waveform or recording feedback.
- Speech recognition status.
- Editable transcription.
- Retry and cancel controls.
- Explicit microphone permission handling.

## Screen 05 — AI Task Preview

- Display extracted tasks.
- Allow editing individual items.
- Display interpreted dates and times.
- Highlight ambiguous information.
- Allow removing incorrect suggestions.
- Require user confirmation before saving.

## Screen 06 — Task List

- Pending tasks.
- In-progress tasks.
- Completed tasks.
- Simple filtering.
- Clear task status indicators.

## Screen 07 — Task Detail

- Task title.
- Description.
- Priority.
- Due date and time.
- Estimated duration.
- Reminder configuration.
- Edit, complete, snooze, and delete actions.

## Screen 08 — Thought Inbox

- Unscheduled thoughts.
- Simple item cards.
- Convert-to-task action.
- Edit and delete actions.

## Screen 09 — Energy Check-in

- Low.
- Medium.
- High.

The interaction should be lightweight and dismissible.

## Screen 10 — Settings

- Notification preferences.
- AI availability information.
- Application preferences.
- Privacy information.
- Data management options appropriate to MVP.

For every screen define:

- Purpose.
- Layout hierarchy.
- Primary action.
- Secondary actions.
- Component composition.
- Loading state.
- Empty state.
- Error state.
- Accessibility behavior.
- Navigation transitions.

---

# 9. Interaction Design

Define interaction patterns for:

- Creating tasks.
- Completing tasks.
- Editing tasks.
- Snoozing reminders.
- Rescheduling.
- Voice recording.
- AI parsing.
- Reviewing extracted tasks.
- Lazy Button recommendations.
- Energy selection.
- Converting Inbox items into tasks.

Use bottom sheets where appropriate, but avoid using them for every interaction.

Avoid unnecessary confirmation dialogs for reversible actions.

Use confirmation for destructive or irreversible actions.

Define behavior for accidental taps and interrupted workflows.

---

# 10. Motion and Microinteractions

Use restrained animations.

Recommended motion characteristics:

- Fast.
- Subtle.
- Functional.
- Non-distracting.

Define animation guidelines for:

- Button press.
- Task completion.
- Card transitions.
- Bottom sheet entrance.
- Voice recording feedback.
- Loading indicators.
- Navigation transitions.

Provide suggested duration and easing tokens.

Respect reduced-motion accessibility preferences.

Do not add decorative animation that delays task completion.

---

# 11. UX Writing and Microcopy

Define LAZY's tone of voice.

Characteristics:

- Friendly.
- Concise.
- Calm.
- Slightly playful.
- Non-judgmental.
- Action-oriented.

The interface should support natural Indonesian microcopy.

Examples:

Instead of:
"You have failed to complete 4 tasks."

Use:
"Masih ada 4 kegiatan. Mau mulai dari yang paling ringan?"

Instead of:
"No tasks available."

Use:
"Belum ada kegiatan. Mau catat sesuatu?"

Provide microcopy examples for:

- Onboarding.
- Empty states.
- Errors.
- AI unavailable.
- Voice recognition failure.
- Task completion.
- Missed reminders.
- Lazy Button.
- Permission requests.

Avoid guilt-inducing productivity language.

---

# 12. Accessibility

Document accessibility requirements including:

- Sufficient color contrast.
- Scalable typography.
- Screen reader semantics.
- Accessible touch targets.
- Clear focus indicators.
- Reduced motion.
- Non-color-only status indicators.
- Voice input alternatives.
- Keyboard accessibility where relevant.

Ensure the application remains usable without voice input or cloud AI.

---

# 13. Flutter Design System Implementation Strategy

Without writing source code, propose a Flutter implementation strategy covering:

- ThemeData.
- ColorScheme.
- TextTheme.
- Theme extensions where appropriate.
- Reusable widgets.
- Design tokens.
- Component organization.
- Responsive layouts.
- Accessibility testing.

Propose a directory structure such as:

mobile/lib/core/theme/
mobile/lib/core/widgets/

Keep feature-specific widgets inside their corresponding feature directories.

Avoid creating a large generic UI framework unnecessarily.

---

# 14. Required Deliverables

The final DESIGN_SYSTEM.md must contain:

1. Design Philosophy.
2. Visual Identity.
3. Color Tokens.
4. Typography Scale.
5. Spacing and Layout Tokens.
6. Border Radius and Elevation.
7. Component Specifications.
8. Information Architecture.
9. Screen-by-Screen UX Specifications.
10. Interaction Patterns.
11. Motion Guidelines.
12. UX Writing Guidelines.
13. Accessibility Requirements.
14. Flutter Implementation Guidelines.
15. Design QA Checklist.
16. Design Decisions and Trade-offs.

Include tables where appropriate.

Include Mermaid diagrams for navigation and major user interaction flows.

The document must be detailed enough for OpenCode to implement the UI consistently without inventing new design decisions during development.

Do not generate application source code.

Do not generate IMPLEMENTATION_PLAN.md yet.

The only required deliverable is:

docs/DESIGN_SYSTEM.md
