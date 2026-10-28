import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../viewmodels/catatan_viewmodel.dart';

/// Form tambah / ubah catatan.
class FormCatatanScreen extends StatefulWidget {
  /// Jika diisi, form berada pada mode ubah.
  final Catatan? catatan;

  const FormCatatanScreen({super.key, this.catatan});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mataKuliahController;
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;

  bool _menyimpan = false;

  bool get _modeUbah => widget.catatan != null;

  @override
  void initState() {
    super.initState();
    final c = widget.catatan;
    _mataKuliahController = TextEditingController(text: c?.mataKuliah ?? '');
    _judulController = TextEditingController(text: c?.judul ?? '');
    _isiController = TextEditingController(text: c?.isi ?? '');
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
    final data = Catatan(
      id: widget.catatan?.id,
      mataKuliah: _mataKuliahController.text.trim(),
      judul: _judulController.text.trim(),
      isi: _isiController.text.trim(),
      tanggal: widget.catatan?.tanggal ?? DateTime.now(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeUbah ? 'Ubah Catatan' : 'Catatan Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('field_mata_kuliah'),
                  controller: _mataKuliahController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Mata kuliah'),
                ),
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
                  minLines: 6,
                  maxLines: 12,
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
