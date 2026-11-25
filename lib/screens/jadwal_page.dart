import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jadwal.dart';
import '../theme/app_theme.dart';
import '../viewmodels/jadwal_view_model.dart';
import 'daftar_catatan_page.dart';
import 'form_catatan_page.dart';
import 'tentang_page.dart';

/// Halaman manajemen jadwal kuliah: menambah dan mengurangi (hapus) mata kuliah.
class JadwalPage extends StatefulWidget {
  final bool tampilkanNavBar;

  const JadwalPage({super.key, this.tampilkanNavBar = true});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final _tabIndex = 2; // Jadwal aktif

  void _dialogTambahJadwal(BuildContext context, JadwalViewModel vm) {
    final formKey = GlobalKey<FormState>();
    final namaC = TextEditingController();
    final kodeC = TextEditingController(text: 'IFB');
    final ruangC = TextEditingController();
    final dosenC = TextEditingController();
    final kelasC = TextEditingController(text: 'IFB5J');
    int hariPilihan = 1; // Senin
    int sksPilihan = 3;
    TimeOfDay mulaiTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay selesaiTime = const TimeOfDay(hour: 9, minute: 40);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String formatTime(TimeOfDay t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Tambah Mata Kuliah',
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
                    TextFormField(
                      key: const Key('field_jadwal_nama'),
                      controller: namaC,
                      decoration: const InputDecoration(
                        labelText: 'Nama Mata Kuliah *',
                        prefixIcon: Icon(Icons.menu_book),
                        hintText: 'Misal: Kecerdasan Buatan',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama mata kuliah wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('field_jadwal_kode'),
                            controller: kodeC,
                            decoration: const InputDecoration(
                              labelText: 'Kode MK',
                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: sksPilihan,
                            decoration: const InputDecoration(
                              labelText: 'SKS',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                            items: const [1, 2, 3, 4, 6]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text('$s SKS'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => sksPilihan = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: hariPilihan,
                      decoration: const InputDecoration(
                        labelText: 'Hari Kuliah',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: List.generate(7, (i) {
                        final h = i + 1;
                        return DropdownMenuItem(
                          value: h,
                          child: Text(Jadwal.namaHari[i]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => hariPilihan = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: mulaiTime,
                              );
                              if (picked != null) {
                                setDialogState(() => mulaiTime = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Mulai',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(formatTime(mulaiTime)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selesaiTime,
                              );
                              if (picked != null) {
                                setDialogState(() => selesaiTime = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Selesai',
                                prefixIcon: Icon(Icons.access_time_filled),
                              ),
                              child: Text(formatTime(selesaiTime)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('field_jadwal_ruang'),
                      controller: ruangC,
                      decoration: const InputDecoration(
                        labelText: 'Ruang Perkuliahan',
                        prefixIcon: Icon(Icons.room_outlined),
                        hintText: 'Misal: LAB B / Ruang 304',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('field_jadwal_dosen'),
                      controller: dosenC,
                      decoration: const InputDecoration(
                        labelText: 'Dosen Pengampu',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Misal: Dr. Ir. Hendra Saputra',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('field_jadwal_kelas'),
                      controller: kelasC,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        prefixIcon: Icon(Icons.group_outlined),
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
                key: const Key('tombol_simpan_jadwal'),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Simpan'),
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  final menitMulai = mulaiTime.hour * 60 + mulaiTime.minute;
                  final menitSelesai =
                      selesaiTime.hour * 60 + selesaiTime.minute;

                  if (menitSelesai <= menitMulai) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Jam selesai harus setelah jam mulai'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }

                  final baru = Jadwal(
                    hari: hariPilihan,
                    mulai: menitMulai,
                    selesai: menitSelesai,
                    kode: kodeC.text.trim().isEmpty ? 'IFB' : kodeC.text.trim(),
                    nama: namaC.text.trim(),
                    sks: sksPilihan,
                    kelas: kelasC.text.trim().isEmpty
                        ? 'IFB5J'
                        : kelasC.text.trim(),
                    ruang: ruangC.text.trim().isEmpty
                        ? 'Daring / TBA'
                        : ruangC.text.trim(),
                    dosen: dosenC.text.trim().isEmpty
                        ? 'Dosen Pengampu'
                        : dosenC.text.trim(),
                  );

                  await vm.tambahJadwal(baru);

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Mata kuliah "${baru.nama}" berhasil ditambahkan',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _konfirmasiHapusJadwal(
    BuildContext context,
    Jadwal j,
    JadwalViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Hapus Mata Kuliah?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${j.nama}" '
          '(${j.labelHari}, ${j.labelJam}) dari daftar perkuliahan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('tombol_konfirmasi_hapus_jadwal'),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              if (j.id != null) {
                await vm.hapusJadwal(j.id!);
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mata kuliah "${j.nama}" berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JadwalViewModel>();
    final items = vm.items;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.tampilkanNavBar,
        title: const Text('Jadwal Kuliah'),
        actions: [
          IconButton(
            key: const Key('tombol_tambah_jadwal_appbar'),
            tooltip: 'Tambah Mata Kuliah',
            icon: const Icon(Icons.add),
            onPressed: () => _dialogTambahJadwal(context, vm),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Jadwal Kuliah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ketuk tombol di bawah untuk menambah mata kuliah baru',
                    style: TextStyle(fontSize: 13, color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Mata Kuliah'),
                    onPressed: () => _dialogTambahJadwal(context, vm),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final j = items[i];
                final isToday = j.hari == DateTime.now().weekday;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isToday
                          ? AppTheme.primary.withValues(alpha: 0.5)
                          : AppTheme.surfaceContainerHigh,
                      width: isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.secondary,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppTheme.primaryContainer
                                    : AppTheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                j.labelHari.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? AppTheme.onPrimary
                                      : AppTheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${j.sks} SKS • ${j.kelas}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Tombol hapus mata kuliah
                            IconButton(
                              tooltip: 'Hapus Mata Kuliah',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppTheme.error,
                                size: 20,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _konfirmasiHapusJadwal(context, j, vm),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          j.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              j.labelJam,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.meeting_room_outlined,
                              size: 14,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                j.ruang,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppTheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                j.dosen,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              icon: const Icon(Icons.edit_note, size: 16),
                              label: const Text(
                                'Buat Catatan',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormCatatanPage(jadwal: j),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Tambah Mata Kuliah',
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
        onPressed: () => _dialogTambahJadwal(context, vm),
      ),
      bottomNavigationBar: widget.tampilkanNavBar
          ? NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) {
                if (i == _tabIndex) return;
                if (i == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DaftarCatatanPage(),
                    ),
                  );
                } else if (i == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TentangPage()),
                  );
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
            )
          : null,
    );
  }
}
