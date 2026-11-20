import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../models/jadwal.dart';
import '../theme/app_theme.dart';
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done,
                  size: 16,
                  color: AppTheme.tertiaryContainer,
                ),
                SizedBox(width: 4),
                Text(
                  'Tersimpan di Cloud',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Course Banner Card
                if (_modeCepat && widget.jadwal != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceContainerHigh),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.primaryContainer,
                              width: 4,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'KULIAH AKTIF',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Smt 5 • ${widget.jadwal!.sks} SKS',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.jadwal!.nama,
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
                                        Icons.meeting_room,
                                        size: 14,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.jadwal!.ruang,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.jadwal!.dosen,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.swap_horiz,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: const Key('dropdown_mata_kuliah'),
                    initialValue: _jadwalId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Mata Kuliah',
                      prefixIcon: Icon(Icons.school_outlined),
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
                      decoration: const InputDecoration(
                        labelText: 'Nama Mata Kuliah',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                      validator: (v) => _wajibDiisi(v, 'Nama mata kuliah'),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],

                // Dropdown Kategori
                if (daftarKategori.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    key: const Key('dropdown_kategori'),
                    initialValue: kategoriAktif,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kategori / Tag',
                      prefixIcon: Icon(Icons.label_outlined),
                    ),
                    items: [
                      for (final k in daftarKategori)
                        DropdownMenuItem(
                          value: k.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(k.warna),
                                radius: 6,
                              ),
                              const SizedBox(width: 8),
                              Text(k.nama),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _kategoriId = v),
                  ),
                  const SizedBox(height: 12),
                ],

                // Note Title Field
                TextFormField(
                  key: const Key('field_judul'),
                  controller: _judulController,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Judul Catatan',
                    hintText: 'Judul catatan perkuliahan...',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Judul'),
                ),
                const SizedBox(height: 12),

                // Topic Field
                TextFormField(
                  key: const Key('field_topik'),
                  controller: _topikController,
                  decoration: const InputDecoration(
                    labelText: 'Topik (opsional, min. 3 karakter)',
                    hintText: 'Contoh: Normalisasi 3NF & BCNF',
                    prefixIcon: Icon(Icons.tag),
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
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    hintText:
                        'Lanjutkan mengetik poin pembahasan kuliah di sini...',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 120),
                      child: Icon(Icons.notes),
                    ),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Isi catatan'),
                ),

                const SizedBox(height: 16),

                // Word & Character Counter row
                Row(
                  children: [
                    const Icon(
                      Icons.text_fields,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_jumlahKata kata • $_jumlahKarakter karakter',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // High-Contrast Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _tersimpan
                          ? Colors.green
                          : AppTheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(
                      _tersimpan ? Icons.check_circle : Icons.save,
                      size: 20,
                    ),
                    label: Text(
                      _menyimpan
                          ? 'Menyimpan...'
                          : (_tersimpan ? 'Tersimpan' : 'Simpan'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
