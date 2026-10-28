import 'package:flutter/foundation.dart';

import '../models/catatan.dart';

/// Milestone 02: state catatan lintas layar (in-memory).
/// Data hilang ketika aplikasi di-full restart.
class CatatanStore extends ChangeNotifier {
  final List<Catatan> _items = [];
  int _nextId = 1;

  List<Catatan> get items => List.unmodifiable(_items.reversed);

  Catatan? cariById(int id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  void tambah(Catatan catatan) {
    _items.add(catatan.copyWith(id: _nextId++));
    notifyListeners();
  }

  void ubah(Catatan catatan) {
    final i = _items.indexWhere((c) => c.id == catatan.id);
    if (i == -1) return;
    _items[i] = catatan;
    notifyListeners();
  }

  void hapus(int id) {
    _items.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
