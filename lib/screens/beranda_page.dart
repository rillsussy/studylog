import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jadwal.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final jadwalVm = context.watch<JadwalViewModel>();
    final status = jadwalVm.status;
    final aktif = status.aktif;
    final mataKuliah = jadwalVm.mataKuliahUnik;
    final jadwalHariIni = jadwalVm.items
        .where((j) => j.hari == DateTime.now().weekday)
        .length;

    final dashboardTab = Scaffold(
      key: const ValueKey('tab_dashboard'),
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 20,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'StudyLog',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari Catatan',
            icon: Icon(Icons.search, color: cs.onSurfaceVariant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DaftarCatatanPage()),
            ),
          ),
          IconButton(
            key: const Key('tombol_tentang'),
            tooltip: 'Tentang Aplikasi',
            icon: Icon(Icons.info_outline, color: cs.onSurfaceVariant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TentangPage()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 108),
        children: [
          // Greeting & Sub-header dengan pill kelas/semester responsif
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTanggalSaja(DateTime.now()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Universitas Mulia',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 0,
                child: Builder(
                  builder: (ctx) {
                    ProfilViewModel? pVm;
                    try {
                      pVm = ctx.watch<ProfilViewModel>();
                    } catch (_) {}
                    final kelas = pVm?.profil.kelas ?? 'IFB5J';
                    final sem = pVm?.profil.semester ?? 'Sem 5';
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 168),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$kelas • $sem',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Section: Kuliah Berlangsung / Berikutnya
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

          const SizedBox(height: 16),

          // Bento Ringkasan Akademik
          Consumer<CatatanViewModel>(
            builder: (context, vm, _) => _BentoRingkasanAkademik(
              totalCatatan: vm.catatan.length,
              totalMatkul: mataKuliah.length,
              jadwalHariIni: jadwalHariIni,
              jumlahFavorit: vm.jumlahFavorit,
            ),
          ),

          const SizedBox(height: 16),

          // Navigasi Cepat Utama (Equal-height M3 tonal action cards)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TombolAksiTonal(
                    icon: Icons.edit_note_rounded,
                    label: 'Catatan Baru',
                    containerColor: cs.primaryContainer,
                    contentColor: cs.onPrimaryContainer,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormCatatanPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TombolAksiTonal(
                    icon: Icons.menu_book_rounded,
                    label: 'Lihat Daftar Catatan',
                    containerColor: cs.secondaryContainer,
                    contentColor: cs.onSecondaryContainer,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DaftarCatatanPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Quick Actions: Catat Cepat Mata Kuliah
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catat Cepat Mata Kuliah',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pilih kelas untuk membuat log materi baru secara instan',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ActionChips Grid (Preserve 8 ActionChip widgets for test stability)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final j in mataKuliah)
                ActionChip(
                  backgroundColor: cs.surfaceContainerLow,
                  side: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  avatar: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    radius: 12,
                    child: Text(
                      _inisial(j.nama),
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  label: Text(
                    j.nama,
                    style: tt.labelLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
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
    );

    final Widget tabContent = switch (_tabIndex) {
      1 => const DaftarCatatanPage(
        key: ValueKey('tab_catatan'),
        tampilkanNavBar: false,
      ),
      2 => const JadwalPage(
        key: ValueKey('tab_jadwal'),
        tampilkanNavBar: false,
      ),
      3 => const TentangPage(key: ValueKey('tab_profil')),
      _ => dashboardTab,
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: tabContent,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        animationDuration: const Duration(milliseconds: 350),
        onDestinationSelected: (i) {
          if (i == _tabIndex) return;
          setState(() => _tabIndex = i);
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

class _TombolAksiTonal extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color containerColor;
  final Color contentColor;
  final VoidCallback onTap;

  const _TombolAksiTonal({
    required this.icon,
    required this.label,
    required this.containerColor,
    required this.contentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: contentColor),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelLarge?.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          segera ? 'SEGERA DIMULAI' : 'SEDANG BERLANGSUNG',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onErrorContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${jadwal.sks} SKS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            jadwal.nama,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onPrimaryContainer,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    jadwal.labelJam,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 16,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    jadwal.ruang,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  radius: 16,
                  child: Text(
                    _inisial(jadwal.dosen),
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosen Pengampu',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        jadwal.dosen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              key: const Key('tombol_catat_sekarang'),
              icon: const Icon(Icons.edit_square, size: 18),
              label: const Text('Catat Sekarang'),
              onPressed: onCatat,
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final b = berikutnya;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: cs.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tidak ada perkuliahan saat ini',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (b != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berikutnya: ${b.nama}',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${b.labelHari}, ${formatTanggalSaja(waktu!)} • ${b.labelJam} • ${b.ruang}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ],
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ringkasan Akademik',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (jumlahFavorit > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$jumlahFavorit difavoritkan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ItemBento(
                    icon: Icons.notes_rounded,
                    angka: '$totalCatatan',
                    label: 'Catatan\nTersimpan',
                    containerColor: cs.primaryContainer,
                    contentColor: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ItemBento(
                    icon: Icons.library_books_outlined,
                    angka: '$totalMatkul',
                    label: 'Mata Kuliah\nAktif',
                    containerColor: cs.secondaryContainer,
                    contentColor: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ItemBento(
                    icon: Icons.event_available_outlined,
                    angka: '$jadwalHariIni',
                    label: 'Jadwal\nHari Ini',
                    containerColor: cs.tertiaryContainer,
                    contentColor: cs.onTertiaryContainer,
                  ),
                ),
              ],
            ),
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
  final Color containerColor;
  final Color contentColor;

  const _ItemBento({
    required this.icon,
    required this.angka,
    required this.label,
    required this.containerColor,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: contentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            angka,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: contentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.labelSmall?.copyWith(
              color: contentColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
