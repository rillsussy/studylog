import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/kategori_view_model.dart';
import 'detail_catatan_page.dart';
import 'form_catatan_page.dart';

class DaftarCatatanPage extends StatefulWidget {
  const DaftarCatatanPage({super.key});

  @override
  State<DaftarCatatanPage> createState() => _DaftarCatatanPageState();
}

class _DaftarCatatanPageState extends State<DaftarCatatanPage> {
  final _cariController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    final mataKuliah = context.watch<JadwalViewModel>().mataKuliahUnik;
    final kategoriVm = context.watch<KategoriViewModel>();
    final daftarKategori = kategoriVm.items;

    return Consumer<CatatanViewModel>(
      builder: (context, vm, _) {
        final items = vm.hasil;
        final total = vm.catatan.length;

        Widget body;
        if (vm.isLoading && items.isEmpty) {
          body = const Center(child: CircularProgressIndicator());
        } else if (vm.error != null) {
          body = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vm.error!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: vm.muatCatatan,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        } else if (items.isEmpty) {
          body = Center(
            child: Text(
              vm.adaFilter
                  ? 'Tidak ada catatan yang cocok'
                  : 'Belum ada catatan',
            ),
          );
        } else {
          body = ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = items[i];
              final kat = kategoriVm.cariById(c.kategoriId);
              final labelKat = kat != null ? ' • ${kat.nama}' : '';
              return ListTile(
                title: Text(c.judul),
                subtitle: Text(
                  '${c.mataKuliah}$labelKat • ${formatTanggal(c.tanggal)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: c.favorit ? 'Hapus favorit' : 'Tandai favorit',
                      icon: Icon(
                        c.favorit ? Icons.star : Icons.star_border,
                        color: c.favorit ? Colors.amber.shade700 : null,
                      ),
                      onPressed: () => vm.toggleFavorit(c),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailCatatanPage(id: c.id!),
                  ),
                ),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Catatan'),
            actions: [
              IconButton(
                key: const Key('tombol_urut'),
                tooltip: vm.urutTerbaru
                    ? 'Urutan: Terbaru (ketuk untuk Terlama)'
                    : 'Urutan: Terlama (ketuk untuk Terbaru)',
                icon: Icon(vm.urutTerbaru ? Icons.south : Icons.north),
                onPressed: () => vm.setUrutTerbaru(!vm.urutTerbaru),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  key: const Key('field_cari'),
                  controller: _cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari judul, mata kuliah, topik, atau isi...',
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
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Semua'),
                        selected: vm.filterJadwalId == null && !vm.hanyaFavorit,
                        onSelected: (_) {
                          vm.setHanyaFavorit(false);
                          vm.setFilterJadwal(null);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: const Key('chip_filter_favorit'),
                        avatar: const Icon(Icons.star, size: 16),
                        label: const Text('Favorit'),
                        selected: vm.hanyaFavorit,
                        onSelected: vm.setHanyaFavorit,
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
              if (daftarKategori.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final k in daftarKategori)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(k.nama),
                            selected: vm.filterKategoriId == k.id,
                            onSelected: (aktif) =>
                                vm.setFilterKategori(aktif ? k.id : null),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  vm.adaFilter
                      ? 'Menampilkan ${items.length} dari $total catatan '
                            '(${vm.urutTerbaru ? 'Terbaru' : 'Terlama'})'
                      : 'Total catatan: $total '
                            '(${vm.urutTerbaru ? 'Terbaru' : 'Terlama'})',
                  key: const Key('label_jumlah_catatan'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(child: body),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Catatan Baru',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormCatatanPage()),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
