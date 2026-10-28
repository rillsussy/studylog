import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/catatan_viewmodel.dart';
import '../utils/format.dart';
import 'form_catatan_screen.dart';

class DetailCatatanScreen extends StatelessWidget {
  final int id;
  const DetailCatatanScreen({super.key, required this.id});

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: const Text('Catatan yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<CatatanViewModel>().hapus(id);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CatatanViewModel>().cariById(id);
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Catatan tidak ditemukan')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            tooltip: 'Ubah',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormCatatanScreen(catatan: c),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete),
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Chip(label: Text(c.mataKuliah)),
          const SizedBox(height: 8),
          Text(c.judul, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            formatTanggal(c.tanggal),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 32),
          SelectableText(c.isi),
        ],
      ),
    );
  }
}
