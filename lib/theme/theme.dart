import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF1a1a16),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF1a1a16),
    secondary: Color(0xFFd98f1e),
    tertiary: Color(0xFF1a1a16),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF0F0D1C), // gradientBottom
  primaryColor: Color(0xFF3C1F67), // gradientMiddle
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF3C1F67),
    secondary: const Color.fromARGB(255, 194, 109, 53), // gradientTop
    surface: Color(0xFF1E1E1E),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
);
