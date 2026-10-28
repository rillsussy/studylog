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
}
