import 'package:sqflite/sqflite.dart';

import '../models/catatan.dart';
import 'database_helper.dart';

/// Repository: satu-satunya pintu akses data catatan untuk ViewModel.
class CatatanRepository {
  final DatabaseHelper helper;
  CatatanRepository(this.helper);

  Future<List<Catatan>> semua({bool terbaru = true}) async {
    final Database db = await helper.database;
    final arah = terbaru ? 'DESC' : 'ASC';
    final baris = await db.query('catatan', orderBy: 'tanggal $arah, id $arah');
    return baris.map(Catatan.fromMap).toList();
  }

  /// Mencari dan memfilter catatan berdasarkan kata kunci, mata kuliah,
  /// kategori/tag, status favorit, serta urutan waktu (Bab 6.2).
  Future<List<Catatan>> cari({
    String kataKunci = '',
    int? jadwalId,
    int? kategoriId,
    bool hanyaFavorit = false,
    bool terbaru = true,
  }) async {
    final db = await helper.database;
    final where = <String>[];
    final args = <Object?>[];
    final k = kataKunci.trim();
    if (k.isNotEmpty) {
      where.add(
        '(judul LIKE ? OR mata_kuliah LIKE ? OR topik LIKE ? OR isi LIKE ?)',
      );
      args.addAll(['%$k%', '%$k%', '%$k%', '%$k%']);
    }
    if (jadwalId != null) {
      where.add('jadwal_id = ?');
      args.add(jadwalId);
    }
    if (kategoriId != null) {
      where.add('kategori_id = ?');
      args.add(kategoriId);
    }
    if (hanyaFavorit) {
      where.add('favorit = 1');
    }
    final arah = terbaru ? 'DESC' : 'ASC';
    final rows = await db.query(
      'catatan',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'tanggal $arah, id $arah',
    );
    return rows.map(Catatan.fromMap).toList();
  }

  Future<Catatan?> cariById(int id) async {
    final db = await helper.database;
    final rows = await db.query('catatan', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Catatan.fromMap(rows.first);
  }

  Future<int> tambah(Catatan catatan) async {
    final db = await helper.database;
    return db.insert('catatan', catatan.toMap());
  }

  Future<int> ubah(Catatan catatan) async {
    if (catatan.id == null) {
      throw ArgumentError('ID catatan tidak boleh kosong');
    }
    final db = await helper.database;
    return db.update(
      'catatan',
      catatan.toMap(),
      where: 'id = ?',
      whereArgs: [catatan.id],
    );
  }

  Future<int> setFavorit(int id, bool favorit) async {
    final db = await helper.database;
    return db.update(
      'catatan',
      {'favorit': favorit ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await helper.database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}
