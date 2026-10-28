import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/catatan_store.dart';
import '../utils/format.dart';
import 'detail_catatan_screen.dart';
import 'form_catatan_screen.dart';

class DaftarCatatanScreen extends StatelessWidget {
  const DaftarCatatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CatatanStore>().items;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Catatan')),
      body: items.isEmpty
          ? const Center(child: Text('Belum ada catatan'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = items[i];
                return ListTile(
                  title: Text(c.judul),
                  subtitle: Text('${c.mataKuliah} • ${formatTanggal(c.tanggal)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailCatatanScreen(id: c.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Catatan Baru',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormCatatanScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
