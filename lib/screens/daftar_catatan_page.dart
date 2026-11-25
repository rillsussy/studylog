import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: cs.error),
                  const SizedBox(height: 12),
                  Text(
                    vm.error!,
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: vm.muatCatatan,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        } else if (items.isEmpty) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 36,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vm.adaFilter
                        ? 'Tidak ada catatan yang cocok'
                        : 'Belum ada catatan',
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = items[i];
              final kat = kategoriVm.cariById(c.kategoriId);
              final snippet = c.isi.replaceAll('\n', ' ').trim();
              final accentColor = kat != null ? Color(kat.warna) : cs.primary;

              return Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                color: cs.surfaceContainerLow,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
                  titleAlignment: ListTileTitleAlignment.top,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                c.mataKuliah,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatTanggal(c.tanggal),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
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
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (c.topik.trim().isNotEmpty || kat != null) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (c.topik.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#${c.topik.trim()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (kat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(kat.warna)
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Color(kat.warna),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      kat.nama,
                                      style: tt.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Color(kat.warna),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: c.favorit ? 'Hapus favorit' : 'Tandai favorit',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      c.favorit ? Icons.star : Icons.star_border,
                      color: c.favorit
                          ? Colors.amber.shade700
                          : cs.onSurfaceVariant,
                    ),
                    onPressed: () => vm.toggleFavorit(c),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailCatatanPage(id: c.id!),
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
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // M3 Pill Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    key: const Key('field_cari'),
                    controller: _cariController,
                    textAlignVertical: TextAlignVertical.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(
                      filled: false,
                      hintText: 'Cari judul, mata kuliah, atau isi...',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: cs.onSurfaceVariant,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      suffixIcon: _cariController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
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

              // Filter Chips Carousel (Primary)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('Semua ($total)'),
                        selected: vm.filterJadwalId == null && !vm.hanyaFavorit,
                        side: BorderSide.none,
                        backgroundColor: cs.surfaceContainerLow,
                        selectedColor: cs.secondaryContainer,
                        shape: const StadiumBorder(),
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
                        avatar: Icon(
                          Icons.star,
                          size: 16,
                          color: vm.hanyaFavorit
                              ? cs.onSecondaryContainer
                              : Colors.amber.shade700,
                        ),
                        label: const Text('Favorit'),
                        selected: vm.hanyaFavorit,
                        side: BorderSide.none,
                        backgroundColor: cs.surfaceContainerLow,
                        selectedColor: cs.secondaryContainer,
                        shape: const StadiumBorder(),
                        onSelected: vm.setHanyaFavorit,
                      ),
                    ),
                    for (final j in mataKuliah)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(j.nama),
                          selected: vm.filterJadwalId == j.id,
                          side: BorderSide.none,
                          backgroundColor: cs.surfaceContainerLow,
                          selectedColor: cs.secondaryContainer,
                          shape: const StadiumBorder(),
                          onSelected: (_) => vm.setFilterJadwal(j.id),
                        ),
                      ),
                  ],
                ),
              ),

              // Filter Chips Carousel (Kategori)
              if (daftarKategori.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 40,
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
                              side: BorderSide.none,
                              backgroundColor: cs.surfaceContainerLow,
                              selectedColor: cs.secondaryContainer,
                              shape: const StadiumBorder(),
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
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
                        style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 13,
                            color: cs.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tersinkron',
                            style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
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
