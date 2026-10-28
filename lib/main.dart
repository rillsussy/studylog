import 'package:flutter/material.dart';

import 'screens/form_catatan_screen.dart';

void main() {
  runApp(const StudyLogApp());
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
      home: const FormCatatanScreen(),
    );
  }
}
