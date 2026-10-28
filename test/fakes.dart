import 'package:studylog/data/catatan_repository.dart';
import 'package:studylog/data/database_helper.dart';
import 'package:studylog/models/catatan.dart';

/// Repository palsu (in-memory) agar widget test tidak bergantung SQLite.
class FakeCatatanRepository extends CatatanRepository {
  FakeCatatanRepository() : super(DatabaseHelper());

  final List<Catatan> _data = [];
  int _id = 1;

  @override
  Future<List<Catatan>> semua() async => _data.reversed.toList();

  @override
  Future<Catatan?> cariById(int id) async {
    for (final c in _data) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<int> tambah(Catatan c) async {
    final id = _id++;
    _data.add(c.copyWith(id: id));
    return id;
  }

  @override
  Future<int> ubah(Catatan c) async {
    final i = _data.indexWhere((e) => e.id == c.id);
    if (i == -1) return 0;
    _data[i] = c;
    return 1;
  }

  @override
  Future<int> hapus(int id) async {
    final n = _data.length;
    _data.removeWhere((e) => e.id == id);
    return n - _data.length;
  }
}
