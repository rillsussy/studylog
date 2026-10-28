import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jadwal.dart';
import '../utils/format.dart';
import '../viewmodels/catatan_viewmodel.dart';
import '../viewmodels/jadwal_viewmodel.dart';
import 'daftar_catatan_screen.dart';
import 'form_catatan_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  void _catat(BuildContext context, Jadwal j) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCatatanScreen(jadwal: j)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jumlah = context.watch<CatatanViewModel>().items.length;
    final jadwalVm = context.watch<JadwalViewModel>();
    final status = jadwalVm.status;
    final aktif = status.aktif;

    return Scaffold(
      appBar: AppBar(title: const Text('StudyLog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (aktif != null)
            _KartuKuliahAktif(
              jadwal: aktif,
              segera: status.segeraDimulai,
              onCatat: () => _catat(context, aktif),
            )
          else
            _KartuTidakAdaKuliah(
              berikutnya: status.berikutnya,
              waktu: status.waktuBerikutnya,
            ),
          const SizedBox(height: 16),
          Text(
            'Catat cepat per mata kuliah',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final j in jadwalVm.mataKuliahUnik)
                ActionChip(
                  avatar: const Icon(Icons.edit_note, size: 18),
                  label: Text(j.nama),
                  onPressed: () => _catat(context, j),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
          OutlinedButton.icon(
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

class _KartuKuliahAktif extends StatelessWidget {
  final Jadwal jadwal;
  final bool segera;
  final VoidCallback onCatat;

  const _KartuKuliahAktif({
    required this.jadwal,
    required this.segera,
    required this.onCatat,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  segera ? Icons.schedule : Icons.circle,
                  size: 14,
                  color: segera ? scheme.tertiary : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  segera ? 'SEGERA DIMULAI' : 'SEDANG BERLANGSUNG',
                  style: text.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(jadwal.nama, style: text.titleLarge),
            const SizedBox(height: 4),
            Text('${jadwal.labelJam} • ${jadwal.ruang}'),
            Text(jadwal.dosen, style: text.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('tombol_catat_sekarang'),
                icon: const Icon(Icons.edit),
                label: const Text('Catat Sekarang'),
                onPressed: onCatat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuTidakAdaKuliah extends StatelessWidget {
  final Jadwal? berikutnya;
  final DateTime? waktu;

  const _KartuTidakAdaKuliah({this.berikutnya, this.waktu});

  @override
  Widget build(BuildContext context) {
    final b = berikutnya;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available),
        title: const Text('Tidak ada perkuliahan saat ini'),
        subtitle: b == null
            ? null
            : Text(
                'Berikutnya: ${b.nama}\n'
                '${b.labelHari}, ${formatTanggalSaja(waktu!)} • '
                '${b.labelJam} • ${b.ruang}',
              ),
        isThreeLine: b != null,
      ),
    );
  }
}
