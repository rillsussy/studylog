import 'package:flutter_test/flutter_test.dart';
import 'package:studylog/models/catatan.dart';

void main() {
  test('Catatan round-trip Map tidak mengubah data', () {
    final asli = Catatan(
      id: 10,
      mataKuliah: 'Pemrograman Mobile',
      judul: 'SQLite',
      isi: 'Materi CRUD',
      tanggal: DateTime(2026, 10, 22),
    );
    final hasil = Catatan.fromMap(asli.toMap());
    expect(hasil.id, 10);
    expect(hasil.judul, 'SQLite');
    expect(hasil.mataKuliah, 'Pemrograman Mobile');
    expect(hasil.isi, 'Materi CRUD');
    expect(hasil.tanggal, DateTime(2026, 10, 22));
    expect(hasil.favorit, isFalse);
  });

  test(
    'Serialisasi field perluasan (topik, favorit, jadwalId, kategoriId)',
    () {
      final tgl = DateTime(2026, 10, 29, 19, 0);
      final c = Catatan(
        id: 1,
        mataKuliah: 'Kriptografi',
        judul: 'Pertemuan 1',
        isi: 'Mempelajari enkripsi klasik',
        tanggal: tgl,
        topik: 'Enkripsi Simetris',
        favorit: true,
        jadwalId: 5,
        kategoriId: 1,
      );

      final dariMap = Catatan.fromMap(c.toMap());
      expect(dariMap.topik, 'Enkripsi Simetris');
      expect(dariMap.favorit, isTrue);
      expect(dariMap.jadwalId, 5);
      expect(dariMap.kategoriId, 1);

      final teks = dariMap.formatEkspor(
        namaKategori: 'Materi Kuliah',
        infoJadwal: '110700 • Rabu 20:30 - 22:00',
      );
      expect(teks, contains('[Kriptografi] Pertemuan 1'));
      expect(teks, contains('Kategori: Materi Kuliah'));
      expect(teks, contains('Topik: Enkripsi Simetris'));
      expect(teks, contains('Mempelajari enkripsi klasik'));
    },
  );

  test('copyWith memperbarui nilai dengan tepat', () {
    final tgl = DateTime(2026, 10, 29, 19, 0);
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
      favorit: true,
    );

    expect(diubah.id, 1);
    expect(diubah.mataKuliah, 'Jaringan Nirkabel');
    expect(diubah.judul, 'Topik Baru');
    expect(diubah.isi, 'Catatan Baru');
    expect(diubah.favorit, isTrue);
  });
}
