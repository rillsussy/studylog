import 'package:studylog/data/catatan_repository.dart';
import 'package:studylog/data/database_helper.dart';
import 'package:studylog/data/jadwal_repository.dart';
import 'package:studylog/data/jadwal_seed.dart';
import 'package:studylog/data/kategori_repository.dart';
import 'package:studylog/data/kategori_seed.dart';
import 'package:studylog/models/catatan.dart';
import 'package:studylog/models/jadwal.dart';
import 'package:studylog/models/kategori.dart';

/// Jadwal seed dengan id 1..8 (urutan sama seperti di database).
final jadwalDenganId = [
  for (var i = 0; i < jadwalAwal.length; i++)
    Jadwal.fromMap({...jadwalAwal[i].toMap(), 'id': i + 1}),
];

/// Kategori seed dengan id 1..5.
final kategoriDenganId = [
  for (var i = 0; i < kategoriAwal.length; i++)
    Kategori.fromMap({...kategoriAwal[i].toMap(), 'id': i + 1}),
];

class FakeJadwalRepository extends JadwalRepository {
  FakeJadwalRepository() : super(DatabaseHelper());

  @override
  Future<List<Jadwal>> semua() async => jadwalDenganId;
}

class FakeKategoriRepository extends KategoriRepository {
  FakeKategoriRepository() : super(DatabaseHelper());

  final List<Kategori> _items = List.of(kategoriDenganId);

  @override
  Future<List<Kategori>> semua() async => List.unmodifiable(_items);

  @override
  Future<int> tambah(Kategori kategori) async {
    final id = _items.length + 1;
    _items.add(Kategori(id: id, nama: kategori.nama, warna: kategori.warna));
    return id;
  }
}

/// Repository palsu (in-memory) agar widget test tidak bergantung SQLite.
class FakeCatatanRepository extends CatatanRepository {
  FakeCatatanRepository() : super(DatabaseHelper());

  final List<Catatan> _data = [];
  int _id = 1;

  List<Catatan> _urutkan(Iterable<Catatan> src, bool terbaru) {
    final list = src.toList()
      ..sort((a, b) {
        final cmp = a.tanggal.compareTo(b.tanggal);
        if (cmp != 0) return terbaru ? -cmp : cmp;
        final idA = a.id ?? 0;
        final idB = b.id ?? 0;
        return terbaru ? idB.compareTo(idA) : idA.compareTo(idB);
      });
    return list;
  }

  @override
  Future<List<Catatan>> semua({bool terbaru = true}) async =>
      _urutkan(_data, terbaru);

  @override
  Future<List<Catatan>> cari({
    String kataKunci = '',
    int? jadwalId,
    int? kategoriId,
    bool hanyaFavorit = false,
    bool terbaru = true,
  }) async {
    final k = kataKunci.trim().toLowerCase();
    final cocok = _data.where((c) {
      final cocokKata =
          k.isEmpty ||
          c.judul.toLowerCase().contains(k) ||
          c.mataKuliah.toLowerCase().contains(k) ||
          c.topik.toLowerCase().contains(k) ||
          c.isi.toLowerCase().contains(k);
      final cocokJadwal = jadwalId == null || c.jadwalId == jadwalId;
      final cocokKategori = kategoriId == null || c.kategoriId == kategoriId;
      final cocokFavorit = !hanyaFavorit || c.favorit;
      return cocokKata && cocokJadwal && cocokKategori && cocokFavorit;
    });
    return _urutkan(cocok, terbaru);
  }

  @override
  Future<Catatan?> cariById(int id) async {
    for (final c in _data) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<int> tambah(Catatan catatan) async {
    final id = _id++;
    _data.add(catatan.copyWith(id: id));
    return id;
  }

  @override
  Future<int> ubah(Catatan catatan) async {
    if (catatan.id == null) {
      throw ArgumentError('ID catatan tidak boleh kosong');
    }
    final i = _data.indexWhere((e) => e.id == catatan.id);
    if (i == -1) return 0;
    _data[i] = catatan;
    return 1;
  }

  @override
  Future<int> setFavorit(int id, bool favorit) async {
    final i = _data.indexWhere((e) => e.id == id);
    if (i == -1) return 0;
    _data[i] = _data[i].copyWith(favorit: favorit);
    return 1;
  }

  @override
  Future<int> hapus(int id) async {
    final n = _data.length;
    _data.removeWhere((e) => e.id == id);
    return n - _data.length;
  }
}
