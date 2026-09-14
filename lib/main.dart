import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const OnibusSitioFlorestaApp());
}

class OnibusSitioFlorestaApp extends StatelessWidget {
  const OnibusSitioFlorestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E6B4F),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Ônibus Sítio Floresta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
