import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database_helper.dart';
import '../data/profil_repository.dart';
import '../models/profil.dart';
import '../viewmodels/profil_view_model.dart';

/// Halaman Profil Mahasiswa dengan desain Google Material 3 (Material You).
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
    final cs = Theme.of(context).colorScheme;
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
        icon: Icon(Icons.badge_outlined, color: cs.primary, size: 28),
        title: const Text('Edit Data Profil'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Perbarui identitas mahasiswa yang aktif menggunakan aplikasi:',
                  style: Theme.of(ctx).textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('field_profil_nama'),
                  controller: namaC,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    prefixIcon: Icon(Icons.person_outline),
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
                    prefixIcon: Icon(Icons.pin_outlined),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        key: const Key('field_profil_semester'),
                        controller: semesterC,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
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
                    prefixIcon: Icon(Icons.account_balance_outlined),
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
            icon: const Icon(Icons.save_outlined, size: 18),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Edit Profil Mahasiswa',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _dialogEditProfil(context, profil, vm),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Material 3 Hero Profile Surface Container
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                    child: Text(
                      _inisial(profil.nama),
                      style: tt.headlineMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profil.nama,
                    key: const Key('label_profil_nama'),
                    textAlign: TextAlign.center,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: ${profil.nim}',
                    key: const Key('label_profil_nim'),
                    textAlign: TextAlign.center,
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _M3Badge(label: profil.kelas),
                      _M3Badge(label: profil.semester),
                      _M3Badge(label: profil.prodi),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profil'),
                    onPressed: () => _dialogEditProfil(context, profil, vm),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grouped M3 Informasi Akademik Section
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 10),
            child: Text(
              'Informasi Akademik',
              style: tt.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: cs.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Nama Lengkap',
                  value: profil.nama,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
                const Divider(indent: 64, endIndent: 16),
                _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Nomor Induk Mahasiswa (NIM)',
                  value: profil.nim,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
                const Divider(indent: 64, endIndent: 16),
                _InfoTile(
                  icon: Icons.class_outlined,
                  label: 'Kelas',
                  value: profil.kelas,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
                const Divider(indent: 64, endIndent: 16),
                _InfoTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Semester',
                  value: profil.semester,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
                const Divider(indent: 64, endIndent: 16),
                _InfoTile(
                  icon: Icons.school_outlined,
                  label: 'Program Studi',
                  value: profil.prodi,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
                const Divider(indent: 64, endIndent: 16),
                _InfoTile(
                  icon: Icons.account_balance_outlined,
                  label: 'Institusi / Kampus',
                  value: profil.institusi,
                  onTap: () => _dialogEditProfil(context, profil, vm),
                ),
              ],
            ),
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

class _M3Badge extends StatelessWidget {
  final String label;
  const _M3Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: cs.secondaryContainer.withValues(alpha: 0.7),
        foregroundColor: cs.onSecondaryContainer,
        radius: 20,
        child: Icon(icon, size: 20),
      ),
      title: Text(
        label,
        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tt.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
