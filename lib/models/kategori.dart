/// Entitas kategori / tag catatan (tabel ke-3 pada skema relasional).
class Kategori {
  final int? id;
  final String nama;

  /// Nilai warna ARGB untuk penanda visual kategori.
  final int warna;

  const Kategori({this.id, required this.nama, required this.warna});

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nama': nama,
    'warna': warna,
  };

  factory Kategori.fromMap(Map<String, Object?> map) => Kategori(
    id: map['id'] as int?,
    nama: map['nama'] as String,
    warna: map['warna'] as int,
  );
}
