import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  static ThemeMode getThemeMode() {
    final box = Hive.box(_boxName);
    final themeIndex = box.get(_themeKey, defaultValue: 0) as int;
    return ThemeMode.values[themeIndex];
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final box = Hive.box(_boxName);
    await box.put(_themeKey, mode.index);
  }

  static Future<void> toggleTheme() async {
    final currentMode = getThemeMode();
    final newMode = currentMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
