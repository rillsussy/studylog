import 'package:flutter/foundation.dart';

import '../data/catatan_repository.dart';
import '../models/catatan.dart';

/// ViewModel: menjembatani UI dengan Repository dan menyimpan state layar.
class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository _repo;
  CatatanViewModel(this._repo);

  List<Catatan> _items = [];
  bool _memuat = false;
  String? _galat;

  List<Catatan> get items => List.unmodifiable(_items);
  bool get memuat => _memuat;
  String? get galat => _galat;

  Catatan? cariById(int id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> muat() async {
    _memuat = true;
    _galat = null;
    notifyListeners();
    try {
      _items = await _repo.semua();
    } catch (e) {
      _galat = 'Gagal memuat catatan: $e';
    } finally {
      _memuat = false;
      notifyListeners();
    }
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
