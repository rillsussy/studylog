import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catatan_repository.dart';
import 'data/database_helper.dart';
import 'screens/beranda_screen.dart';
import 'viewmodels/catatan_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = CatatanRepository(DatabaseHelper());
  runApp(
    ChangeNotifierProvider(
      create: (_) => CatatanViewModel(repo)..muat(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BerandaScreen(),
    );
  }
}
