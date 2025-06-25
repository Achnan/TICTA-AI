import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static bool enableTechnicalFeedback = true;
  static bool enableEncouragement = true;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enableTechnicalFeedback = prefs.getBool('enableTechnicalFeedback') ?? true;
    enableEncouragement = prefs.getBool('enableEncouragement') ?? true;
  }

  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableTechnicalFeedback', enableTechnicalFeedback);
    await prefs.setBool('enableEncouragement', enableEncouragement);
  }
}
