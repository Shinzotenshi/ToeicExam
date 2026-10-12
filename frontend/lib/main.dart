import 'package:flutter/material.dart';
import 'screens/exam_list_screen.dart';

void main() {
  runApp(const ToeicExamApp());
}

class ToeicExamApp extends StatelessWidget {
  const ToeicExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Reading Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF1E3A8A),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const ExamListScreen(),
    );
  }
}
