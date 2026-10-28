# Laporan Praktikum & Proyek Akhir: StudyLog
**Mata Kuliah:** Pemrograman Aplikasi Bergerak  
**Program Studi:** Informatika — Universitas Mulia  
**Kelas:** IFB5J  
**Tahun Akademik:** 2026  

---

## 1. Identitas Mahasiswa & Proyek
- **Nama Mahasiswa:** [Nama Lengkap Anda]
- **NIM:** [NIM Anda]
- **Kelas:** IFB5J
- **Tautan Repository GitHub:** [https://github.com/rillsussy/studylog](https://github.com/rillsussy/studylog)
- **Tautan Video Demo:** [Tuliskan Tautan Google Drive / YouTube Video Demo di sini]

---

## 2. Ringkasan Proyek & Implementasi Checkpoint

Aplikasi **StudyLog** adalah aplikasi catatan perkuliahan Android yang beroperasi secara penuh tanpa koneksi internet (*offline-first*). Aplikasi dibangun secara modular mengikuti 3 Checkpoint terpadu dan diperluas dengan fitur Project-Based Learning (PjBL):

1. **Milestone 01 (M1) — Interaksi & Form:**
   - Formulir catatan dengan 3 input wajib (`Mata Kuliah`, `Judul`, `Isi`).
   - Validasi ketat yang menolak input kosong maupun input yang hanya berisi karakter spasi (`trim().isEmpty`).
   - State lokal interaktif serta umpan balik visual menggunakan `SnackBar`.

2. **Milestone 02 (M2) — Navigasi & State Management:**
   - Alur navigasi 4 layar: **Beranda $\to$ Daftar Catatan $\to$ Form Catatan $\to$ Detail Catatan**.
   - Manajemen rute menggunakan `Navigator.push` dan `Navigator.pop` dengan struktur *back stack* yang konsisten.
   - Pemisahan logika dari widget ke state terpusat menggunakan `ChangeNotifier` dan `Provider`.

3. **Milestone 03 (M3) — Persistensi Database SQLite & Arsitektur Berlapis:**
   - Penyimpanan data permanen di perangkat menggunakan paket `sqflite` dan `path`.
   - Mengikuti pola arsitektur berlapis (*Layered Architecture*):
     $$\text{UI (Screens)} \longleftrightarrow \text{ViewModel} \longleftrightarrow \text{Repository} \longleftrightarrow \text{DatabaseHelper} \longleftrightarrow \text{SQLite}$$
   - Fitur CRUD lengkap (*Create, Read, Update, Delete*) disertai dialog konfirmasi pembatalan/penghapusan.
   - Uji persistensi data setelah *full restart*.

4. **Pengembangan Mandiri PjBL (Extension):**
   - **Ekstensi C (Relasional multi-tabel):** Tabel `jadwal` (8 mata kuliah kelas IFB5J) berelasi 1..N ke `catatan.jadwal_id` dengan migrasi skema v1 $\to$ v2 dan auto-seed jadwal.
   - **Fitur Cerdas "Catat Sekarang":** Sistem mencocokkan waktu real-time (`DateTime.now()`) dengan jam kuliah. Saat jam kuliah aktif (atau 15 menit menjelang mulai), Beranda menampilkan kartu aktif beserta tombol **"Catat Sekarang"** yang langsung membuka form dengan mata kuliah dan judul terisi otomatis.
   - **Ekstensi A (Pencarian & Filter):** Pencarian *real-time* berbasis kata kunci pada judul/mata kuliah/isi serta filter cepat menggunakan *choice chips* per mata kuliah.

---

## 3. Bukti Tangkapan Layar (Screenshots Antarmuka)

Berikut dokumentasi antarmuka yang diambil langsung dari perangkat Android:

### 3.1. Validasi Formulir (Mencegah Input Kosong / Spasi)
Menampilkan pesan kesalahan validasi saat form disimpan tanpa data yang valid.
![Validasi Form](screenshots/01_form_validasi_error.png)

### 3.2. Beranda & Deteksi Jadwal Kuliah
Menampilkan informasi perkuliahan berikutnya serta daftar tombol cepat (*chips*) 8 mata kuliah kelas IFB5J.
![Beranda & Jadwal](screenshots/02_beranda_jadwal.png)

### 3.3. Formulir Catatan Baru
Mata kuliah terpilih dari jadwal dan field dapat diisi dengan mudah.
![Form Tambah Catatan](screenshots/03_form_tambah_catatan.png)

### 3.4. Layar Daftar Catatan & Fitur Pencarian / Filter
Daftar catatan perkuliahan dilengkapi kolom pencarian dan tombol filter kategori mata kuliah.
![Daftar Catatan](screenshots/04_daftar_catatan_filter.png)

### 3.5. Layar Detail Catatan
Menampilkan rincian judul, isi catatan, tanggal, serta metadata relasi jadwal (kode MK, jam, ruang, dosen).
![Detail Catatan](screenshots/05_detail_catatan.png)

### 3.6. Dialog Konfirmasi Hapus
Dialog pengaman sebelum catatan dihapus secara permanen dari database SQLite.
![Dialog Konfirmasi Hapus](screenshots/06_dialog_konfirmasi_hapus.png)

---

## 4. Matriks Pengujian & Observasi Sistem

| No | Kasus Uji | Skenario Pengujian | Hasil yang Diharapkan | Hasil Pengamatan | Status |
|:--:|---|---|---|---|:--:|
| **T1** | Validasi Input Kosong | Menekan tombol "Simpan" dengan seluruh field kosong | Sistem menolak simpan dan menampilkan pesan kesalahan "wajib diisi" di setiap field | Pesan error muncul di bawah setiap field | **Lulus** |
| **T2** | Validasi Input Spasi | Mengisi field hanya dengan spasi (`   `) lalu simpan | Nilai spasi ditolak setelah `trim()`, sistem meminta input valid | Muncul pesan error "Judul wajib diisi" | **Lulus** |
| **T3** | Create (Tambah Catatan) | Mengisi data catatan lengkap lalu tekan "Simpan" | Data tersimpan ke database lokal SQLite dan tampil di Daftar Catatan | Catatan langsung muncul di baris teratas daftar | **Lulus** |
| **T4** | Read (Detail Catatan) | Memilih salah satu catatan dari Daftar Catatan | Halaman Detail terbuka dengan rincian yang cocok dengan data input | Rincian judul, isi, waktu, dan dosen tampil akurat | **Lulus** |
| **T5** | Update (Ubah Catatan) | Menekan ikon edit di Detail, mengubah judul/isi, lalu simpan | Data pada database diperbarui dan perubahan langsung terlihat di Detail & Daftar | Judul dan isi berhasil diperbarui tanpa duplikasi | **Lulus** |
| **T6** | Delete (Batal Hapus) | Menekan ikon hapus di Detail, lalu menekan tombol "Batal" | Dialog tertutup dan catatan tetap tersimpan aman di database | Catatan tidak terhapus | **Lulus** |
| **T7** | Delete (Setuju Hapus) | Menekan ikon hapus di Detail, lalu menekan tombol "Hapus" | Catatan terhapus dari database SQLite dan kembali ke halaman Daftar | Catatan hilang dari daftar, SnackBar konfirmasi muncul | **Lulus** |
| **T8** | Persistensi (Full Restart) | Menambah catatan, menutup paksa aplikasi (*kill recent apps*), lalu membuka ulang aplikasi | Data catatan tetap tersimpan dan langsung tampil kembali tanpa koneksi internet | Seluruh catatan tetap utuh tersimpan di SQLite | **Lulus** |
| **T9** | Smart Live Course / Catat Sekarang | Membuka aplikasi pada jam kuliah (19:00 - 22:00) | Muncul kartu "SEDANG BERLANGSUNG", tombol "Catat Sekarang" mengotomatisasi pengisian mata kuliah | Pengguna dapat langsung mengetik isi materi tanpa mencari mata kuliah | **Lulus** |
| **T10** | Pencarian & Filter | Mengetik kata kunci di kolom pencarian atau memilih chip mata kuliah | Daftar catatan hanya menyaring catatan yang cocok secara instan | Filter dan search berfungsi secara *real-time* | **Lulus** |

---

## 5. Ringkasan Pengujian Otomatis (Automated Tests)
Proyek dilengkapi dengan pengujian unit, widget, dan migrasi database:
- **Total Pengujian:** 16 pengujian otomatis (`flutter test`)
- **Status Static Analysis:** 0 issue (`flutter analyze`)
- **Daftar Berkas Pengujian:**
  1. `test/catatan_model_test.dart`: Validasi model serialisasi JSON/Map dan copyWith.
  2. `test/catatan_repository_test.dart`: Pengujian CRUD langsung ke SQLite FFI in-memory.
  3. `test/status_kuliah_test.dart`: Logika penentuan kuliah aktif, kuliah segera dimulai, dan kuliah berikutnya.
  4. `test/database_migrasi_test.dart`: Pengujian migrasi otomatis skema v1 ke skema v2 relasional.
  5. `test/widget_test.dart`: Pengujian interaksi UI form, alur navigasi, dan simulasi tombol "Catat Sekarang".

---

## 6. Laporan Refleksi Individual

Dalam menyelesaikan proyek praktikum **StudyLog**, beberapa pembelajaran kunci yang diperoleh antara lain:
1. **Pemisahan State dan UI:** Mengisolasi logika bisnis dari tampilan widget ke dalam `ViewModel` (`ChangeNotifier`) membuat kode jauh lebih bersih, terstruktur, dan mudah diuji secara independen tanpa ketergantungan UI yang rumit.
2. **Persistensi Data SQLite:** Memahami siklus hidup data (*lifecycle*) antara data sementara di memori (RAM) dengan data permanen di penyimpanan lokal (`sqflite`). Penggunaan pola *Repository* mempermudah abstraksi kueri SQL sehingga komponen UI tidak perlu mengetahui sintaks SQL langsung.
3. **Penerapan Relasi & Pemecahan Masalah Nyata:** Mengintegrasikan jadwal kuliah malam kelas IFB5J ke dalam database dan menghadirkan fitur *Auto-Detect Kuliah Aktif* memberikan pengalaman langsung bagaimana aplikasi mobile dapat menyelesaikan kendala nyata pengguna (efisiensi waktu saat perkuliahan berlangsung).
