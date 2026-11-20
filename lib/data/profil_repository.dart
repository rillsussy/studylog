import 'package:sqflite/sqflite.dart';

import '../models/profil.dart';
import 'database_helper.dart';

class ProfilRepository {
  final DatabaseHelper _helper;
  ProfilRepository(this._helper);

  Profil _cache = Profil.defaultProfil();

  Future<void> _initTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profil (
        id INTEGER PRIMARY KEY,
        nama TEXT NOT NULL,
        nim TEXT NOT NULL,
        kelas TEXT NOT NULL,
        prodi TEXT NOT NULL,
        semester TEXT NOT NULL,
        institusi TEXT NOT NULL
      )
    ''');
  }

  Future<Profil> ambil() async {
    try {
      final db = await _helper.database;
      await _initTable(db);
      final rows = await db.query('profil', where: 'id = 1');
      if (rows.isNotEmpty) {
        _cache = Profil.fromMap(rows.first);
        return _cache;
      }
    } catch (_) {
      // Fallback cache saat database tidak tersedia / di pengujian
    }
    return _cache;
  }

  Future<void> simpan(Profil profil) async {
    _cache = profil;
    try {
      final db = await _helper.database;
      await _initTable(db);
      final map = profil.toMap()..['id'] = 1;
      await db.insert(
        'profil',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Fallback saat database tidak tersedia / di pengujian
    }
  }
}
