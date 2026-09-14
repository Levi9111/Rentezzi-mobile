import 'package:flutter/material.dart';
import '../core/localization/app_translations.dart';
import '../core/services/storage_service.dart';

enum TextScaleOption {
  standard(1.0, 'Standard', 'সাধারণ'),
  large(1.18, 'Large', 'বড়'),
  extraLarge(1.35, 'Extra Large (Elder)', 'খুব বড় (সহজ মোড)');

  final double scale;
  final String labelEn;
  final String labelBn;
  const TextScaleOption(this.scale, this.labelEn, this.labelBn);

  String getLabel(String lang) => lang == 'bn' ? labelBn : labelEn;
}

class AppProvider extends ChangeNotifier {
  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  double _fontScale = 1.0;

  String get language => _language;
  bool get isBengali => _language == 'bn';
  bool get isBn => _language == 'bn';
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  double get fontScale => _fontScale;
  bool get isElderMode => _fontScale >= 1.20;

  AppProvider() {
    _loadPreferences();
  }

  void _loadPreferences() {
    _language = StorageService.getLanguage();
    final modeStr = StorageService.getThemeMode();
    if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (modeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _fontScale = StorageService.getFontScale();
    notifyListeners();
  }

  /// Instant Language toggle between English and Bengali
  Future<void> toggleLanguage() async {
    final next = _language == 'en' ? 'bn' : 'en';
    await setLanguage(next);
  }

  Future<void> setLanguage(String langCode) async {
    if (_language == langCode) return;
    _language = langCode;
    await StorageService.saveLanguage(langCode);
    notifyListeners();
  }

  /// Toggle Dark / Light mode
  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.system ? 'system' : 'light');
    await StorageService.saveThemeMode(str);
    notifyListeners();
  }

  /// Set Text Size / Font Scale
  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await StorageService.saveFontScale(scale);
    notifyListeners();
  }

  /// One-tap Elder Mode Toggle
  Future<void> toggleElderMode() async {
    if (isElderMode) {
      await setFontScale(1.0);
    } else {
      await setFontScale(1.25);
    }
  }

  /// Translate a key with current active locale
  String tr(String key) {
    return AppTranslations.get(key, _language);
  }
}
