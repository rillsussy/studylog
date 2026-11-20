import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Halaman informasi aplikasi & profil kelompok (Tugas Pengayaan Bab 4.7 Workbook).
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // Header Card
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'StudyLog',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aplikasi Catatan Perkuliahan Offline-First',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'IFB5J • Versi 3.0 (3 Tabel Relasional SQLite)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Card: Anggota Kelompok
          const _SectionCard(
            title: 'Anggota Kelompok',
            icon: Icons.groups_outlined,
            children: [
              _MemberTile(
                no: '1',
                nama: 'Ryanda Hermawan',
                nim: '2411068',
                peran: 'Arsitektur SQLite 3 Tabel Relasional & Git',
              ),
              Divider(height: 16),
              _MemberTile(
                no: '2',
                nama: 'Dewi Nofitta Sari',
                nim: '2411065',
                peran: 'Antarmuka Multi-Layar & State Provider',
              ),
              Divider(height: 16),
              _MemberTile(
                no: '3',
                nama: 'Bintang Sahda Rayyu Sonora',
                nim: '2411025',
                peran: 'Pengujian Sistem, Video Demo & Dokumentasi',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card: Mata Kuliah & Institusi
          const _SectionCard(
            title: 'Mata Kuliah & Institusi',
            icon: Icons.account_balance_outlined,
            children: [
              Text(
                'Pemrograman Aplikasi Bergerak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dosen Pengampu: Pramudya Prima Insan, S.Kom., M.Kom.',
                style: TextStyle(fontSize: 13, color: AppTheme.secondary),
              ),
              SizedBox(height: 2),
              Text(
                'Program Studi S1 Informatika — Fakultas Ilmu Komputer\nUniversitas Mulia Balikpapan (2026)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card: Arsitektur & Database
          const _SectionCard(
            title: 'Arsitektur & Basis Data',
            icon: Icons.layers_outlined,
            children: [
              Text(
                'Arsitektur Berlapis (Layered Architecture):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'UI (Material 3) ↔ ViewModel (ChangeNotifier/Provider) ↔ Repository ↔ DatabaseHelper ↔ SQLite (sqflite)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Skema 3 Tabel Relasional SQLite (v3):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '• jadwal (id, kode, nama, hari, jam, ruang, dosen, sks)\n'
                '• kategori (id, nama, warna, ikon)\n'
                '• catatan (id, judul, topik, isi, tanggal, favorit, jadwal_id FK, kategori_id FK)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card: Fitur Unggulan
          const _SectionCard(
            title: 'Fitur Unggulan',
            icon: Icons.bolt_outlined,
            children: [
              Text(
                '• Deteksi Cerdas Perkuliahan Aktif ("Catat Sekarang") sesuai jadwal IFB5J\n'
                '• Pencarian teks instan (judul, isi, topik, mata kuliah)\n'
                '• Pengurutan catatan (Terbaru ↔ Terlama)\n'
                '• Filter multi-kategori dan penanda bintang/favorit permanen di SQLite\n'
                '• Salin dan bagikan catatan rapi ke papan klip (clipboard)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String no;
  final String nama;
  final String nim;
  final String peran;

  const _MemberTile({
    required this.no,
    required this.nama,
    required this.nim,
    required this.peran,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.secondaryContainer,
          radius: 12,
          child: Text(
            no,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nama ($nim)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                peran,
                style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
