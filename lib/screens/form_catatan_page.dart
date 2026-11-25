import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../models/jadwal.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/kategori_view_model.dart';

/// Form tambah / ubah catatan sesuai spesifikasi Catat Cepat.
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;
  final Jadwal? jadwal;

  const FormCatatanPage({super.key, this.catatan, this.jadwal});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  static const _lainnya = -1;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mataKuliahController;
  late final TextEditingController _judulController;
  late final TextEditingController _topikController;
  late final TextEditingController _isiController;

  int? _jadwalId;
  int? _kategoriId;
  bool _menyimpan = false;
  bool _tersimpan = false;

  bool get _modeUbah => widget.catatan != null;
  bool get _modeCepat => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    final c = widget.catatan;
    final j = widget.jadwal;
    _mataKuliahController = TextEditingController(text: c?.mataKuliah ?? '');
    _judulController = TextEditingController(
      text:
          c?.judul ??
          (j != null ? 'Pertemuan ${formatTanggalSaja(DateTime.now())}' : ''),
    );
    _topikController = TextEditingController(text: c?.topik ?? '');
    _isiController = TextEditingController(text: c?.isi ?? '');

    if (j != null) {
      _jadwalId = j.id;
    } else if (c != null) {
      _jadwalId = c.jadwalId ?? _lainnya;
    }
    _kategoriId = c?.kategoriId;

    _isiController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mataKuliahController.dispose();
    _judulController.dispose();
    _topikController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  String? _wajibDiisi(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  String? _validasiTopik(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 3) {
      return 'Topik minimal 3 karakter';
    }
    return null;
  }

  int get _jumlahKata {
    final t = _isiController.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  int get _jumlahKarakter => _isiController.text.length;

  InputDecoration _m3InputDecoration(
    ColorScheme cs, {
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
    );
  }

  Future<void> _simpan() async {
    if (_menyimpan || !_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final vm = context.read<CatatanViewModel>();
    final jadwal = context.read<JadwalViewModel>().cariById(_jadwalId);
    final kategoriVm = context.read<KategoriViewModel>();
    final kategoriId = _kategoriId ?? kategoriVm.defaultKategori?.id;

    final data = Catatan(
      id: widget.catatan?.id,
      mataKuliah: jadwal?.nama ?? _mataKuliahController.text.trim(),
      judul: _judulController.text.trim(),
      topik: _topikController.text.trim(),
      isi: _isiController.text.trim(),
      tanggal: widget.catatan?.tanggal ?? DateTime.now(),
      favorit: widget.catatan?.favorit ?? false,
      jadwalId: jadwal?.id,
      kategoriId: kategoriId,
    );
    try {
      if (_modeUbah) {
        await vm.ubahCatatan(data);
      } else {
        await vm.tambahCatatan(data);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      return;
    }
    if (!mounted) return;
    setState(() => _tersimpan = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_modeUbah ? 'Catatan diperbarui' : 'Catatan disimpan'),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final daftarJadwal = context.watch<JadwalViewModel>().mataKuliahUnik;
    final kategoriVm = context.watch<KategoriViewModel>();
    final daftarKategori = kategoriVm.items;
    final kategoriAktif = _kategoriId ?? kategoriVm.defaultKategori?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modeUbah
              ? 'Ubah Catatan'
              : (_modeCepat ? 'Catat Cepat' : 'Catatan Baru'),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  size: 15,
                  color: cs.onTertiaryContainer,
                ),
                const SizedBox(width: 5),
                Text(
                  'Tersinkron',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tonal Active-Course Banner
                if (_modeCepat && widget.jadwal != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'KULIAH AKTIF',
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.jadwal!.sks} SKS • ${widget.jadwal!.labelJam}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onPrimaryContainer.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.jadwal!.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 15,
                              color: cs.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.jadwal!.ruang,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.person_outline,
                              size: 15,
                              color: cs.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.jadwal!.dosen,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onPrimaryContainer.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: const Key('dropdown_mata_kuliah'),
                    initialValue: _jadwalId,
                    isExpanded: true,
                    decoration: _m3InputDecoration(
                      cs,
                      labelText: 'Mata Kuliah',
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                    items: [
                      for (final jd in daftarJadwal)
                        DropdownMenuItem(
                          value: jd.id,
                          child: Text(jd.nama, overflow: TextOverflow.ellipsis),
                        ),
                      const DropdownMenuItem(
                        value: _lainnya,
                        child: Text('Lainnya (ketik manual)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _jadwalId = v),
                    validator: (v) =>
                        v == null ? 'Mata kuliah wajib diisi' : null,
                  ),
                  if (_jadwalId == _lainnya) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('field_mata_kuliah'),
                      controller: _mataKuliahController,
                      decoration: _m3InputDecoration(
                        cs,
                        labelText: 'Nama Mata Kuliah',
                        prefixIcon: const Icon(Icons.book_outlined),
                      ),
                      validator: (v) => _wajibDiisi(v, 'Nama mata kuliah'),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],

                // M3 Tonal Category ChoiceChips
                if (daftarKategori.isNotEmpty) ...[
                  Text(
                    'Kategori',
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in daftarKategori)
                        ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: Color(k.warna),
                            radius: 5,
                          ),
                          label: Text(k.nama),
                          selected: kategoriAktif == k.id,
                          side: BorderSide.none,
                          backgroundColor: cs.surfaceContainerLow,
                          selectedColor: cs.secondaryContainer,
                          shape: const StadiumBorder(),
                          onSelected: (_) => setState(() => _kategoriId = k.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Note Title Field
                TextFormField(
                  key: const Key('field_judul'),
                  controller: _judulController,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  decoration: _m3InputDecoration(
                    cs,
                    labelText: 'Judul Catatan',
                    hintText: 'Judul catatan perkuliahan...',
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Judul'),
                ),
                const SizedBox(height: 12),

                // Topic Field
                TextFormField(
                  key: const Key('field_topik'),
                  controller: _topikController,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  decoration: _m3InputDecoration(
                    cs,
                    labelText: 'Topik (opsional, min. 3 karakter)',
                    hintText: 'Contoh: Normalisasi 3NF & BCNF',
                    prefixIcon: const Icon(Icons.tag),
                  ),
                  validator: _validasiTopik,
                ),
                const SizedBox(height: 12),

                // Expansive Writing Area
                TextFormField(
                  key: const Key('field_isi'),
                  controller: _isiController,
                  autofocus: _modeCepat,
                  minLines: 8,
                  maxLines: 22,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: tt.bodyLarge?.copyWith(
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                  decoration: _m3InputDecoration(
                    cs,
                    labelText: 'Isi Catatan',
                    hintText:
                        'Lanjutkan mengetik poin pembahasan kuliah di sini...',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 120),
                      child: Icon(Icons.notes),
                    ),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Isi catatan'),
                ),

                const SizedBox(height: 12),

                // Word & Character Counter row
                Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$_jumlahKata kata • $_jumlahKarakter karakter',
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Prominent M3 FilledButton inside scrollable body
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _tersimpan ? cs.tertiary : cs.primary,
                      foregroundColor: _tersimpan
                          ? cs.onTertiary
                          : cs.onPrimary,
                      shape: const StadiumBorder(),
                    ),
                    icon: Icon(
                      _tersimpan
                          ? Icons.check_circle_outline
                          : Icons.save_outlined,
                      size: 20,
                    ),
                    label: Text(
                      _menyimpan
                          ? 'Menyimpan...'
                          : (_tersimpan ? 'Tersimpan' : 'Simpan'),
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _tersimpan ? cs.onTertiary : cs.onPrimary,
                      ),
                    ),
                    onPressed: _menyimpan ? null : _simpan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
