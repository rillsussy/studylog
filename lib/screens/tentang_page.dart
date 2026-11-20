import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database_helper.dart';
import '../data/profil_repository.dart';
import '../models/profil.dart';
import '../theme/app_theme.dart';
import '../viewmodels/profil_view_model.dart';

/// Halaman informasi aplikasi & profil mahasiswa/kelompok (Workbook Bab 4.7).
class TentangPage extends StatefulWidget {
  const TentangPage({super.key});

  @override
  State<TentangPage> createState() => _TentangPageState();
}

class _TentangPageState extends State<TentangPage> {
  late Profil _profilLocal;
  late final ProfilRepository _repoFallback;

  @override
  void initState() {
    super.initState();
    _profilLocal = Profil.defaultProfil();
    _repoFallback = ProfilRepository(DatabaseHelper.instance);
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    final p = await _repoFallback.ambil();
    if (mounted) {
      setState(() => _profilLocal = p);
    }
  }

  void _dialogEditProfil(
    BuildContext context,
    Profil profilAwal,
    ProfilViewModel? vm,
  ) {
    final formKey = GlobalKey<FormState>();
    final namaC = TextEditingController(text: profilAwal.nama);
    final nimC = TextEditingController(text: profilAwal.nim);
    final kelasC = TextEditingController(text: profilAwal.kelas);
    final prodiC = TextEditingController(text: profilAwal.prodi);
    final semesterC = TextEditingController(text: profilAwal.semester);
    final institusiC = TextEditingController(text: profilAwal.institusi);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.badge_outlined, color: AppTheme.primary),
            SizedBox(width: 8),
            Text(
              'Edit Data Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Masukkan identitas mahasiswa yang aktif menggunakan aplikasi:',
                  style: TextStyle(fontSize: 12, color: AppTheme.secondary),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('field_profil_nama'),
                  controller: namaC,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_profil_nim'),
                  controller: nimC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'NIM *',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'NIM tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('field_profil_kelas'),
                        controller: kelasC,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: const Key('field_profil_semester'),
                        controller: semesterC,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_profil_prodi'),
                  controller: prodiC,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_profil_institusi'),
                  controller: institusiC,
                  decoration: const InputDecoration(
                    labelText: 'Institusi / Kampus',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            key: const Key('tombol_simpan_profil'),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Simpan'),
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final baru = Profil(
                nama: namaC.text.trim(),
                nim: nimC.text.trim(),
                kelas: kelasC.text.trim().isEmpty
                    ? 'IFB5J'
                    : kelasC.text.trim(),
                prodi: prodiC.text.trim().isEmpty
                    ? 'S1 Informatika'
                    : prodiC.text.trim(),
                semester: semesterC.text.trim().isEmpty
                    ? 'Semester 5'
                    : semesterC.text.trim(),
                institusi: institusiC.text.trim().isEmpty
                    ? 'Universitas Mulia Balikpapan'
                    : institusiC.text.trim(),
              );

              if (vm != null) {
                await vm.perbarui(baru);
              } else {
                await _repoFallback.simpan(baru);
                if (mounted) setState(() => _profilLocal = baru);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mahasiswa berhasil disimpan'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProfilViewModel? vm;
    try {
      vm = context.watch<ProfilViewModel>();
    } catch (_) {}

    final profil = vm?.profil ?? _profilLocal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        actions: [
          IconButton(
            tooltip: 'Edit Profil Mahasiswa',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _dialogEditProfil(context, profil, vm),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // Header & Identitas Mahasiswa Aktif
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceContainerHigh),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        _inisial(profil.nama),
                        style: const TextStyle(
                          color: AppTheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profil.nama,
                            key: const Key('label_profil_nama'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NIM: ${profil.nim}',
                            key: const Key('label_profil_nim'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _BadgePill(label: profil.kelas),
                              _BadgePill(label: profil.semester),
                              _BadgePill(label: profil.prodi),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            size: 16,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              profil.institusi,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Profil'),
                      onPressed: () => _dialogEditProfil(context, profil, vm),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                '• jadwal (id, kode, nama, hari, mulai, selesai, ruang, dosen, sks, kelas)\n'
                '• kategori (id, nama, warna)\n'
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
                '• Manajemen Jadwal Kuliah: tambah mata kuliah & kurangi/hapus jadwal\n'
                '• Profil Mahasiswa interaktif (Nama, NIM, Kelas, Semester, Prodi)\n'
                '• Deteksi Cerdas Perkuliahan Aktif ("Catat Sekarang") sesuai jadwal\n'
                '• Pencarian teks instan (judul, isi, topik, mata kuliah)\n'
                '• Pengurutan catatan (Terbaru ↔ Terlama)\n'
                '• Filter multi-kategori dan penanda favorit permanen di SQLite\n'
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

  static String _inisial(String nama) {
    final kata = nama.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return 'U';
    if (kata.length == 1) return kata.first.substring(0, 1).toUpperCase();
    return '${kata[0][0]}${kata[1][0]}'.toUpperCase();
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  const _BadgePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSecondaryContainer,
        ),
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
