import 'package:flutter/foundation.dart';

import '../data/catatan_repository.dart';
import '../models/catatan.dart';

/// ViewModel: menjembatani UI dengan Repository dan menyimpan state layar.
class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository _repo;
  CatatanViewModel(this._repo);

  List<Catatan> _items = [];
  List<Catatan> _hasil = [];
  bool _memuat = false;
  String? _galat;
  String _kataKunci = '';
  int? _filterJadwalId;
  int _permintaan = 0;

  /// Seluruh catatan.
  List<Catatan> get items => List.unmodifiable(_items);

  /// Catatan setelah pencarian / filter diterapkan.
  List<Catatan> get hasil => List.unmodifiable(_hasil);

  bool get memuat => _memuat;
  String? get galat => _galat;
  String get kataKunci => _kataKunci;
  int? get filterJadwalId => _filterJadwalId;
  bool get adaFilter => _kataKunci.trim().isNotEmpty || _filterJadwalId != null;

  Catatan? cariById(int id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> muat() async {
    final token = ++_permintaan;
    _memuat = true;
    _galat = null;
    notifyListeners();
    try {
      final items = await _repo.semua();
      final hasil = adaFilter
          ? await _repo.cari(kataKunci: _kataKunci, jadwalId: _filterJadwalId)
          : items;
      // Abaikan hasil lama jika sudah ada permintaan yang lebih baru.
      if (token != _permintaan) return;
      _items = items;
      _hasil = hasil;
    } catch (e) {
      if (token != _permintaan) return;
      _galat = 'Gagal memuat catatan: $e';
    } finally {
      if (token == _permintaan) {
        _memuat = false;
        notifyListeners();
      }
    }
  }

  Future<void> setKataKunci(String value) async {
    _kataKunci = value;
    await muat();
  }

  Future<void> setFilterJadwal(int? jadwalId) async {
    _filterJadwalId = jadwalId;
    await muat();
  }

  Future<void> resetFilter() async {
    if (!adaFilter) return;
    _kataKunci = '';
    _filterJadwalId = null;
    await muat();
  }

  Future<void> tambah(Catatan c) async {
    await _repo.tambah(c);
    await muat();
  }

  Future<void> ubah(Catatan c) async {
    await _repo.ubah(c);
    await muat();
  }

  Future<void> hapus(int id) async {
    await _repo.hapus(id);
    await muat();
  }
}
