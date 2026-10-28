import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/catatan_viewmodel.dart';
import '../utils/format.dart';
import 'detail_catatan_screen.dart';
import 'form_catatan_screen.dart';

class DaftarCatatanScreen extends StatelessWidget {
  const DaftarCatatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatatanViewModel>();
    final items = vm.items;
    Widget body;
    if (vm.memuat && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.galat != null) {
      body = Center(child: Text(vm.galat!));
    } else if (items.isEmpty) {
      body = const Center(child: Text('Belum ada catatan'));
    } else {
      body = ListView.separated(
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
              MaterialPageRoute(builder: (_) => DetailCatatanScreen(id: c.id!)),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Catatan')),
      body: body,
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
