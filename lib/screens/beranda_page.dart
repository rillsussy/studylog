import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jadwal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/profil_view_model.dart';
import 'daftar_catatan_page.dart';
import 'form_catatan_page.dart';
import 'jadwal_page.dart';
import 'tentang_page.dart';

String _inisial(String nama) {
  final parts = nama.split(' ').where((w) => w.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  } else if (parts.isNotEmpty) {
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
  return 'MK';
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _tabIndex = 0;

  void _catat(BuildContext context, Jadwal j) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCatatanPage(jadwal: j)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jadwalVm = context.watch<JadwalViewModel>();
    final status = jadwalVm.status;
    final aktif = status.aktif;
    final mataKuliah = jadwalVm.mataKuliahUnik;
    final jadwalHariIni = jadwalVm.items
        .where((j) => j.hari == DateTime.now().weekday)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'StudyLog',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) {
              ProfilViewModel? pVm;
              try {
                pVm = ctx.watch<ProfilViewModel>();
              } catch (_) {}
              final kelas = pVm?.profil.kelas ?? 'IFB5J';
              final sem = pVm?.profil.semester ?? 'Sem 5';
              return Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kelas,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• $sem',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Cari Catatan',
            icon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DaftarCatatanPage()),
            ),
          ),
          IconButton(
            key: const Key('tombol_tentang'),
            tooltip: 'Tentang Aplikasi',
            icon: const Icon(
              Icons.info_outline,
              color: AppTheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TentangPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Greeting & Sub-header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTanggalSaja(DateTime.now()),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Universitas Mulia',
                style: TextStyle(fontSize: 13, color: AppTheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hero Section: Kuliah Berlangsung
          if (aktif != null)
            _KartuKuliahAktif(
              jadwal: aktif,
              segera: status.segeraDimulai,
              onCatat: () => _catat(context, aktif),
            )
          else
            _KartuTidakAdaKuliah(
              berikutnya: status.berikutnya,
              waktu: status.waktuBerikutnya,
            ),

          const SizedBox(height: 14),

          // Bento Ringkasan Akademik
          Consumer<CatatanViewModel>(
            builder: (context, vm, _) => _BentoRingkasanAkademik(
              totalCatatan: vm.catatan.length,
              totalMatkul: mataKuliah.length,
              jadwalHariIni: jadwalHariIni,
              jumlahFavorit: vm.jumlahFavorit,
            ),
          ),

          const SizedBox(height: 14),

          // Navigasi Cepat Utama (Placed high so always visible & hit-testable)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Catatan Baru'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormCatatanPage()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list, size: 18),
                  label: const Text('Lihat Daftar Catatan'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DaftarCatatanPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Actions: Catat Cepat Mata Kuliah (No Row to prevent overflow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catat Cepat Mata Kuliah',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Pilih kelas untuk membuat log materi baru secara instan',
                style: TextStyle(fontSize: 12, color: AppTheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ActionChips Grid (Preserve 8 ActionChip widgets for test stability)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final j in mataKuliah)
                ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: AppTheme.primaryFixed,
                    radius: 12,
                    child: Text(
                      _inisial(j.nama),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onPrimaryFixed,
                      ),
                    ),
                  ),
                  label: Text(
                    j.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => _catat(context, j),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Catat Kuliah',
        icon: const Icon(Icons.add),
        label: const Text('Catat Kuliah'),
        onPressed: () {
          if (aktif != null) {
            _catat(context, aktif);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormCatatanPage()),
            );
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) {
          setState(() => _tabIndex = i);
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DaftarCatatanPage()),
            ).then((_) {
              if (mounted) setState(() => _tabIndex = 0);
            });
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JadwalPage()),
            ).then((_) {
              if (mounted) setState(() => _tabIndex = 0);
            });
          } else if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TentangPage()),
            ).then((_) {
              if (mounted) setState(() => _tabIndex = 0);
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _KartuKuliahAktif extends StatelessWidget {
  final Jadwal jadwal;
  final bool segera;
  final VoidCallback onCatat;

  const _KartuKuliahAktif({
    required this.jadwal,
    required this.segera,
    required this.onCatat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppTheme.error, width: 4)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.error.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          segera ? 'SEGERA DIMULAI' : 'SEDANG BERLANGSUNG',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${jadwal.sks} SKS',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                jadwal.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    jadwal.labelJam,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 16,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    jadwal.ruang,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.secondaryContainer,
                      radius: 16,
                      child: Text(
                        _inisial(jadwal.dosen),
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
                          const Text(
                            'Dosen Pengampu',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondary,
                            ),
                          ),
                          Text(
                            jadwal.dosen,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  key: const Key('tombol_catat_sekarang'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.edit_square, size: 18),
                  label: const Text(
                    'Catat Sekarang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: onCatat,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuTidakAdaKuliah extends StatelessWidget {
  final Jadwal? berikutnya;
  final DateTime? waktu;

  const _KartuTidakAdaKuliah({this.berikutnya, this.waktu});

  @override
  Widget build(BuildContext context) {
    final b = berikutnya;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tidak ada perkuliahan saat ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (b != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berikutnya: ${b.nama}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${b.labelHari}, ${formatTanggalSaja(waktu!)} • ${b.labelJam} • ${b.ruang}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BentoRingkasanAkademik extends StatelessWidget {
  final int totalCatatan;
  final int totalMatkul;
  final int jadwalHariIni;
  final int jumlahFavorit;

  const _BentoRingkasanAkademik({
    required this.totalCatatan,
    required this.totalMatkul,
    required this.jadwalHariIni,
    required this.jumlahFavorit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Akademik',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              if (jumlahFavorit > 0)
                Text(
                  '$jumlahFavorit difavoritkan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ItemBento(
                  icon: Icons.notes,
                  angka: '$totalCatatan',
                  label: 'Catatan Tersimpan',
                  iconColor: AppTheme.primary,
                  iconBg: AppTheme.secondaryContainer,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppTheme.surfaceContainerHigh,
              ),
              Expanded(
                child: _ItemBento(
                  icon: Icons.library_books_outlined,
                  angka: '$totalMatkul',
                  label: 'Mata Kuliah Aktif',
                  iconColor: AppTheme.primary,
                  iconBg: AppTheme.secondaryContainer,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppTheme.surfaceContainerHigh,
              ),
              Expanded(
                child: _ItemBento(
                  icon: Icons.event_available_outlined,
                  angka: '$jadwalHariIni',
                  label: 'Jadwal Hari Ini',
                  iconColor: AppTheme.tertiary,
                  iconBg: AppTheme.tertiaryFixedDim.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemBento extends StatelessWidget {
  final IconData icon;
  final String angka;
  final String label;
  final Color iconColor;
  final Color iconBg;

  const _ItemBento({
    required this.icon,
    required this.angka,
    required this.label,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          angka,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.secondary,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
