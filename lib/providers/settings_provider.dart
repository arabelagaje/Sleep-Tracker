import 'package:flutter/material.dart';

import '../services/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  final DatabaseHelper _db;

  static const minGoal = Duration(hours: 4);
  static const maxGoal = Duration(hours: 12);
  static const goalStep = Duration(minutes: 30);

  Duration _goal = const Duration(hours: 8);
  bool _ratePrompt = true;
  ThemeMode _themeMode = ThemeMode.system;

  Duration get goal => _goal;
  bool get ratePrompt => _ratePrompt;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final s = await _db.getSettings();
    _goal = Duration(minutes: int.tryParse(s['goal_minutes'] ?? '') ?? 480);
    _ratePrompt = (s['rate_prompt'] ?? 'true') == 'true';
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == s['theme_mode'],
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setGoal(Duration goal) async {
    _goal = goal < minGoal ? minGoal : (goal > maxGoal ? maxGoal : goal);
    notifyListeners();
    await _db.setSetting('goal_minutes', '${_goal.inMinutes}');
  }

  Future<void> setRatePrompt(bool on) async {
    _ratePrompt = on;
    notifyListeners();
    await _db.setSetting('rate_prompt', '$on');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _db.setSetting('theme_mode', mode.name);
  }
}
