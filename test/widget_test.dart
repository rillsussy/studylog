import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:studylog/main.dart';
import 'package:studylog/viewmodels/catatan_viewmodel.dart';
import 'package:studylog/viewmodels/jadwal_viewmodel.dart';

import 'fakes.dart';

Widget _app(DateTime sekarang) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => JadwalViewModel(
        FakeJadwalRepository(),
        jam: () => sekarang,
        otomatis: false,
      )..muat(),
    ),
    ChangeNotifierProvider(
      create: (_) => CatatanViewModel(FakeCatatanRepository())..muat(),
    ),
  ],
  child: const StudyLogApp(),
);

// Rabu 28 Okt 2026.
final rabuKriptografi = DateTime(2026, 10, 28, 20, 45);
final rabuPagi = DateTime(2026, 10, 28, 9, 0);

void _layarBesar(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Validasi menolak input kosong dan spasi', (tester) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuPagi));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_judul')), '   ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Mata kuliah wajib diisi'), findsOneWidget);
    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(find.text('Isi catatan wajib diisi'), findsOneWidget);
  });

  testWidgets('Saat kuliah berlangsung: Catat Sekarang langsung ke form', (
    tester,
  ) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuKriptografi));
    await tester.pumpAndSettle();

    expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tombol_catat_sekarang')));
    await tester.pumpAndSettle();

    // Mata kuliah & judul sudah terisi; cukup tulis isi.
    expect(find.text('Kriptografi'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('field_isi')), 'RSA dan AES');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Daftar Catatan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kriptografi'), findsWidgets);

    await tester.tap(find.textContaining('Pertemuan'));
    await tester.pumpAndSettle();
    expect(find.text('RSA dan AES'), findsOneWidget);
    expect(find.textContaining('A301'), findsOneWidget);
  });

  testWidgets('Di luar jam kuliah: tampil info kuliah berikutnya', (
    tester,
  ) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuPagi));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada perkuliahan saat ini'), findsOneWidget);
    expect(find.textContaining('Berikutnya: Kriptografi'), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(8));
  });
}
