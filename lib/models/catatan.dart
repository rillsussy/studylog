/// Entitas catatan perkuliahan.
class Catatan {
  final int? id;
  final String mataKuliah;
  final String judul;
  final String isi;
  final DateTime tanggal;

  const Catatan({
    this.id,
    required this.mataKuliah,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  Catatan copyWith({
    int? id,
    String? mataKuliah,
    String? judul,
    String? isi,
    DateTime? tanggal,
  }) {
    return Catatan(
      id: id ?? this.id,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'mata_kuliah': mataKuliah,
        'judul': judul,
        'isi': isi,
        'tanggal': tanggal.toIso8601String(),
      };

  factory Catatan.fromMap(Map<String, Object?> map) => Catatan(
        id: map['id'] as int?,
        mataKuliah: map['mata_kuliah'] as String,
        judul: map['judul'] as String,
        isi: map['isi'] as String,
        tanggal: DateTime.parse(map['tanggal'] as String),
      );
}
