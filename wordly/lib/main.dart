import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const WordlyApp());
}

class WordlyApp extends StatelessWidget {
  const WordlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Wordly работает! бэм'),
        ),
      ),
    );
  }
}
