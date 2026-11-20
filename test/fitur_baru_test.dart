import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studylog/models/jadwal.dart';
import 'package:studylog/models/profil.dart';
import 'package:studylog/screens/jadwal_page.dart';
import 'package:studylog/screens/tentang_page.dart';
import 'package:studylog/viewmodels/jadwal_view_model.dart';

import 'fakes.dart';

class FakeProfilRepository {
  Profil profil = Profil.defaultProfil();

  Future<Profil> ambil() async => profil;
  Future<void> simpan(Profil p) async {
    profil = p;
  }
}

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('JadwalViewModel CRUD Tambah & Hapus', () {
    test(
      'tambahJadwal dan hapusJadwal bekerja dengan FakeJadwalRepository',
      () async {
        final repo = FakeJadwalRepository();
        final vm = JadwalViewModel(repo, otomatis: false);
        await vm.muat();

        final totalAwal = vm.items.length;
        expect(totalAwal, greaterThan(0));

        // Tambah jadwal baru
        const baru = Jadwal(
          hari: 1,
          mulai: 480,
          selesai: 580,
          kode: 'IFB99',
          nama: 'Pemrograman Web Lanjut',
          sks: 3,
          kelas: 'IFB5J',
          ruang: 'LAB C',
          dosen: 'Dosen Pengampu Web',
        );

        final newId = await vm.tambahJadwal(baru);
        expect(vm.items.length, totalAwal + 1);
        expect(vm.items.any((j) => j.nama == 'Pemrograman Web Lanjut'), isTrue);

        // Hapus jadwal yang baru saja ditambahkan
        await vm.hapusJadwal(newId);
        expect(vm.items.length, totalAwal);
        expect(
          vm.items.any((j) => j.nama == 'Pemrograman Web Lanjut'),
          isFalse,
        );
      },
    );
  });

  group('Profil Mahasiswa Model & ViewModel', () {
    test('Profil default dan copyWith', () {
      final p = Profil.defaultProfil();
      expect(p.nama, 'Ryanda Hermawan');
      expect(p.nim, '2411068');

      final updated = p.copyWith(nama: 'Dewi Nofitta', nim: '2411065');
      expect(updated.nama, 'Dewi Nofitta');
      expect(updated.nim, '2411065');
      expect(updated.kelas, 'IFB5J');
    });
  });

  group('Widget Test JadwalPage & Edit Profil TentangPage', () {
    testWidgets(
      'JadwalPage menampilkan daftar jadwal dan bisa membuka dialog tambah',
      (tester) async {
        _setViewport(tester);
        final repo = FakeJadwalRepository();
        final jadwalVm = JadwalViewModel(repo, otomatis: false)..muat();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: jadwalVm,
              child: const JadwalPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Jadwal Kuliah'), findsOneWidget);
        expect(find.byType(Card), findsWidgets);

        // Buka dialog tambah jadwal
        await tester.tap(find.byKey(const Key('tombol_tambah_jadwal_appbar')));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Mata Kuliah'), findsOneWidget);
        expect(find.byKey(const Key('field_jadwal_nama')), findsOneWidget);

        // Batal
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(find.text('Tambah Mata Kuliah'), findsNothing);
      },
    );

    testWidgets(
      'TentangPage bisa mengedit dan memperbarui identitas profil mahasiswa',
      (tester) async {
        _setViewport(tester);
        await tester.pumpWidget(const MaterialApp(home: TentangPage()));
        await tester.pumpAndSettle();

        expect(find.text('Tentang Aplikasi'), findsOneWidget);
        expect(find.byKey(const Key('label_profil_nama')), findsOneWidget);

        // Buka dialog edit profil
        await tester.tap(find.text('Edit Profil'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Data Profil'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('field_profil_nama')),
          'Bintang Sahda',
        );
        await tester.enterText(
          find.byKey(const Key('field_profil_nim')),
          '2411025',
        );

        await tester.tap(find.byKey(const Key('tombol_simpan_profil')));
        await tester.pumpAndSettle();

        expect(find.text('Bintang Sahda'), findsOneWidget);
        expect(find.text('NIM: 2411025'), findsOneWidget);
      },
    );
  });
}
