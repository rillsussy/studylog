import '../models/catatan.dart';
import 'database_helper.dart';

/// Repository: satu-satunya pintu akses data catatan untuk ViewModel.
class CatatanRepository {
  final DatabaseHelper _helper;
  CatatanRepository(this._helper);

  Future<List<Catatan>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('catatan', orderBy: 'tanggal DESC, id DESC');
    return rows.map(Catatan.fromMap).toList();
  }

  /// Mencari catatan berdasarkan kata kunci (judul / mata kuliah / isi)
  /// dan/atau jadwal tertentu.
  Future<List<Catatan>> cari({String kataKunci = '', int? jadwalId}) async {
    final db = await _helper.database;
    final where = <String>[];
    final args = <Object?>[];
    final k = kataKunci.trim();
    if (k.isNotEmpty) {
      where.add('(judul LIKE ? OR mata_kuliah LIKE ? OR isi LIKE ?)');
      args.addAll(['%$k%', '%$k%', '%$k%']);
    }
    if (jadwalId != null) {
      where.add('jadwal_id = ?');
      args.add(jadwalId);
    }
    final rows = await db.query(
      'catatan',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(Catatan.fromMap).toList();
  }

  Future<Catatan?> cariById(int id) async {
    final db = await _helper.database;
    final rows = await db.query('catatan', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Catatan.fromMap(rows.first);
  }

  Future<int> tambah(Catatan c) async {
    final db = await _helper.database;
    return db.insert('catatan', c.toMap());
  }

  Future<int> ubah(Catatan c) async {
    final db = await _helper.database;
    return db.update('catatan', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}
