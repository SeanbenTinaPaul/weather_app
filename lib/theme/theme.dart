import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF6F6F6), // Dimmed White
  primaryColor: const Color(0xFFF6F6F6), // Dimmed White
  colorScheme: ColorScheme.light(
    primary: Colors.white,
    secondary: Color(0xFFd98f1e),
    tertiary: Color(0xFF1a1a16),
    shadow: Colors.grey.withValues(alpha: 0.3),
    surface: Color.fromARGB(255, 241, 241, 241),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF333333)), // Soft Black
    bodyMedium: TextStyle(color: Color.fromARGB(255, 96, 96, 96)), // Dark Grey
    titleLarge: TextStyle(
      color: Color(0xFF333333),
      fontWeight: FontWeight.bold,
    ),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF1a1a16), // Old Dark Grey
  primaryColor: Color(0xFF3C1F67), // gradientMiddle
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF3C1F67), // gradientTop
    secondary: const Color.fromARGB(255, 194, 109, 53),
    tertiary: Color(0xFFEEEEEE),
    shadow: Color.fromARGB(255, 70, 70, 70),
    surface: Color.fromARGB(255, 19, 19, 19),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
);
