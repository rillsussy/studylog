import 'package:flutter_test/flutter_test.dart';
import 'package:studylog/models/catatan.dart';

void main() {
  group('Catatan Model Test (Slide 29)', () {
    final tgl = DateTime(2026, 10, 29, 19, 0);

    test('Konstruktor dan toMap / fromMap berfungsi dengan benar', () {
      final c = Catatan(
        id: 1,
        mataKuliah: 'Kriptografi',
        judul: 'Pertemuan 1',
        isi: 'Mempelajari enkripsi klasik',
        tanggal: tgl,
        jadwalId: 5,
      );

      final map = c.toMap();
      expect(map['id'], 1);
      expect(map['mata_kuliah'], 'Kriptografi');
      expect(map['judul'], 'Pertemuan 1');
      expect(map['isi'], 'Mempelajari enkripsi klasik');
      expect(map['tanggal'], tgl.toIso8601String());
      expect(map['jadwal_id'], 5);

      final dariMap = Catatan.fromMap(map);
      expect(dariMap.id, c.id);
      expect(dariMap.mataKuliah, c.mataKuliah);
      expect(dariMap.judul, c.judul);
      expect(dariMap.isi, c.isi);
      expect(dariMap.tanggal, c.tanggal);
      expect(dariMap.jadwalId, c.jadwalId);
    });

    test('copyWith memperbarui nilai dengan tepat', () {
      final c = Catatan(
        id: 1,
        mataKuliah: 'Jaringan Nirkabel',
        judul: 'Topik A',
        isi: 'Catatan A',
        tanggal: tgl,
      );

      final diubah = c.copyWith(
        judul: 'Topik Baru',
        isi: 'Catatan Baru',
      );

      expect(diubah.id, 1);
      expect(diubah.mataKuliah, 'Jaringan Nirkabel');
      expect(diubah.judul, 'Topik Baru');
      expect(diubah.isi, 'Catatan Baru');
      expect(diubah.tanggal, tgl);
    });
  });
}
