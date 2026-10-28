import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:studylog/main.dart';
import 'package:studylog/state/catatan_store.dart';

Widget _app() => ChangeNotifierProvider(
      create: (_) => CatatanStore(),
      child: const StudyLogApp(),
    );

void main() {
  testWidgets('Validasi menolak input kosong dan spasi', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_judul')), '   ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Mata kuliah wajib diisi'), findsOneWidget);
    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(find.text('Isi catatan wajib diisi'), findsOneWidget);
  });

  testWidgets('Alur tambah -> daftar -> detail', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_mata_kuliah')), 'Kriptografi');
    await tester.enterText(find.byKey(const Key('field_judul')), 'Caesar Cipher');
    await tester.enterText(find.byKey(const Key('field_isi')), 'Geser huruf');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Daftar Catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Caesar Cipher'), findsOneWidget);

    await tester.tap(find.text('Caesar Cipher'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Catatan'), findsOneWidget);
    expect(find.text('Geser huruf'), findsOneWidget);
  });
}
