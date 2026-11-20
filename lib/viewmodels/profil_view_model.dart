import 'package:flutter/foundation.dart';

import '../data/profil_repository.dart';
import '../models/profil.dart';

class ProfilViewModel extends ChangeNotifier {
  final ProfilRepository _repo;

  ProfilViewModel(this._repo);

  Profil _profil = Profil.defaultProfil();
  bool _isLoading = false;

  Profil get profil => _profil;
  bool get isLoading => _isLoading;

  Future<void> muat() async {
    _isLoading = true;
    notifyListeners();
    _profil = await _repo.ambil();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> perbarui(Profil baru) async {
    _profil = baru;
    notifyListeners();
    await _repo.simpan(baru);
  }
}
