# StudyLog

Aplikasi catatan perkuliahan Flutter Android yang berjalan **offline-first** dengan SQLite.
Dibuat untuk praktikum Pemrograman Aplikasi Bergerak — Universitas Mulia (kelas IFB5J).

## Fitur Utama: Catat Sekarang

Saat jam kuliah berlangsung (atau 15 menit sebelum mulai), Beranda langsung menampilkan
kartu **SEDANG BERLANGSUNG** berisi mata kuliah, jam, ruang, dan dosen, beserta tombol
**Catat Sekarang**. Satu ketukan membuka form dengan mata kuliah dan judul
(`Pertemuan <tanggal>`) sudah terisi, dan kursor langsung berada di kolom isi.

Di luar jam kuliah, Beranda menampilkan **kuliah berikutnya** dan tombol cepat
(chip) untuk tiap mata kuliah.

## Milestone

| Tahap | Isi |
|---|---|
| M1 | Form `TextFormField` + `GlobalKey<FormState>`, validasi kosong/spasi, `SnackBar` |
| M2 | Navigasi 4 layar (Beranda → Daftar → Form → Detail), state lintas layar dengan `Provider` |
| M3 | SQLite (`sqflite`) CRUD, arsitektur berlapis UI ↔ ViewModel ↔ Repository ↔ DatabaseHelper ↔ SQLite, dialog konfirmasi hapus |
| Ekstensi C | Tabel `jadwal` relasional (1..N ke `catatan.jadwal_id`), migrasi skema v1 → v2, seed jadwal IFB5J |
| Ekstensi A | Pencarian (judul / mata kuliah / isi) dan filter per mata kuliah |

## Skema Database (v2)

```
jadwal(id PK, hari, mulai, selesai, kode, nama, sks, kelas, ruang, dosen)
catatan(id PK, mata_kuliah TEXT NOT NULL, judul TEXT NOT NULL, isi TEXT NOT NULL,
        tanggal TEXT ISO 8601, jadwal_id FK -> jadwal.id ON DELETE SET NULL)
```

`hari` mengikuti `DateTime.weekday` (1 = Senin), `mulai`/`selesai` dalam menit sejak 00:00.
Jadwal awal ada di [`lib/data/jadwal_seed.dart`](lib/data/jadwal_seed.dart).

## Struktur

```
lib/
  data/        database_helper, catatan_repository, jadwal_repository, jadwal_seed
  models/      catatan, jadwal
  viewmodels/  catatan_viewmodel, jadwal_viewmodel
  screens/     beranda, daftar_catatan, form_catatan, detail_catatan
  utils/       format, status_kuliah
test/          unit, migrasi database, dan widget test
```

## Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Matriks Uji

| Skenario | Cara uji | Otomatis |
|---|---|---|
| Validasi input kosong / spasi | Simpan form kosong | `widget_test.dart` |
| Catat Sekarang saat kuliah berlangsung | Rabu 20:45 → Kriptografi | `widget_test.dart` |
| Info kuliah berikutnya di luar jam | Rabu 09:00 | `widget_test.dart` |
| Penentuan kuliah aktif / berikutnya | Berbagai hari & jam | `status_kuliah_test.dart` |
| Create / Read / Update / Delete | Repository + SQLite FFI | `catatan_repository_test.dart` |
| Pencarian & filter | Kata kunci + jadwal | `catatan_repository_test.dart`, `widget_test.dart` |
| Seed jadwal & migrasi v1 → v2 | DB v1 dibuka oleh helper v2 | `database_migrasi_test.dart` |
| Persistensi setelah full restart | Tambah catatan, tutup paksa aplikasi, buka lagi | Manual |
