import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  static final Map<String, String> keywordCategoryMap = {
    'ปวดกล้ามเนื้อ': 'Ortho',
    'ข้อเสื่อม': 'Ortho',
    'หายใจลำบาก': 'Cardio',
    'เหนื่อยง่าย': 'Cardio',
    'แขนขาอ่อนแรง': 'Neuro',
    'พูดไม่ชัด': 'Neuro',
    'เดินลำบาก': 'Geriatric',
    'ทรงตัวไม่ดี': 'Geriatric',
  };

  static String? getCategory(String keyword) {
    return keywordCategoryMap[keyword];
  }

  static Future<void> saveSuggestion(String keyword, {bool skip = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final category = getCategory(keyword);
    if (category != null) {
      await prefs.setString('suggested_category', category);
    }
    await prefs.setBool('suggestion_done', true);
    if (skip) await prefs.setBool('suggestion_skip', true);
  }

  static Future<bool> shouldSkip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('suggestion_skip') ?? false;
  }

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('suggestion_done') ?? false;
  }

  static Future<String?> getSavedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('suggested_category');
  }
}
