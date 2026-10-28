import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:studylog/data/catatan_repository.dart';
import 'package:studylog/data/database_helper.dart';
import 'package:studylog/models/catatan.dart';

void main() {
  sqfliteFfiInit();
  late DatabaseHelper helper;
  late CatatanRepository repo;

  setUp(() {
    helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repo = CatatanRepository(helper);
  });

  tearDown(() => helper.tutup());

  Catatan contoh([String judul = 'Caesar Cipher']) => Catatan(
    mataKuliah: 'Kriptografi',
    judul: judul,
    isi: 'Geser huruf',
    tanggal: DateTime(2026, 10, 28, 20, 30),
  );

  test('Create & Read', () async {
    final id = await repo.tambah(contoh());
    final semua = await repo.semua();
    expect(semua, hasLength(1));
    expect(semua.first.id, id);
    expect(semua.first.tanggal, DateTime(2026, 10, 28, 20, 30));
  });

  test('Update', () async {
    final id = await repo.tambah(contoh());
    final c = (await repo.cariById(id))!;
    await repo.ubah(c.copyWith(judul: 'Vigenere'));
    expect((await repo.cariById(id))!.judul, 'Vigenere');
  });

  test('Delete', () async {
    final id = await repo.tambah(contoh());
    await repo.hapus(id);
    expect(await repo.semua(), isEmpty);
  });

  test('Cari berdasarkan kata kunci dan jadwal', () async {
    await repo.tambah(contoh('Caesar Cipher').copyWith(jadwalId: () => 5));
    await repo.tambah(
      Catatan(
        mataKuliah: 'Jaringan Nirkabel',
        judul: 'WiFi 802.11',
        isi: 'Standar IEEE',
        tanggal: DateTime(2026, 10, 30, 19),
        jadwalId: 7,
      ),
    );

    expect(
      (await repo.cari(kataKunci: 'caesar')).single.judul,
      'Caesar Cipher',
    );
    expect((await repo.cari(kataKunci: 'ieee')).single.judul, 'WiFi 802.11');
    expect((await repo.cari(jadwalId: 7)).single.judul, 'WiFi 802.11');
    expect(await repo.cari(kataKunci: 'caesar', jadwalId: 7), isEmpty);
    expect(await repo.cari(), hasLength(2));
  });
}
