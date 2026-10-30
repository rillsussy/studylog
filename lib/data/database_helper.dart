import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'jadwal_seed.dart';
import 'kategori_seed.dart';

/// Lapisan paling bawah: membuka koneksi dan mengelola skema SQLite.
///
/// Riwayat versi skema:
/// - v1: tabel `catatan` (kompetensi dasar M3).
/// - v2: tabel `jadwal` (relasi 1..N ke `catatan` via `jadwal_id`).
/// - v3: tabel `kategori` (skema 3 tabel relasional `jadwal` - `catatan` - `kategori`),
///       serta kolom `favorit` dan `topik` pada `catatan`.
class DatabaseHelper {
  static const namaDatabase = 'studylog.db';
  static const versi = 3;

  /// Instance standar untuk produksi (sesuai Workbook Bab 5.6 / Lampiran 10).
  static final DatabaseHelper instance = DatabaseHelper();

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
    final path =
        _pathOverride ??
        p.join(await _factory.getDatabasesPath(), namaDatabase);
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: versi,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _buatTabelJadwal(db);
    await _buatTabelKategori(db);
    await db.execute('''
      CREATE TABLE catatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mata_kuliah TEXT NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        topik TEXT NOT NULL DEFAULT '',
        favorit INTEGER NOT NULL DEFAULT 0,
        jadwal_id INTEGER REFERENCES jadwal(id) ON DELETE SET NULL,
        kategori_id INTEGER REFERENCES kategori(id) ON DELETE SET NULL
      )
    ''');
    await _seedJadwal(db);
    await _seedKategori(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _buatTabelJadwal(db);
      await db.execute(
        'ALTER TABLE catatan ADD COLUMN jadwal_id INTEGER '
        'REFERENCES jadwal(id) ON DELETE SET NULL',
      );
      await _seedJadwal(db);
      // Hubungkan catatan lama ke jadwal berdasarkan nama mata kuliah.
      await db.execute('''
        UPDATE catatan SET jadwal_id = (
          SELECT j.id FROM jadwal j
          WHERE LOWER(TRIM(j.nama)) = LOWER(TRIM(catatan.mata_kuliah))
          LIMIT 1
        )
      ''');
    }
    if (oldVersion < 3) {
      await _buatTabelKategori(db);
      await _seedKategori(db);
      await db.execute(
        "ALTER TABLE catatan ADD COLUMN topik TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        'ALTER TABLE catatan ADD COLUMN favorit INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE catatan ADD COLUMN kategori_id INTEGER '
        'REFERENCES kategori(id) ON DELETE SET NULL',
      );
      // Set default kategori 'Materi Kuliah' untuk catatan lama.
      await db.execute('''
        UPDATE catatan SET kategori_id = (
          SELECT k.id FROM kategori k WHERE k.nama = 'Materi Kuliah' LIMIT 1
        ) WHERE kategori_id IS NULL
      ''');
    }
  }

  Future<void> _buatTabelJadwal(Database db) async {
    await db.execute('''
      CREATE TABLE jadwal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hari INTEGER NOT NULL,
        mulai INTEGER NOT NULL,
        selesai INTEGER NOT NULL,
        kode TEXT NOT NULL,
        nama TEXT NOT NULL,
        sks INTEGER NOT NULL,
        kelas TEXT NOT NULL,
        ruang TEXT NOT NULL,
        dosen TEXT NOT NULL
      )
    ''');
  }

  Future<void> _buatTabelKategori(Database db) async {
    await db.execute('''
      CREATE TABLE kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE,
        warna INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedJadwal(Database db) async {
    final batch = db.batch();
    for (final j in jadwalAwal) {
      batch.insert('jadwal', j.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedKategori(Database db) async {
    final batch = db.batch();
    for (final k in kategoriAwal) {
      batch.insert('kategori', k.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> tutup() async {
    await _db?.close();
    _db = null;
  }
}
