import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/catatan.dart';
import '../theme/app_theme.dart';
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppTheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever,
                color: AppTheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Catatan Ini?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Catatan '$judulCatatan' akan dihapus secara permanen dari penyimpanan dan tidak dapat dipulihkan.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete, size: 16),
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
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storage, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      c.mataKuliah,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSecondaryFixedVariant,
                      ),
                    ),
                  ),
                ],
              ),
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
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () => _konfirmasiHapus(context, vm, c.judul),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // Academic Badges Cluster
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school,
                          size: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Semester 5',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kategori != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(kategori.warna).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(kategori.warna),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (c.favorit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 13,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Favorit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Headline Title
              Text(
                c.judul,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Metadata Ribbon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceContainerHigh),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTanggal(c.tanggal),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (jadwal != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.meeting_room,
                            size: 16,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ruang: ${jadwal.ruang}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              jadwal.dosen,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Topic Highlight (if present)
              if (c.topik.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.secondaryContainer),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_stories,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Topik Bahasan',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              c.topik,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Core Note Content (Card with elevation & selectable text)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes, size: 18, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Catatan Kuliah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      c.isi,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            tooltip: 'Ubah Catatan',
            icon: const Icon(Icons.edit),
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
