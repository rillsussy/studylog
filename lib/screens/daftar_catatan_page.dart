import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/kategori_view_model.dart';
import 'detail_catatan_page.dart';
import 'form_catatan_page.dart';
import 'jadwal_page.dart';
import 'tentang_page.dart';

class DaftarCatatanPage extends StatefulWidget {
  final bool tampilkanNavBar;

  const DaftarCatatanPage({super.key, this.tampilkanNavBar = true});

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
    final jadwalVm = context.watch<JadwalViewModel>();
    final mataKuliah = jadwalVm.mataKuliahUnik;
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: vm.muatCatatan,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        } else if (items.isEmpty) {
          body = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.note_alt_outlined,
                    size: 40,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  vm.adaFilter
                      ? 'Tidak ada catatan yang cocok'
                      : 'Belum ada catatan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else {
          body = ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = items[i];
              final kat = kategoriVm.cariById(c.kategoriId);
              final snippet = c.isi.replaceAll('\n', ' ').trim();

              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.surfaceContainerHigh),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: kat != null
                            ? Color(kat.warna)
                            : AppTheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryContainer.withValues(
                                    alpha: 0.6,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.storage,
                                      size: 12,
                                      color: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        c.mataKuliah,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              AppTheme.onSecondaryFixedVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatTanggal(c.tanggal),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.judul,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (snippet.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (c.topik.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#${c.topik.trim()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            if (kat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(kat.warna)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  kat.nama,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(kat.warna),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: c.favorit
                              ? 'Hapus favorit'
                              : 'Tandai favorit',
                          icon: Icon(
                            c.favorit ? Icons.star : Icons.star_border,
                            color: c.favorit
                                ? Colors.amber.shade700
                                : AppTheme.outline,
                          ),
                          onPressed: () => vm.toggleFavorit(c),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.outlineVariant,
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailCatatanPage(id: c.id!),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: widget.tampilkanNavBar,
            title: const Text('Catatan Kuliah'),
            actions: [
              IconButton(
                key: const Key('tombol_urut'),
                tooltip: vm.urutTerbaru
                    ? 'Urutan: Terbaru (ketuk untuk Terlama)'
                    : 'Urutan: Terlama (ketuk untuk Terbaru)',
                icon: Icon(vm.urutTerbaru ? Icons.south : Icons.north),
                onPressed: () => vm.setUrutTerbaru(!vm.urutTerbaru),
              ),
              IconButton(
                tooltip: 'Filter Lanjutan',
                icon: const Icon(Icons.tune),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // M3 Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    key: const Key('field_cari'),
                    controller: _cariController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, mata kuliah, atau isi...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.onSurfaceVariant,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      suffixIcon: _cariController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _cariController.clear();
                                vm.setKataKunci('');
                              },
                            ),
                    ),
                    onChanged: vm.setKataKunci,
                  ),
                ),
              ),

              // Filter Chips Carousel
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('Semua ($total)'),
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
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final k in daftarKategori)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: CircleAvatar(
                                backgroundColor: Color(k.warna),
                                radius: 5,
                              ),
                              label: Text(k.nama),
                              selected: vm.filterKategoriId == k.id,
                              onSelected: (aktif) =>
                                  vm.setFilterKategori(aktif ? k.id : null),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Sub-header Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vm.adaFilter
                            ? 'Menampilkan ${items.length} dari $total catatan '
                                  '(${vm.urutTerbaru ? 'Terbaru' : 'Terlama'})'
                            : 'Total catatan: $total '
                                  '(${vm.urutTerbaru ? 'Terbaru' : 'Terlama'})',
                        key: const Key('label_jumlah_catatan'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 14,
                          color: AppTheme.tertiaryContainer,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tersinkron',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(child: body),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Tambah Catatan Baru',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormCatatanPage()),
            ),
            child: const Icon(Icons.edit_note, size: 28),
          ),
          bottomNavigationBar: widget.tampilkanNavBar
              ? NavigationBar(
                  selectedIndex: 1,
                  onDestinationSelected: (i) {
                    if (i == 0) {
                      Navigator.pop(context);
                    } else if (i == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JadwalPage()),
                      );
                    } else if (i == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TentangPage()),
                      );
                    }
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'Catatan',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: 'Jadwal',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
