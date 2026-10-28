/// Entitas catatan perkuliahan.
class Catatan {
  final int? id;
  final String mataKuliah;
  final String judul;
  final String isi;
  final DateTime tanggal;

  /// Relasi ke tabel `jadwal` (boleh null untuk mata kuliah di luar jadwal).
  final int? jadwalId;

  const Catatan({
    this.id,
    required this.mataKuliah,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.jadwalId,
  });

  Catatan copyWith({
    int? id,
    String? mataKuliah,
    String? judul,
    String? isi,
    DateTime? tanggal,
    int? Function()? jadwalId,
  }) {
    return Catatan(
      id: id ?? this.id,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      jadwalId: jadwalId != null ? jadwalId() : this.jadwalId,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'mata_kuliah': mataKuliah,
    'judul': judul,
    'isi': isi,
    'tanggal': tanggal.toIso8601String(),
    'jadwal_id': jadwalId,
  };

  factory Catatan.fromMap(Map<String, Object?> map) => Catatan(
    id: map['id'] as int?,
    mataKuliah: map['mata_kuliah'] as String,
    judul: map['judul'] as String,
    isi: map['isi'] as String,
    tanggal: DateTime.parse(map['tanggal'] as String),
    jadwalId: map['jadwal_id'] as int?,
  );
}
