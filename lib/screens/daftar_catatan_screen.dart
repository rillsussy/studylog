import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/format.dart';
import '../viewmodels/catatan_viewmodel.dart';
import '../viewmodels/jadwal_viewmodel.dart';
import 'detail_catatan_screen.dart';
import 'form_catatan_screen.dart';

class DaftarCatatanScreen extends StatefulWidget {
  const DaftarCatatanScreen({super.key});

  @override
  State<DaftarCatatanScreen> createState() => _DaftarCatatanScreenState();
}

class _DaftarCatatanScreenState extends State<DaftarCatatanScreen> {
  final _cariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mulai dengan daftar tanpa filter setiap kali layar dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CatatanViewModel>().resetFilter();
    });
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatatanViewModel>();
    final mataKuliah = context.watch<JadwalViewModel>().mataKuliahUnik;
    final items = vm.hasil;

    Widget body;
    if (vm.memuat && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.galat != null) {
      body = Center(child: Text(vm.galat!));
    } else if (items.isEmpty) {
      body = Center(
        child: Text(
          vm.adaFilter ? 'Tidak ada catatan yang cocok' : 'Belum ada catatan',
        ),
      );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('field_cari'),
              controller: _cariController,
              decoration: InputDecoration(
                hintText: 'Cari judul, mata kuliah, atau isi...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _cariController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cariController.clear();
                          vm.setKataKunci('');
                        },
                      ),
              ),
              onChanged: vm.setKataKunci,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: vm.filterJadwalId == null,
                    onSelected: (_) => vm.setFilterJadwal(null),
                  ),
                ),
                for (final j in mataKuliah)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(j.nama),
                      selected: vm.filterJadwalId == j.id,
                      onSelected: (_) => vm.setFilterJadwal(j.id),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
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
