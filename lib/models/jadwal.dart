/// Satu slot jadwal perkuliahan mingguan.
class Jadwal {
  final int? id;

  /// 1 = Senin ... 7 = Minggu (sama dengan [DateTime.weekday]).
  final int hari;

  /// Menit sejak 00:00, misalnya 19:00 = 1140.
  final int mulai;
  final int selesai;
  final String kode;
  final String nama;
  final int sks;
  final String kelas;
  final String ruang;
  final String dosen;

  const Jadwal({
    this.id,
    required this.hari,
    required this.mulai,
    required this.selesai,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.kelas,
    required this.ruang,
    required this.dosen,
  });

  static const namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  String get labelHari => namaHari[hari - 1];

  static String jam(int menit) =>
      '${(menit ~/ 60).toString().padLeft(2, '0')}:'
      '${(menit % 60).toString().padLeft(2, '0')}';

  String get labelJam => '${jam(mulai)} - ${jam(selesai)}';

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'hari': hari,
    'mulai': mulai,
    'selesai': selesai,
    'kode': kode,
    'nama': nama,
    'sks': sks,
    'kelas': kelas,
    'ruang': ruang,
    'dosen': dosen,
  };

  factory Jadwal.fromMap(Map<String, Object?> m) => Jadwal(
    id: m['id'] as int?,
    hari: m['hari'] as int,
    mulai: m['mulai'] as int,
    selesai: m['selesai'] as int,
    kode: m['kode'] as String,
    nama: m['nama'] as String,
    sks: m['sks'] as int,
    kelas: m['kelas'] as String,
    ruang: m['ruang'] as String,
    dosen: m['dosen'] as String,
  );
}
