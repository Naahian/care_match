import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';

final appPreferences = PreferencesController();

class PreferencesController extends ChangeNotifier {
  PreferencesController({StorageService? storage})
    : _storage = storage ?? StorageService() {
    _restore();
  }
  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.light;
  bool _largerText = false;
  bool _shareAnonymousData = false;
  String _language = 'English';
  ThemeMode get themeMode => _themeMode;
  bool get largerText => _largerText;
  bool get shareAnonymousData => _shareAnonymousData;
  String get language => _language;
  Locale get locale => Locale(_language == 'Bangla' ? 'bn' : 'en');

  Future<void> _restore() async {
    try {
      _themeMode = ThemeMode.values.byName(
        await _storage.readString(key: 'settings.theme') ?? 'light',
      );
      _largerText =
          await _storage.readBool(key: 'settings.largerText') ?? false;
      _shareAnonymousData =
          await _storage.readBool(key: 'settings.shareAnonymousData') ?? false;
      _language =
          await _storage.readString(key: 'settings.language') ?? 'English';
      notifyListeners();
    } catch (_) {}
  }

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
    _storage.writeString(key: 'settings.theme', value: value.name);
  }

  void setLargerText(bool value) {
    _largerText = value;
    notifyListeners();
    _storage.writeBool(key: 'settings.largerText', value: value);
  }

  void setShareAnonymousData(bool value) {
    _shareAnonymousData = value;
    notifyListeners();
    _storage.writeBool(key: 'settings.shareAnonymousData', value: value);
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
    _storage.writeString(key: 'settings.language', value: value);
  }
}
