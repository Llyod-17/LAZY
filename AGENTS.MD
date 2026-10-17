# AGENTS.md — OpenCode Execution Guidelines for LAZY

Petunjuk eksekusi bagi AI Coding Agent (OpenCode) dalam mengembangkan proyek LAZY.

---

## 1. Prinsip Utama (Core Principles)
- **Ponytail / Lazy Senior Dev**: YAGNI, utamakan kode minimal yang bekerja dan teruji, hindari over-engineering atau abstraksi prematur.
- **Terse & Direct (Caveman Mode)**: Komunikasi ringkas, padat teknis, tanpa basa-basi atau spekulasi berlebihan.
- **Single Source of Truth**: Selalu patuhi dokumen di `docs/` (`PRD.md`, `ARCHITECTURE.md`, `DESIGN_SYSTEM.md`, `IMPLEMENTATION_PLAN.md`).
- **One Task at a Time**: Hanya eksekusi SATU task berstatus `TODO` yang dependensinya sudah `DONE`. Dilarang mengerjakan multiple task sekaligus.

---

## 2. Prosedur Sebelum Modifikasi (Pre-Change Protocol)
Sebelum melakukan modifikasi kode atau membuat file:
1. **Ringkasan Task**: Sebutkan ID dan nama task yang sedang dikerjakan.
2. **Pendekatan Implementasi**: Jelaskan strategi teknis secara ringkas.
3. **File yang Dimodifikasi**: Daftarkan file yang akan dibuat/diubah.
4. **Langkah Verifikasi**: Daftarkan perintah test/build untuk memverifikasi pekerjaan.

---

## 3. Batasan & Larangan (Strict Constraints)
- Dilarang menambahkan dependensi tanpa kebutuhan jelas yang tertuang di ARCHITECTURE.md.
- Dilarang membuat abstraksi untuk komponen yang hanya memiliki satu implementasi.
- Dilarang mengubah skema arsitektur atau dependensi tanpa konfirmasi.
- Dilarang meng-commit file kredensial (`.env`, private keys).
- Dilarang mengklaim test lulus tanpa menjalankan perintah verifikasi yang sesungguhnya.
- Dilarang menghapus atau melemahkan test untuk membuat build lulus.

---

## 4. Prosedur Penyelesaian Task (Completion Protocol)
1. Jalankan perintah verifikasi spesifik task (format, analyze/vet, test).
2. Periksa `git status` dan pastikan hanya file terkait yang berubah.
3. Perbarui status task menjadi `DONE` di `docs/IMPLEMENTATION_PLAN.md`.
4. Berikan ringkasan ringkas hasil pekerjaan dan langkah selanjutnya.
