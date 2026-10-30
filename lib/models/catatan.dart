/// Entitas catatan perkuliahan.
class Catatan {
  final int? id;
  final String mataKuliah;
  final String judul;
  final String isi;
  final DateTime tanggal;

  /// Topik pembahasan (opsional; minimal 3 karakter bila diisi - Bab 3.5).
  final String topik;

  /// Penanda catatan prioritas/favorit yang disimpan di SQLite (Bab 6.2).
  final bool favorit;

  /// Relasi ke tabel `jadwal` (boleh null untuk mata kuliah di luar jadwal).
  final int? jadwalId;

  /// Relasi ke tabel `kategori` (boleh null bila tanpa kategori).
  final int? kategoriId;

  const Catatan({
    this.id,
    required this.mataKuliah,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.topik = '',
    this.favorit = false,
    this.jadwalId,
    this.kategoriId,
  });

  Catatan copyWith({
    int? id,
    String? mataKuliah,
    String? judul,
    String? isi,
    DateTime? tanggal,
    String? topik,
    bool? favorit,
    int? Function()? jadwalId,
    int? Function()? kategoriId,
  }) {
    return Catatan(
      id: id ?? this.id,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      topik: topik ?? this.topik,
      favorit: favorit ?? this.favorit,
      jadwalId: jadwalId != null ? jadwalId() : this.jadwalId,
      kategoriId: kategoriId != null ? kategoriId() : this.kategoriId,
    );
  }

  /// Format teks rapi untuk fitur salin/ekspor catatan (Bab 6.2).
  String formatEkspor({String? namaKategori, String? infoJadwal}) {
    final buffer = StringBuffer()
      ..writeln('[$mataKuliah] $judul')
      ..writeln('Tanggal: ${tanggal.toIso8601String().substring(0, 10)}');
    if (namaKategori != null && namaKategori.isNotEmpty) {
      buffer.writeln('Kategori: $namaKategori');
    }
    if (topik.trim().isNotEmpty) {
      buffer.writeln('Topik: ${topik.trim()}');
    }
    if (infoJadwal != null && infoJadwal.isNotEmpty) {
      buffer.writeln('Jadwal: $infoJadwal');
    }
    buffer
      ..writeln('---')
      ..write(isi);
    return buffer.toString();
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'mata_kuliah': mataKuliah,
    'judul': judul,
    'isi': isi,
    'tanggal': tanggal.toIso8601String(),
    'topik': topik,
    'favorit': favorit ? 1 : 0,
    'jadwal_id': jadwalId,
    'kategori_id': kategoriId,
  };

  factory Catatan.fromMap(Map<String, Object?> data) => Catatan(
    id: data['id'] as int?,
    mataKuliah: data['mata_kuliah'] as String,
    judul: data['judul'] as String,
    isi: data['isi'] as String,
    tanggal: DateTime.parse(data['tanggal'] as String),
    topik: (data['topik'] as String?) ?? '',
    favorit: ((data['favorit'] as int?) ?? 0) == 1,
    jadwalId: data['jadwal_id'] as int?,
    kategoriId: data['kategori_id'] as int?,
  );
}
