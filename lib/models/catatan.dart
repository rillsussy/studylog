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
}
