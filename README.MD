# LAZY — AI-Powered Personal Productivity Assistant

> Less planning. More doing.

LAZY adalah asisten produktivitas personal Android-first yang meminimalkan gesekan antara niat dan tindakan nyata melalui prinsip *capture first, organize later*, *local-first*, dan rekomendasi deterministik *Lazy Button*.

---

## Struktur Monorepo

```text
project-LAZY/
├── docs/                 # Dokumentasi arsitektur, PRD, design system, dan plan
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── DESIGN_SYSTEM.md
│   └── IMPLEMENTATION_PLAN.md
├── mobile/               # Aplikasi mobile Android (Flutter + Riverpod + Drift)
├── server/               # AI Orchestration backend (Golang + Gin + 9Router)
├── AGENTS.MD             # Petunjuk eksekusi AI coding agent
└── README.MD
```

---

## Tech Stack

- **Mobile**: Flutter, Riverpod, GoRouter, Drift (SQLite), `flutter_local_notifications`, `speech_to_text`
- **Backend**: Golang, Gin, `log/slog`, `go-playground/validator`
- **AI Gateway**: Hidden

---

## Panduan Memulai

Lihat petunjuk teknis di `docs/IMPLEMENTATION_PLAN.md`.
