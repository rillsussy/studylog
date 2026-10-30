import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../models/jadwal.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/kategori_view_model.dart';

/// Form tambah / ubah catatan.
class FormCatatanPage extends StatefulWidget {
  /// Jika diisi, form berada pada mode ubah.
  final Catatan? catatan;

  /// Jika diisi (mode "Catat Sekarang"), mata kuliah langsung terpilih
  /// dan kursor langsung berada di kolom isi catatan.
  final Jadwal? jadwal;

  const FormCatatanPage({super.key, this.catatan, this.jadwal});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  /// Nilai dropdown untuk mata kuliah di luar jadwal.
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
    final j = widget.jadwal;

    return Scaffold(
      appBar: AppBar(title: Text(_modeUbah ? 'Ubah Catatan' : 'Catatan Baru')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_modeCepat)
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(j!.nama),
                      subtitle: Text('${j.labelJam} • ${j.ruang}\n${j.dosen}'),
                      isThreeLine: true,
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: const Key('dropdown_mata_kuliah'),
                    initialValue: _jadwalId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Mata Kuliah',
                      border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _wajibDiisi(v, 'Nama mata kuliah'),
                    ),
                  ],
                ],
                if (daftarKategori.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: const Key('dropdown_kategori'),
                    initialValue: kategoriAktif,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kategori / Tag',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final k in daftarKategori)
                        DropdownMenuItem(value: k.id, child: Text(k.nama)),
                    ],
                    onChanged: (v) => setState(() => _kategoriId = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_judul'),
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Catatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Judul'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_topik'),
                  controller: _topikController,
                  decoration: const InputDecoration(
                    labelText: 'Topik (opsional, min. 3 karakter)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validasiTopik,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('field_isi'),
                  controller: _isiController,
                  autofocus: _modeCepat,
                  minLines: 8,
                  maxLines: 20,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Isi catatan'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: _tersimpan
                      ? FilledButton.styleFrom(backgroundColor: Colors.green)
                      : null,
                  icon: Icon(_tersimpan ? Icons.check_circle : Icons.save),
                  label: Text(
                    _menyimpan
                        ? 'Menyimpan...'
                        : (_tersimpan ? 'Tersimpan' : 'Simpan'),
                  ),
                  onPressed: _menyimpan ? null : _simpan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
