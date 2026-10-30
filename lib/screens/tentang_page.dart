import 'package:flutter/material.dart';

/// Halaman informasi aplikasi (Tugas Pengayaan Bab 4.7 Workbook).
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'StudyLog',
            style: text.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Aplikasi Catatan Perkuliahan Offline-First',
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.groups_outlined),
            title: Text('Anggota Kelompok (Kelas IFB5J)'),
            subtitle: Text(
              '• Ryanda Hermawan (2411068)\n'
              '• Dewi Nofitta Sari (2411065)\n'
              '• Bintang Sahda Rayyu Sonora (2411025)',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('Mata Kuliah & Institusi'),
            subtitle: Text(
              'Pemrograman Aplikasi Bergerak\n'
              'Program Studi Informatika — Universitas Mulia (Kelas IFB5J)',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.layers_outlined),
            title: Text('Arsitektur Aplikasi'),
            subtitle: Text(
              'UI (Screens) ↔ ViewModel (ChangeNotifier/Provider) ↔ '
              'Repository ↔ DatabaseHelper ↔ SQLite (sqflite)',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Skema Tiga Tabel Relasional (SQLite v3)'),
            subtitle: Text(
              '• jadwal (mata kuliah & jam perkuliahan)\n'
              '• kategori (tag klasifikasi catatan)\n'
              '• catatan (catatan perkuliahan, relasi FK ke jadwal & kategori)',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.bolt_outlined),
            title: Text('Fitur Unggulan'),
            subtitle: Text(
              'Deteksi otomatis perkuliahan aktif ("Catat Sekarang"), '
              'pencarian, pengurutan terbaru/terlama, penanda favorit '
              'permanen, dan salin/ekspor teks catatan.',
            ),
          ),
        ],
      ),
    );
  }
}
