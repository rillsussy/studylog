import 'package:flutter/foundation.dart';

import '../data/kategori_repository.dart';
import '../models/kategori.dart';

/// ViewModel kategori/tag catatan.
class KategoriViewModel extends ChangeNotifier {
  final KategoriRepository _repo;
  KategoriViewModel(this._repo);

  List<Kategori> _items = [];
  List<Kategori> get items => List.unmodifiable(_items);

  /// Kategori default ('Materi Kuliah') untuk pengisian otomatis.
  Kategori? get defaultKategori {
    for (final k in _items) {
      if (k.nama == 'Materi Kuliah') return k;
    }
    return _items.isEmpty ? null : _items.first;
  }

  Kategori? cariById(int? id) {
    if (id == null) return null;
    for (final k in _items) {
      if (k.id == id) return k;
    }
    return null;
  }

  Future<void> muat() async {
    _items = await _repo.semua();
    notifyListeners();
  }

  Future<void> tambahKategori(String nama, {int warna = 0xFF3949AB}) async {
    final bersih = nama.trim();
    if (bersih.isEmpty) return;
    await _repo.tambah(Kategori(nama: bersih, warna: warna));
    await muat();
  }
}
