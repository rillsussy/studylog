import 'package:flutter/material.dart';

/// Milestone 01: form catatan dengan validasi dan state lokal.
class FormCatatanScreen extends StatefulWidget {
  const FormCatatanScreen({super.key});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mataKuliahController = TextEditingController();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  String? _hasilMataKuliah;
  String? _hasilJudul;
  String? _hasilIsi;

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

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _hasilMataKuliah = _mataKuliahController.text.trim();
      _hasilJudul = _judulController.text.trim();
      _hasilIsi = _isiController.text.trim();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  void _reset() {
    _formKey.currentState!.reset();
    _mataKuliahController.clear();
    _judulController.clear();
    _isiController.clear();
    setState(() {
      _hasilMataKuliah = null;
      _hasilJudul = null;
      _hasilIsi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StudyLog - Catatan Baru')),
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
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _wajibDiisi(v, 'Isi catatan'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _simpan,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
                if (_hasilJudul != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      title: Text(_hasilJudul!),
                      subtitle: Text('$_hasilMataKuliah\n\n$_hasilIsi'),
                      isThreeLine: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
