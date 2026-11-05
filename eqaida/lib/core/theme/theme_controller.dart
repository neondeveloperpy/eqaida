// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's light/dark choice and remembers it between launches.
/// Until the user picks something, the app follows the system setting.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Call once before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_key)) {
      case 'light':
        _mode = ThemeMode.light;
      case 'dark':
        _mode = ThemeMode.dark;
      default:
        _mode = ThemeMode.system;
    }
  }

  /// True when dark colours are actually showing (also when following system).
  bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Flip between light and dark based on what is currently on screen.
  Future<void> toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
  }
}
