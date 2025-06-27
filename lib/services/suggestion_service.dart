import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  static final Map<String, String> keywordCategoryMap = {
    'ปวดไหล่': 'กายภาพบำบัดระบบกระดูกและกล้ามเนื้อ',
    'ปวดหลัง': 'กายภาพบำบัดระบบประสาท',
    'ปวดเข่า': 'กายภาพบำบัดผู้สูงอายุ',
    'บาดเจ็บกีฬา': 'กายภาพบำบัดบาดเจ็บทางการกีฬา',
  };

  static String getCategory(String keyword) {
    return keywordCategoryMap[keyword] ?? 'ไม่พบหมวดหมู่ที่เกี่ยวข้อง';
  }

  static Future<void> saveSuggestion(String keyword, {bool skip = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getStringList('suggestion_done') ?? [];
    final skipList = prefs.getStringList('suggestion_skip') ?? [];

    if (!done.contains(keyword)) {
      done.add(keyword);
      await prefs.setStringList('suggestion_done', done);
    }

    if (skip) {
      await prefs.setStringList('suggestion_skip', [...skipList, keyword]);
    }
  }
}
