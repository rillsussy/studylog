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
  ) async {
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
            title: const Text('Detail Catatan'),
            actions: [
              IconButton(
                key: const Key('tombol_favorit'),
                tooltip: c.favorit ? 'Hapus favorit' : 'Tandai favorit',
                icon: Icon(
                  c.favorit ? Icons.star : Icons.star_border,
                  color: c.favorit ? Colors.amber.shade700 : null,
                ),
                onPressed: () => vm.toggleFavorit(c),
              ),
              IconButton(
                key: const Key('tombol_salin'),
                tooltip: 'Salin Teks Catatan',
                icon: const Icon(Icons.copy),
                onPressed: () => _salinCatatan(
                  context,
                  c,
                  namaKategori: kategori?.nama,
                  infoJadwal: infoJadwal,
                ),
              ),
              IconButton(
                key: const Key('tombol_ubah'),
                tooltip: 'Ubah',
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormCatatanPage(catatan: c),
                  ),
                ),
              ),
              IconButton(
                key: const Key('tombol_hapus'),
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete),
                onPressed: () => _konfirmasiHapus(context, vm),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(label: Text(c.mataKuliah)),
                  if (kategori != null)
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(kategori.warna),
                        radius: 6,
                      ),
                      label: Text(kategori.nama),
                    ),
                ],
              ),
              if (jadwal != null)
                Text(
                  '${jadwal.kode} • ${jadwal.labelHari} ${jadwal.labelJam} • '
                  '${jadwal.ruang}\n${jadwal.dosen}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Text(c.judul, style: Theme.of(context).textTheme.headlineSmall),
              if (c.topik.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Topik: ${c.topik}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
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
      },
    );
  }
}
