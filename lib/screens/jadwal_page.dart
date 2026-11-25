import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jadwal.dart';
import '../viewmodels/jadwal_view_model.dart';
import 'daftar_catatan_page.dart';
import 'form_catatan_page.dart';
import 'tentang_page.dart';

/// Halaman manajemen jadwal kuliah dengan desain Google Material 3.
class JadwalPage extends StatefulWidget {
  final bool tampilkanNavBar;

  const JadwalPage({super.key, this.tampilkanNavBar = true});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final _tabIndex = 2; // Jadwal aktif

  void _dialogTambahJadwal(BuildContext context, JadwalViewModel vm) {
    final cs = Theme.of(context).colorScheme;
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
          final dialogCs = Theme.of(ctx).colorScheme;
          final dialogTt = Theme.of(ctx).textTheme;

          String formatTime(TimeOfDay t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

          return AlertDialog(
            icon: Icon(
              Icons.event_note_outlined,
              color: dialogCs.primary,
              size: 28,
            ),
            title: const Text('Tambah Mata Kuliah'),
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
                        prefixIcon: Icon(Icons.menu_book_outlined),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: sksPilihan,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'SKS',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            items: const [1, 2, 3, 4, 6]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      '$s SKS',
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Hari Kuliah',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
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
                            borderRadius: BorderRadius.circular(16),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 16,
                                    color: dialogCs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      formatTime(mulaiTime),
                                      style: dialogTt.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: dialogCs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      formatTime(selesaiTime),
                                      style: dialogTt.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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
                        prefixIcon: Icon(Icons.meeting_room_outlined),
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
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Simpan'),
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) return;
                  final menitMulai = mulaiTime.hour * 60 + mulaiTime.minute;
                  final menitSelesai =
                      selesaiTime.hour * 60 + selesaiTime.minute;

                  if (menitSelesai <= menitMulai) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Jam selesai harus setelah jam mulai',
                        ),
                        backgroundColor: cs.error,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 28),
        title: const Text('Hapus Mata Kuliah?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${j.nama}" '
          '(${j.labelHari}, ${j.labelJam}) dari daftar perkuliahan?',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('tombol_konfirmasi_hapus_jadwal'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () async {
              if (j.id != null) {
                await vm.hapusJadwal(j.id!);
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mata kuliah "${j.nama}" berhasil dihapus'),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.tampilkanNavBar,
        title: const Text('Jadwal Kuliah'),
        actions: [
          IconButton.filledTonal(
            key: const Key('tombol_tambah_jadwal_appbar'),
            tooltip: 'Tambah Mata Kuliah',
            icon: const Icon(Icons.add),
            onPressed: () => _dialogTambahJadwal(context, vm),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 36,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Jadwal Kuliah',
                      textAlign: TextAlign.center,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ketuk tombol di bawah untuk menambah mata kuliah baru',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Mata Kuliah'),
                      onPressed: () => _dialogTambahJadwal(context, vm),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final j = items[i];
                final isToday = j.hari == DateTime.now().weekday;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: isToday
                      ? cs.primaryContainer.withValues(alpha: 0.45)
                      : cs.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? cs.primaryContainer
                                          : cs.secondaryContainer,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      j.labelHari.toUpperCase(),
                                      style: tt.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                        color: isToday
                                            ? cs.onPrimaryContainer
                                            : cs.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      '${j.sks} SKS • ${j.kelas}',
                                      style: tt.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Hapus Mata Kuliah',
                              style: IconButton.styleFrom(
                                backgroundColor: cs.errorContainer.withValues(
                                  alpha: 0.55,
                                ),
                                foregroundColor: cs.error,
                              ),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                  _konfirmasiHapusJadwal(context, j, vm),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          j.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 15,
                              color: isToday ? cs.primary : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              j.labelJam,
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isToday ? cs.primary : cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 15,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                j.ruang,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 15,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                j.dosen,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Buat Catatan'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormCatatanPage(jadwal: j),
                                ),
                              );
                            },
                          ),
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
