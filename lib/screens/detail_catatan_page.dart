import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_view_model.dart';
import '../viewmodels/jadwal_view_model.dart';
import '../viewmodels/kategori_view_model.dart';
import 'form_catatan_page.dart';

class DetailCatatanPage extends StatelessWidget {
  final int id;
  const DetailCatatanPage({super.key, required this.id});

  Future<void> _konfirmasiHapus(
    BuildContext context,
    CatatanViewModel vm,
    String judulCatatan,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: cs.onErrorContainer,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hapus Catatan Ini?',
              textAlign: TextAlign.center,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Catatan '$judulCatatan' akan dihapus secara permanen dari penyimpanan dan tidak dapat dipulihkan.",
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => Navigator.pop(ctx, true),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await vm.hapusCatatan(id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Catatan dihapus')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  Future<void> _salinCatatan(
    BuildContext context,
    Catatan c, {
    String? namaKategori,
    String? infoJadwal,
  }) async {
    final teks = c.formatEkspor(
      namaKategori: namaKategori,
      infoJadwal: infoJadwal,
    );
    await Clipboard.setData(ClipboardData(text: teks));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan disalin ke papan klip')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Consumer<CatatanViewModel>(
      builder: (context, vm, _) {
        final c = vm.cariById(id);
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Catatan tidak ditemukan')),
          );
        }
        final jadwal = context.watch<JadwalViewModel>().cariById(c.jadwalId);
        final kategori = context.watch<KategoriViewModel>().cariById(
          c.kategoriId,
        );
        final infoJadwal = jadwal == null
            ? null
            : '${jadwal.kode} • ${jadwal.labelHari} ${jadwal.labelJam} • '
                  '${jadwal.ruang}';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Detail Catatan',
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                key: const Key('tombol_ubah'),
                tooltip: 'Edit Catatan',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormCatatanPage(catatan: c),
                  ),
                ),
              ),
              IconButton(
                key: const Key('tombol_favorit'),
                tooltip: c.favorit ? 'Hapus favorit' : 'Simpan Bintang',
                icon: Icon(
                  c.favorit ? Icons.star : Icons.star_border,
                  color: c.favorit ? Colors.amber.shade700 : null,
                ),
                onPressed: () => vm.toggleFavorit(c),
              ),
              IconButton(
                key: const Key('tombol_salin'),
                tooltip: 'Bagikan & Salin Teks',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _salinCatatan(
                  context,
                  c,
                  namaKategori: kategori?.nama,
                  infoJadwal: infoJadwal,
                ),
              ),
              IconButton(
                key: const Key('tombol_hapus'),
                tooltip: 'Hapus',
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: () => _konfirmasiHapus(context, vm, c.judul),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              // Tonal Metadata Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tonal Chips for Course, Category, Topic, Favorit
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 14,
                                color: cs.onPrimaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  c.mataKuliah,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kategori != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Color(kategori.warna)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(kategori.warna),
                                  radius: 4,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  kategori.nama,
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Color(kategori.warna),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (c.topik.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14,
                                  color: cs.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    c.topik.trim(),
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (c.favorit)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: cs.tertiaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Favorit',
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onTertiaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Headline Title
                    Text(
                      c.judul,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatTanggal(c.tanggal),
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (jadwal != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Ruang ${jadwal.ruang}',
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal.dosen,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Generous Readable Note Content Surface
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Catatan Kuliah',
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SelectableText(
                      c.isi,
                      style: tt.bodyLarge?.copyWith(
                        height: 1.65,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            tooltip: 'Ubah Catatan',
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Ubah Catatan'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FormCatatanPage(catatan: c)),
            ),
          ),
        );
      },
    );
  }
}
