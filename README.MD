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

### Menjalankan Backend (Server)
```bash
cd server
cp .env.example .env # Sesuaikan konfigurasi URL dan token 9Router jika diperlukan
go run cmd/server/main.go
```

### Menjalankan Mobile App (Debug)
```bash
cd mobile
flutter run
```

---

## Release MVP v1.0 (Android)

Binary APK rilis dihasilkan menggunakan `flutter build apk --release` (minSdk 24, Android 7.0+).

### Lokasi APK
```text
mobile/build/app/outputs/flutter-apk/app-release.apk (~60MB)
```

### Petunjuk Instalasi
1. Transfer `app-release.apk` ke perangkat Android fisik via USB / adb:
   ```bash
   adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
   ```
2. Atau aktifkan opsi *Install from unknown sources* pada pengaturan keamanan perangkat untuk instalasi manual via File Manager.

### Fitur yang Didukung pada MVP v1.0
- **Offline-First Task Management**: CRUD task, priority, energy, contextual tagging, filter, search (Drift SQLite).
- **The Lazy Button**: Algoritma deterministik scoring 3-faktor (<10ms) untuk menyajikan tugas paling relevan.
- **Smart Brain Dump**: Transkripsi suara (STT) + AI Extraction via Go backend + konfirmasi interaktif.
- **Micro-Steps Generator**: Pemecahan tugas kompleks menjadi langkah-langkah mikro yang actionable.
- **Local Reminders**: Pengingat berkala/jadwal via `flutter_local_notifications` tanpa ketergantungan cloud.
- **Analytics & Streak**: Ringkasan performa harian dan visualisasi streak produktivitas.

### Batasan MVP
- Signing APK menggunakan default release config (debug keystore untuk testing lokal sebelum signing production key).
- Transkripsi suara bergantung pada kapabilitas Speech-to-Text perangkat lokal.
- Fitur AI (Brain Dump & Micro-Steps) membutuhkan koneksi ke server Go backend yang terhubung ke 9Router API gateway.

---

Dokumentasi lengkap arsitektur dan spesifikasi tersedia di folder `docs/`.
