import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static bool enableTechnicalFeedback = true;
  static bool enableEncouragement = true;
  static bool enableFallDetection = true;
  static String emergencyPhone = "1669";

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enableTechnicalFeedback = prefs.getBool('enableTechnicalFeedback') ?? true;
    enableEncouragement = prefs.getBool('enableEncouragement') ?? true;
    enableFallDetection = prefs.getBool('enableFallDetection') ?? true;
    emergencyPhone = prefs.getString('emergencyPhone') ?? "1669";
  }

  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableTechnicalFeedback', enableTechnicalFeedback);
    prefs.setBool('enableEncouragement', enableEncouragement);
    prefs.setBool('enableFallDetection', enableFallDetection);
    prefs.setString('emergencyPhone', emergencyPhone);
  }
}
