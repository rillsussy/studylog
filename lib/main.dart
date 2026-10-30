import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catatan_repository.dart';
import 'data/database_helper.dart';
import 'data/jadwal_repository.dart';
import 'data/kategori_repository.dart';
import 'screens/beranda_page.dart';
import 'viewmodels/catatan_view_model.dart';
import 'viewmodels/jadwal_view_model.dart';
import 'viewmodels/kategori_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final helper = DatabaseHelper.instance;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JadwalViewModel(JadwalRepository(helper))..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => KategoriViewModel(KategoriRepository(helper))..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CatatanViewModel(CatatanRepository(helper))..muatCatatan(),
        ),
      ],
      child: const StudyLogApp(),
    ),
  );
}

class StudyLogApp extends StatelessWidget {
  const StudyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4158D0)),
        useMaterial3: true,
      ),
      home: const BerandaPage(),
    );
  }
}
