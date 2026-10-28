import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/catatan_viewmodel.dart';
import 'daftar_catatan_screen.dart';
import 'form_catatan_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlah = context.watch<CatatanViewModel>().items.length;
    return Scaffold(
      appBar: AppBar(title: const Text('StudyLog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Total Catatan'),
              trailing: Text(
                '$jumlah',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Catatan Baru'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormCatatanScreen()),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('Lihat Daftar Catatan'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DaftarCatatanScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
