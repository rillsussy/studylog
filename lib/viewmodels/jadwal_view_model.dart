import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/jadwal_repository.dart';
import '../models/jadwal.dart';
import '../utils/status_kuliah.dart';

/// ViewModel jadwal: memuat jadwal dan memperbarui status kuliah berkala.
class JadwalViewModel extends ChangeNotifier {
  final JadwalRepository _repo;
  final DateTime Function() _jam;
  final bool otomatis;
  Timer? _timer;

  /// [jam] dapat diganti saat pengujian; [otomatis] mengaktifkan
  /// pembaruan status berkala.
  JadwalViewModel(this._repo, {DateTime Function()? jam, this.otomatis = true})
    : _jam = jam ?? DateTime.now;

  List<Jadwal> _items = [];
  StatusKuliah _status = const StatusKuliah();

  List<Jadwal> get items => List.unmodifiable(_items);
  StatusKuliah get status => _status;

  /// Daftar mata kuliah unik (berdasarkan nama) untuk pilihan cepat.
  List<Jadwal> get mataKuliahUnik {
    final seen = <String>{};
    return _items.where((j) => seen.add(j.nama)).toList();
  }

  Jadwal? cariById(int? id) {
    if (id == null) return null;
    for (final j in _items) {
      if (j.id == id) return j;
    }
    return null;
  }

  Future<void> muat() async {
    _items = await _repo.semua();
    _perbaruiStatus();
    if (!otomatis) return;
    _timer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => _perbaruiStatus(),
    );
  }

  void _perbaruiStatus() {
    _status = StatusKuliah.hitung(_items, _jam());
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
