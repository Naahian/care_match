import 'package:flutter/material.dart';

/// Session preferences until persistent settings are available.
final appPreferences = PreferencesController();

class PreferencesController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _largerText = false;
  bool _shareAnonymousData = true;

  ThemeMode get themeMode => _themeMode;
  bool get largerText => _largerText;
  bool get shareAnonymousData => _shareAnonymousData;

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  void setLargerText(bool value) {
    _largerText = value;
    notifyListeners();
  }

  void setShareAnonymousData(bool value) {
    _shareAnonymousData = value;
    notifyListeners();
  }
}
