import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferences {
  const LocalePreferences._();

  static const key = 'itarevo_app_language';

  static Future<String?> loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, languageCode);
  }
}
