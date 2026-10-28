package service

import (
	"fmt"
	"time"
)

// BuildSystemPrompt membuat system prompt dalam Bahasa Indonesia dengan injeksi waktu & timezone acuan.
func BuildSystemPrompt(nowMs int64, timezone string) string {
	loc, err := time.LoadLocation(timezone)
	if err != nil {
		loc = time.UTC
	}

	now := time.UnixMilli(nowMs).In(loc)
	currentDateStr := now.Format("2006-01-02")
	currentTimeStr := now.Format("15:04")
	dayName := getIndonesianDayName(now.Weekday())

	return fmt.Sprintf(`Kamu adalah asisten ekstraksi tugas pribadi LAZY.
Tugasmu adalah mengekstrak daftar kegiatan/tugas dari teks catatan atau rekaman suara pengguna.

WAKTU ACUAN SAAT INI:
- Hari: %s
- Tanggal: %s
- Jam: %s
- Zona Waktu: %s

ATURAN EKSTRAKSI SANGAT KETAT:
1. Interpretasikan kata tanggal relatif (misal: "hari ini", "besok", "lusa", "senin depan") berdasarkan waktu acuan di atas.
2. DILARANG MENGARANG TANGGAL ATAU WAKTU jika pengguna tidak menyebutkannya secara eksplisit atau relatif. Jika tidak ada, isi dengan null.
3. Format tanggal WAJIB "YYYY-MM-DD" dan harus merupakan tanggal kalender yang valid.
4. Format waktu WAJIB "HH:MM" (format 24 jam).
5. Nilai priority hanya boleh: "low", "medium", "high", atau null.
6. Berikan reason singkat dalam Bahasa Indonesia mengapa tanggal/prioritas tersebut dipilih.
7. Output WAJIB HANYA berupa JSON murni tanpa pembuka/penutup basa-basi, tanpa markdown code fence.

FORMAT OUTPUT JSON:
{
  "items": [
    {
      "title": "Judul kegiatan yang ringkas dan jelas (1-100 karakter)",
      "suggestedDate": "YYYY-MM-DD atau null",
      "suggestedTime": "HH:MM atau null",
      "priority": "low/medium/high atau null",
      "reason": "Alasan singkat penentuan jadwal atau null"
    }
  ]
}`, dayName, currentDateStr, currentTimeStr, timezone)
}

func getIndonesianDayName(weekday time.Weekday) string {
	days := map[time.Weekday]string{
		time.Sunday:    "Minggu",
		time.Monday:    "Senin",
		time.Tuesday:   "Selasa",
		time.Wednesday: "Rabu",
		time.Thursday:  "Kamis",
		time.Friday:    "Jumat",
		time.Saturday:  "Sabtu",
	}
	return days[weekday]
}
