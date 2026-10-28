import 'package:flutter_test/flutter_test.dart';

import 'package:studylog/utils/status_kuliah.dart';

import 'fakes.dart';

void main() {
  // 28 Oktober 2026 adalah hari Rabu.
  StatusKuliah pada(int hari, int jam, int menit) => StatusKuliah.hitung(
    jadwalDenganId,
    DateTime(2026, 10, 26 + hari - 1, jam, menit),
  );

  test('Senin 19:30 -> Sistem Manajemen Basis Data sedang berlangsung', () {
    final s = pada(1, 19, 30);
    expect(s.aktif?.nama, 'Sistem Manajemen Basis Data');
    expect(s.segeraDimulai, isFalse);
    expect(s.berikutnya?.nama, 'Teknologi Aplikasi Bergerak');
  });

  test('Senin 20:30 tepat -> berpindah ke Teknologi Aplikasi Bergerak', () {
    expect(pada(1, 20, 30).aktif?.nama, 'Teknologi Aplikasi Bergerak');
  });

  test('Rabu 20:20 -> Kriptografi segera dimulai', () {
    final s = pada(3, 20, 20);
    expect(s.aktif?.nama, 'Kriptografi');
    expect(s.segeraDimulai, isTrue);
  });

  test('Rabu 19:30 -> tidak ada kuliah (Rabu hanya 20:30)', () {
    final s = pada(3, 19, 30);
    expect(s.aktif, isNull);
    expect(s.berikutnya?.nama, 'Kriptografi');
  });

  test('Jumat 22:00 -> selesai, berikutnya Senin depan', () {
    final s = pada(5, 22, 0);
    expect(s.aktif, isNull);
    expect(s.berikutnya?.nama, 'Sistem Manajemen Basis Data');
    expect(s.waktuBerikutnya, DateTime(2026, 11, 2, 19, 0));
  });
}
