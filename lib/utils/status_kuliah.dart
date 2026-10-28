import '../models/jadwal.dart';

/// Logika murni penentuan kuliah aktif / berikutnya (mudah diuji).
class StatusKuliah {
  /// Kuliah dianggap "segera dimulai" mulai N menit sebelum jam mulai.
  static const menitSebelum = 15;

  final Jadwal? aktif;
  final bool segeraDimulai;
  final Jadwal? berikutnya;
  final DateTime? waktuBerikutnya;

  const StatusKuliah({
    this.aktif,
    this.segeraDimulai = false,
    this.berikutnya,
    this.waktuBerikutnya,
  });

  factory StatusKuliah.hitung(List<Jadwal> daftar, DateTime now) {
    final menit = now.hour * 60 + now.minute;
    final hariIni = daftar.where((j) => j.hari == now.weekday).toList()
      ..sort((a, b) => a.mulai.compareTo(b.mulai));

    Jadwal? aktif;
    var segera = false;
    for (final j in hariIni) {
      if (menit >= j.mulai && menit < j.selesai) {
        aktif = j;
        segera = false;
        break;
      }
      if (menit >= j.mulai - menitSebelum && menit < j.mulai) {
        aktif = j;
        segera = true;
        break;
      }
    }

    // Cari slot berikutnya (di luar slot aktif) dalam 7 hari ke depan.
    Jadwal? next;
    DateTime? waktuNext;
    final hariMulai = DateTime(now.year, now.month, now.day);
    for (var d = 0; d < 8 && next == null; d++) {
      final tgl = hariMulai.add(Duration(days: d));
      final kandidat = daftar.where((j) => j.hari == tgl.weekday).toList()
        ..sort((a, b) => a.mulai.compareTo(b.mulai));
      for (final j in kandidat) {
        if (d == 0 && j.mulai <= menit) continue;
        if (identical(j, aktif)) continue;
        next = j;
        waktuNext = tgl.add(Duration(minutes: j.mulai));
        break;
      }
    }

    return StatusKuliah(
      aktif: aktif,
      segeraDimulai: segera,
      berikutnya: next,
      waktuBerikutnya: waktuNext,
    );
  }
}
