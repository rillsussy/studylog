import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/beranda_screen.dart';
import 'state/catatan_store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CatatanStore(),
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
