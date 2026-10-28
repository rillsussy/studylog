import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studylog/screens/form_catatan_screen.dart';

void main() {
  testWidgets('Validasi menolak input kosong dan spasi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FormCatatanScreen()));

    await tester.enterText(find.byKey(const Key('field_judul')), '   ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Mata kuliah wajib diisi'), findsOneWidget);
    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(find.text('Isi catatan wajib diisi'), findsOneWidget);
  });

  testWidgets('Input valid menampilkan hasil', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FormCatatanScreen()));

    await tester.enterText(find.byKey(const Key('field_mata_kuliah')), 'Kriptografi');
    await tester.enterText(find.byKey(const Key('field_judul')), 'Caesar Cipher');
    await tester.enterText(find.byKey(const Key('field_isi')), 'Geser huruf');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Caesar Cipher'), findsWidgets);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);
  });
}
