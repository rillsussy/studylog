import 'package:flutter/foundation.dart';

import '../data/catatan_repository.dart';
import '../models/catatan.dart';

/// ViewModel: menjembatani UI dengan Repository dan menyimpan state layar.
class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository repository;
  CatatanViewModel(this.repository);

  List<Catatan> _catatan = [];
  List<Catatan> _hasil = [];
  bool isLoading = false;
  String? error;

  String _kataKunci = '';
  int? _filterJadwalId;
  int? _filterKategoriId;
  bool _hanyaFavorit = false;
  bool _urutTerbaru = true;
  int _permintaan = 0;

  /// Seluruh catatan (sesuai penamaan Workbook Bab 5.8 / Lampiran 10).
  List<Catatan> get catatan => List.unmodifiable(_catatan);

  /// Catatan setelah pencarian, filter, dan pengurutan diterapkan.
  List<Catatan> get hasil => List.unmodifiable(_hasil);

  String get kataKunci => _kataKunci;
  int? get filterJadwalId => _filterJadwalId;
  int? get filterKategoriId => _filterKategoriId;
  bool get hanyaFavorit => _hanyaFavorit;
  bool get urutTerbaru => _urutTerbaru;

  bool get adaFilter =>
      _kataKunci.trim().isNotEmpty ||
      _filterJadwalId != null ||
      _filterKategoriId != null ||
      _hanyaFavorit;

  int get jumlahFavorit => _catatan.where((c) => c.favorit).length;

  Catatan? cariById(int id) {
    for (final c in _catatan) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> muatCatatan() async {
    final token = ++_permintaan;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final semua = await repository.semua(terbaru: _urutTerbaru);
      final tersaring = adaFilter
          ? await repository.cari(
              kataKunci: _kataKunci,
              jadwalId: _filterJadwalId,
              kategoriId: _filterKategoriId,
              hanyaFavorit: _hanyaFavorit,
              terbaru: _urutTerbaru,
            )
          : semua;
      if (token != _permintaan) return;
      _catatan = semua;
      _hasil = tersaring;
    } catch (e) {
      if (token != _permintaan) return;
      error = 'Tidak dapat membaca catatan: $e';
    } finally {
      if (token == _permintaan) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setKataKunci(String value) async {
    _kataKunci = value;
    await muatCatatan();
  }

  Future<void> setFilterJadwal(int? jadwalId) async {
    _filterJadwalId = jadwalId;
    await muatCatatan();
  }

  Future<void> setFilterKategori(int? kategoriId) async {
    _filterKategoriId = kategoriId;
    await muatCatatan();
  }

  Future<void> setHanyaFavorit(bool aktif) async {
    _hanyaFavorit = aktif;
    await muatCatatan();
  }

  Future<void> setUrutTerbaru(bool terbaru) async {
    if (_urutTerbaru == terbaru) return;
    _urutTerbaru = terbaru;
    await muatCatatan();
  }

  Future<void> resetFilter() async {
    if (!adaFilter) return;
    _kataKunci = '';
    _filterJadwalId = null;
    _filterKategoriId = null;
    _hanyaFavorit = false;
    await muatCatatan();
  }

  Future<void> tambahCatatan(Catatan baru) async {
    await repository.tambah(baru);
    await muatCatatan();
  }

  Future<void> ubahCatatan(Catatan catatan) async {
    await repository.ubah(catatan);
    await muatCatatan();
  }

  Future<void> toggleFavorit(Catatan catatan) async {
    if (catatan.id == null) return;
    await repository.setFavorit(catatan.id!, !catatan.favorit);
    await muatCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    await repository.hapus(id);
    await muatCatatan();
  }
}
