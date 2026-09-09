import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_profile';
  static const String _keyLanguage = 'app_language';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyFontScale = 'app_font_scale';
  static const String _keyCustomBaseUrl = 'custom_base_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(_keyAccessToken, accessToken);
    await _prefs?.setString(_keyRefreshToken, refreshToken);
  }

  static String? getAccessToken() => _prefs?.getString(_keyAccessToken);
  static String? getRefreshToken() => _prefs?.getString(_keyRefreshToken);

  static Future<void> clearTokens() async {
    await _prefs?.remove(_keyAccessToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyUser);
  }

  // User profile
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs?.setString(_keyUser, jsonEncode(userMap));
  }

  static Map<String, dynamic>? getUser() {
    final userStr = _prefs?.getString(_keyUser);
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Language: 'en' or 'bn'
  static Future<void> saveLanguage(String langCode) async {
    await _prefs?.setString(_keyLanguage, langCode);
  }

  static String getLanguage() => _prefs?.getString(_keyLanguage) ?? 'en';

  // Theme: 'light', 'dark', 'system'
  static Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }

  static String getThemeMode() => _prefs?.getString(_keyThemeMode) ?? 'light';

  // Font Scale: 1.0 (standard), 1.15 (large), 1.30 (extra large)
  static Future<void> saveFontScale(double scale) async {
    await _prefs?.setDouble(_keyFontScale, scale);
  }

  static double getFontScale() => _prefs?.getDouble(_keyFontScale) ?? 1.0;

  // Custom Base URL
  static Future<void> saveBaseUrl(String url) async {
    await _prefs?.setString(_keyCustomBaseUrl, url);
  }

  static String? getCustomBaseUrl() => _prefs?.getString(_keyCustomBaseUrl);
}
