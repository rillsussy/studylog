# StudyLog — Aplikasi Catatan Perkuliahan

Aplikasi catatan perkuliahan **Flutter Android** yang berjalan **offline-first** menggunakan database lokal **SQLite (`sqflite`)**. Disusun sesuai panduan **Workbook Praktikum Pemrograman Aplikasi Bergerak** — Program Studi Informatika, Universitas Mulia (Kelas **IFB5J**).

---

## Daftar Fitur

### 1. Fitur Utama (Kompetensi Checkpoint M1 – M3)
- **Form Interaktif & Validasi (M1):** Input *Mata Kuliah*, *Kategori/Tag*, *Judul*, *Topik* (opsional, validasi minimal 3 karakter bila diisi), dan *Isi Catatan*. Menolak input kosong maupun spasi saja (`trim().isEmpty`), dilengkapi umpan balik visual tombol & `SnackBar`.
- **Navigasi Multi-Layar & State Management (M2):** Alur `Beranda → Daftar Catatan → Detail Catatan → Form Catatan` serta halaman `Tentang Aplikasi` menggunakan `Navigator.push`/`Navigator.pop`, `ChangeNotifier`, `Provider`, dan `Consumer`.
- **Persistensi SQLite & CRUD Berlapis (M3):** Operasi *Create, Read, Update, Delete* (dengan dialog konfirmasi *Batal* / *Hapus* serta tombol *Coba lagi* saat error) melalui arsitektur `UI ↔ ViewModel ↔ Repository ↔ DatabaseHelper ↔ SQLite`.

### 2. Fitur Unggulan & Pengembangan Mandiri PjBL (Bab 6.2 Workbook)
- **Catat Sekarang (Deteksi Otomatis Jam Kuliah):** Saat perkuliahan kelas IFB5J berlangsung (atau 15 menit sebelum mulai), Beranda menampilkan kartu **SEDANG BERLANGSUNG** beserta tombol **Catat Sekarang**. Satu ketukan langsung membuka form dengan mata kuliah, kategori, dan judul otomatis terisi serta kursor fokus di kolom isi. Di luar jam kuliah, tampil info kuliah berikutnya dan 8 chip cepat mata kuliah.
- **Tiga Tabel Relasional & Migrasi Skema (`v1 → v2 → v3`):** Relasi antara tabel `jadwal` (mata kuliah), `kategori` (tag catatan), dan `catatan` dengan `FOREIGN KEY ... ON DELETE SET NULL` serta migrasi otomatis `onUpgrade` tanpa menghapus data pengguna.
- **Cari Catatan:** Pencarian *real-time* berdasarkan kata kunci pada judul, mata kuliah, topik, atau isi.
- **Urutkan Catatan:** Pengaturan urutan daftar catatan **Terbaru** atau **Terlama**.
- **Filter Mata Kuliah & Kategori/Tag:** Penyaringan daftar menggunakan *chips* per mata kuliah dan per kategori.
- **Tandai Favorit:** Penanda bintang catatan prioritas yang tersimpan permanen di SQLite dan bertahan setelah aplikasi ditutup paksa.
- **Ekspor / Salin Teks:** Menyalin isi catatan terformat rapi beserta metadata ke papan klip (*clipboard*) dari layar Detail.

---

## Skema Database SQLite (v3 — Tiga Tabel Relasional)

```text
jadwal(
  id INTEGER PK AUTOINCREMENT,
  hari INTEGER NOT NULL,        -- 1 = Senin ... 7 = Minggu
  mulai INTEGER NOT NULL,       -- menit sejak 00:00 (mis. 19:00 = 1140)
  selesai INTEGER NOT NULL,
  kode TEXT NOT NULL,
  nama TEXT NOT NULL,
  sks INTEGER NOT NULL,
  kelas TEXT NOT NULL,
  ruang TEXT NOT NULL,
  dosen TEXT NOT NULL
)

kategori(
  id INTEGER PK AUTOINCREMENT,
  nama TEXT NOT NULL UNIQUE,    -- Materi Kuliah, Praktikum, Tugas, Kuis & Ujian, Rangkuman
  warna INTEGER NOT NULL
)

catatan(
  id INTEGER PK AUTOINCREMENT,
  mata_kuliah TEXT NOT NULL,
  judul TEXT NOT NULL,
  isi TEXT NOT NULL,
  tanggal TEXT NOT NULL,        -- ISO 8601
  topik TEXT NOT NULL DEFAULT '',
  favorit INTEGER NOT NULL DEFAULT 0,
  jadwal_id INTEGER REFERENCES jadwal(id) ON DELETE SET NULL,
  kategori_id INTEGER REFERENCES kategori(id) ON DELETE SET NULL
)
```

---

## Struktur Folder (Sesuai Bab 5.4 & 9.1 Workbook)

```text
lib/
  main.dart
  models/
    catatan.dart
    jadwal.dart
    kategori.dart
  data/
    database_helper.dart
    catatan_repository.dart
    jadwal_repository.dart
    jadwal_seed.dart
    kategori_repository.dart
    kategori_seed.dart
  viewmodels/
    catatan_view_model.dart
    jadwal_view_model.dart
    kategori_view_model.dart
  screens/
    beranda_page.dart
    daftar_catatan_page.dart
    detail_catatan_page.dart
    form_catatan_page.dart
    tentang_page.dart
  utils/
    format.dart
    status_kuliah.dart
test/
  catatan_model_test.dart
  catatan_repository_test.dart
  database_migrasi_test.dart
  fakes.dart
  status_kuliah_test.dart
  widget_test.dart
docs/
  LAPORAN_PRAKTIKUM.md
  screenshots/
```

---

## Prasyarat, Instalasi, dan Cara Menjalankan

### Prasyarat
1. **Flutter SDK** stabil dan **Android SDK** terpasang di sistem.
2. Emulator Android aktif atau ponsel Android tersambung dengan *USB Debugging* aktif.
   > **Perhatian:** Paket `sqflite` ditujukan untuk target **Android** (emulator/perangkat fisik). Jangan memilih target browser Chrome saat menguji persistensi database aplikasi.

### Pemeriksaan Lingkungan
```bash
flutter --version
flutter doctor
flutter devices
```

### Instalasi & Menjalankan Aplikasi
```bash
git clone https://github.com/rillsussy/studylog.git
cd studylog
flutter pub get
flutter analyze
flutter test
flutter run
```

Untuk membangun berkas APK Android secara langsung:
```bash
flutter build apk --debug
```

---

## Dokumentasi & Bukti Pengujian
Seluruh matriks pengujian (M1, Lifecycle M2, CRUD M3, Backlog PjBL, Logbook Debugging, Screenshot Antarmuka, dan Refleksi Individual) terdokumentasi lengkap pada:
- [`docs/LAPORAN_PRAKTIKUM.md`](docs/LAPORAN_PRAKTIKUM.md)

---

## Kontribusi Pengembangan

| Peran | Tanggung Jawab & Kontribusi |
|---|---|
| **Pengembang (@rillsussy — Kelas IFB5J)** | Perancangan skema 3 tabel relasional SQLite (`jadwal`, `kategori`, `catatan`) beserta migrasi `v1 → v2 → v3`, implementasi arsitektur berlapis (`DatabaseHelper`, `Repository`, `ViewModel`, 5 layar UI), fitur cerdas *Catat Sekarang* sesuai jadwal IFB5J, pencarian/filter/pengurutan/favorit/ekspor teks, penulisan unit & widget test otomatis, serta pengujian langsung pada perangkat Android. |
