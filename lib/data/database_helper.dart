import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Lapisan paling bawah: membuka koneksi dan mengelola skema SQLite.
class DatabaseHelper {
  static const namaDatabase = 'studylog.db';
  static const versi = 1;

  final DatabaseFactory? _factoryOverride;
  final String? _pathOverride;
  Database? _db;

  /// [factory] dan [path] dapat diganti saat pengujian
  /// (misalnya `databaseFactoryFfi` dan `inMemoryDatabasePath`).
  DatabaseHelper({DatabaseFactory? factory, String? path})
      : _factoryOverride = factory,
        _pathOverride = path;

  DatabaseFactory get _factory => _factoryOverride ?? databaseFactory;

  Future<Database> get database async {
    return _db ??= await _buka();
  }

  Future<Database> _buka() async {
    final path = _pathOverride ??
        p.join(await _factory.getDatabasesPath(), namaDatabase);
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: versi,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE catatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mata_kuliah TEXT NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  Future<void> tutup() async {
    await _db?.close();
    _db = null;
  }
}
