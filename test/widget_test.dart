import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:studylog/main.dart';
import 'package:studylog/viewmodels/catatan_view_model.dart';
import 'package:studylog/viewmodels/jadwal_view_model.dart';
import 'package:studylog/viewmodels/kategori_view_model.dart';

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
      create: (_) => KategoriViewModel(FakeKategoriRepository())..muat(),
    ),
    ChangeNotifierProvider(
      create: (_) => CatatanViewModel(FakeCatatanRepository())..muatCatatan(),
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
  testWidgets('Validasi menolak input kosong, spasi, dan topik < 3 karakter', (
    tester,
  ) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuPagi));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_judul')), '   ');
    await tester.enterText(find.byKey(const Key('field_topik')), 'ab');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Mata kuliah wajib diisi'), findsOneWidget);
    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(find.text('Topik minimal 3 karakter'), findsOneWidget);
    expect(find.text('Isi catatan wajib diisi'), findsOneWidget);
  });

  testWidgets(
    'Saat kuliah berlangsung: Catat Sekarang -> Ubah -> Hapus (CRUD)',
    (tester) async {
      _layarBesar(tester);
      String? disalin;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            disalin = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(_app(rabuKriptografi));
      await tester.pumpAndSettle();

      expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
      await tester.tap(find.byKey(const Key('tombol_catat_sekarang')));
      await tester.pumpAndSettle();

      // T1 Create: mata kuliah, kategori, & judul terisi; cukup ketik isi.
      expect(find.text('Kriptografi'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('field_isi')), 'RSA dan AES');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // T2 Read: daftar & detail.
      await tester.tap(find.text('Lihat Daftar Catatan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Total catatan: 1'), findsOneWidget);
      await tester.tap(find.textContaining('Pertemuan'));
      await tester.pumpAndSettle();
      expect(find.text('RSA dan AES'), findsOneWidget);
      expect(find.textContaining('A301'), findsOneWidget);

      // Ekspor teks ke clipboard.
      await tester.tap(find.byKey(const Key('tombol_salin')));
      await tester.pumpAndSettle();
      expect(disalin, contains('RSA dan AES'));

      // T3 Update: ubah judul catatan.
      await tester.tap(find.byKey(const Key('tombol_ubah')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('field_judul')),
        'Kriptografi Modern',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Kriptografi Modern'), findsOneWidget);

      // T4 Delete Batal: catatan tetap ada.
      await tester.tap(find.byKey(const Key('tombol_hapus')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Kriptografi Modern'), findsOneWidget);

      // T5 Delete Setuju: catatan terhapus dari daftar.
      await tester.tap(find.byKey(const Key('tombol_hapus')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada catatan'), findsOneWidget);
    },
  );

  testWidgets('Di luar jam kuliah: info kuliah berikutnya & halaman Tentang', (
    tester,
  ) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuPagi));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada perkuliahan saat ini'), findsOneWidget);
    expect(find.textContaining('Berikutnya: Kriptografi'), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(8));

    await tester.tap(find.byKey(const Key('tombol_tentang')));
    await tester.pumpAndSettle();
    expect(find.text('Tentang Aplikasi'), findsOneWidget);
  });

  testWidgets('Pencarian, favorit, dan pengurutan daftar catatan', (
    tester,
  ) async {
    _layarBesar(tester);
    await tester.pumpWidget(_app(rabuPagi));
    await tester.pumpAndSettle();

    Future<void> catat(String chip, String isi) async {
      await tester.tap(find.widgetWithText(ActionChip, chip));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('field_isi')), isi);
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    }

    await catat('Kriptografi', 'Materi RSA');
    await catat('Jaringan Nirkabel', 'Materi WiFi');

    await tester.tap(find.text('Lihat Daftar Catatan'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));

    // Tandai item pertama sebagai favorit lalu filter favorit.
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chip_filter_favorit')));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.byKey(const Key('chip_filter_favorit')));
    await tester.pumpAndSettle();

    // Ubah urutan Terbaru <-> Terlama.
    await tester.tap(find.byKey(const Key('tombol_urut')));
    await tester.pumpAndSettle();
    expect(find.textContaining('(Terlama)'), findsOneWidget);

    // Pencarian kata kunci.
    await tester.enterText(find.byKey(const Key('field_cari')), 'jaringan');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);

    await tester.enterText(find.byKey(const Key('field_cari')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
  });
}
