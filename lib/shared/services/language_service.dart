import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'am', 'name': 'Amharic', 'nativeName': 'አማርኛ'},
    {'code': 'om', 'name': 'Oromo', 'nativeName': 'Afaan Oromoo'},
  ];

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null && _isLanguageSupported(languageCode)) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading the language, use default (English)
      _currentLocale = const Locale('en');
    }
  }

  bool _isLanguageSupported(String languageCode) {
    return supportedLanguages.any((lang) => lang['code'] == languageCode);
  }

  Future<bool> changeLanguage(String languageCode) async {
    if (!_isLanguageSupported(languageCode)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      _currentLocale = Locale(languageCode);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String getLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'name': 'Unknown'},
    );
    return language['name'] ?? 'Unknown';
  }

  String getLanguageNativeName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'nativeName': 'Unknown'},
    );
    return language['nativeName'] ?? 'Unknown';
  }

  bool isCurrentLanguage(String languageCode) {
    return _currentLocale.languageCode == languageCode;
  }
}