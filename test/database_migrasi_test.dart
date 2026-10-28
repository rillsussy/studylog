import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:studylog/data/catatan_repository.dart';
import 'package:studylog/data/database_helper.dart';
import 'package:studylog/data/jadwal_repository.dart';

void main() {
  sqfliteFfiInit();

  test('Database baru berisi 8 jadwal hasil seed', () async {
    final helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    final jadwal = await JadwalRepository(helper).semua();
    expect(jadwal, hasLength(8));
    expect(jadwal.first.nama, 'Sistem Manajemen Basis Data');
    await helper.tutup();
  });

  test(
    'Migrasi v1 -> v2 mempertahankan catatan dan menautkan jadwal',
    () async {
      final dir = await Directory.systemTemp.createTemp('studylog_test');
      final path = p.join(dir.path, 'migrasi.db');

      // Buat database versi 1 secara manual.
      final v1 = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute('''
            CREATE TABLE catatan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              mata_kuliah TEXT NOT NULL,
              judul TEXT NOT NULL,
              isi TEXT NOT NULL,
              tanggal TEXT NOT NULL
            )
          ''');
            await db.insert('catatan', {
              'mata_kuliah': 'kriptografi',
              'judul': 'Lama',
              'isi': 'Data v1',
              'tanggal': DateTime(2026, 10, 1).toIso8601String(),
            });
          },
        ),
      );
      await v1.close();

      final helper = DatabaseHelper(factory: databaseFactoryFfi, path: path);
      final semua = await CatatanRepository(helper).semua();
      expect(semua, hasLength(1));
      expect(semua.first.judul, 'Lama');

      final jadwal = await JadwalRepository(helper).semua();
      final kripto = jadwal.firstWhere((j) => j.nama == 'Kriptografi');
      expect(semua.first.jadwalId, kripto.id);

      await helper.tutup();
      await dir.delete(recursive: true);
    },
  );
}
