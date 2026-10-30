import 'package:sqflite/sqflite.dart';

import '../models/kategori.dart';
import 'database_helper.dart';

/// Repository akses tabel `kategori` (tag catatan).
class KategoriRepository {
  final DatabaseHelper helper;
  KategoriRepository(this.helper);

  Future<List<Kategori>> semua() async {
    final db = await helper.database;
    final rows = await db.query('kategori', orderBy: 'id ASC');
    return rows.map(Kategori.fromMap).toList();
  }

  Future<int> tambah(Kategori kategori) async {
    final db = await helper.database;
    return db.insert(
      'kategori',
      kategori.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
