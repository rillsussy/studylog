import '../models/jadwal.dart';
import 'database_helper.dart';

class JadwalRepository {
  final DatabaseHelper _helper;
  JadwalRepository(this._helper);

  Future<List<Jadwal>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('jadwal', orderBy: 'hari, mulai');
    return rows.map(Jadwal.fromMap).toList();
  }

  Future<int> tambah(Jadwal j) async {
    final db = await _helper.database;
    return await db.insert('jadwal', j.toMap());
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }
}
