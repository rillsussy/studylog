import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../models/jadwal.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_viewmodel.dart';
import '../viewmodels/jadwal_viewmodel.dart';

/// Form tambah / ubah catatan.
class FormCatatanScreen extends StatefulWidget {
  /// Jika diisi, form berada pada mode ubah.
  final Catatan? catatan;

  /// Jika diisi (mode "Catat Sekarang"), mata kuliah langsung terpilih
  /// dan kursor langsung berada di kolom isi catatan.
  final Jadwal? jadwal;

  const FormCatatanScreen({super.key, this.catatan, this.jadwal});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  /// Nilai dropdown untuk mata kuliah di luar jadwal.
  static const _lainnya = -1;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mataKuliahController;
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;

  int? _jadwalId;
  bool _menyimpan = false;

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
    _isiController = TextEditingController(text: c?.isi ?? '');

    if (j != null) {
      _jadwalId = j.id;
    } else if (c != null) {
      _jadwalId = c.jadwalId ?? _lainnya;
    }
  }

  @override
  void dispose() {
    _mataKuliahController.dispose();
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  String? _wajibDiisi(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  Future<void> _simpan() async {
    if (_menyimpan || !_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    final vm = context.read<CatatanViewModel>();
    final jadwal = context.read<JadwalViewModel>().cariById(_jadwalId);
    final data = Catatan(
      id: widget.catatan?.id,
      mataKuliah: jadwal?.nama ?? _mataKuliahController.text.trim(),
      judul: _judulController.text.trim(),
      isi: _isiController.text.trim(),
      tanggal: widget.catatan?.tanggal ?? DateTime.now(),
      jadwalId: jadwal?.id,
    );
    try {
      if (_modeUbah) {
        await vm.ubah(data);
      } else {
        await vm.tambah(data);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_modeUbah ? 'Catatan diperbarui' : 'Catatan disimpan'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final daftarJadwal = context.watch<JadwalViewModel>().mataKuliahUnik;
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
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
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
