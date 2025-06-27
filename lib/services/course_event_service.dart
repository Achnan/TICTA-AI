import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theraphy_flutter/main.dart';

class CourseEventService {
  static final List<Map<String, dynamic>> courseList = [
    {
      'name': 'กายภาพบำบัดผู้สูงอายุ',
      'exercises': [
        {
          'title': 'นั่งเหยียดขา (Seated Leg Raise)',
          'slug': 'seated_leg_raise',
          'desc': 'เสริมกล้ามต้นขา',
          'reps': 'ข้างละ 10',
          'duration': '~3 นาที'
        },
        {
          'title': 'เขย่งส้นเท้า (Heel Raise)',
          'slug': 'heel_raise',
          'desc': 'เสริมกล้ามเนื้อน่อง',
          'reps': '10–15 ครั้ง',
          'duration': '~2 นาที'
        },
        {
          'title': 'หมุนไหล่ (Shoulder Rolls)',
          'slug': 'shoulder_rolls',
          'desc': 'ผ่อนคลายข้อไหล่',
          'reps': '10 รอบ หน้า-หลัง',
          'duration': '~2 นาที'
        },
        {
          'title': 'ยกไหล่ (Shoulder Shrug)',
          'slug': 'shoulder_shrug',
          'desc': 'ลดอาการตึงที่ไหล่',
          'reps': '10 ครั้ง',
          'duration': '~2 นาที'
        },
      ]
    },
    {
      'name': 'กายภาพบำบัดระบบกระดูกและกล้ามเนื้อ',
      'exercises': [
        {
          'title': 'เลื่อนแขนบนผนัง (Wall Slide)',
          'slug': 'wall_slide',
          'desc': 'เพิ่มการเคลื่อนไหวของข้อไหล่',
          'reps': '10 ครั้ง',
          'duration': '~3 นาที'
        },
        {
          'title': 'วิดพื้นกับผนัง (Wall Push-Up)',
          'slug': 'wall_push_up',
          'desc': 'เสริมแรงต้นแขน/หัวไหล่',
          'reps': '10–15 ครั้ง',
          'duration': '~3 นาที'
        },
        {
          'title': 'กางแขนด้านข้าง (Shoulder Abduction)',
          'slug': 'shoulder_abduction',
          'desc': 'กางแขนออกข้าง เสริมไหล่',
          'reps': '10 ครั้ง',
          'duration': '~3 นาที'
        },
      ]
    },
    {
      'name': 'กายภาพบำบัดระบบประสาท',
      'exercises': [
        {
          'title': 'ยืนงอเข่า (Standing Knee Flexion)',
          'slug': 'standing_knee_flexion',
          'desc': 'งอกล้ามเนื้อหลังขา',
          'reps': 'ข้างละ 10',
          'duration': '~3 นาที'
        },
        {
          'title': 'ยกขาออกด้านข้าง (Side Leg Raise)',
          'slug': 'side_leg_raise',
          'desc': 'กล้ามเนื้อสะโพก',
          'reps': 'ข้างละ 10',
          'duration': '~2 นาที'
        },
        {
          'title': 'หมุนแขนเป็นวง (Arm Circles)',
          'slug': 'arm_circles',
          'desc': 'เพิ่มความยืดหยุ่นหัวไหล่',
          'reps': '10 รอบ หน้า–หลัง',
          'duration': '~2 นาที'
        },
      ]
    },
    {
      'name': 'กายภาพบำบัดบาดเจ็บทางการกีฬา',
      'exercises': [
        {
          'title': 'งอข้อศอก (Elbow Flexion)',
          'slug': 'elbow_flexion',
          'desc': 'ฝึกงอ-เหยียดข้อศอก',
          'reps': 'ข้างละ 10 ครั้ง',
          'duration': '~2 นาที'
        },
        {
          'title': 'เหยียดแขนขึ้นหน้า (Arm Extension Forward)',
          'slug': 'arm_extension_forward',
          'desc': 'เหยียดแขนหน้า-ชูขึ้น',
          'reps': '10 ครั้ง',
          'duration': '~2 นาที'
        },
      ]
    },
  ];



  static final List<DateTime> _scheduledDates = [];

  static Future<void> scheduleCourseEvent(String courseName, DateTime dateTime) async {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
    final int id = dateTime.millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'แจ้งเตือนคอร์ส',
      'ถึงเวลาฝึกคอร์ส: $courseName แล้ว!',
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'แจ้งเตือนคอร์สกายภาพ',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    _scheduledDates.add(dateTime);
    await saveSelectedCourse(courseName);
    await showScheduledConfirmationNotification(courseName, dateTime);
  }

  static Future<void> showScheduledConfirmationNotification(String courseName, DateTime dateTime) async {
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    await flutterLocalNotificationsPlugin.show(
      2,
      'ตั้งการแจ้งเตือนสำเร็จ',
      'คอร์ส: $courseName เวลา $timeStr',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'แจ้งเตือนยืนยัน',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> logCourse(String courseName, DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'history_${_formatDate(dateTime)}';
    final existing = prefs.getStringList(key) ?? [];

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final newEntry = '$courseName|$timeStr';

    if (!existing.contains(newEntry)) {
      existing.add(newEntry);
      await prefs.setStringList(key, existing);
    }
  }

  static Future<void> saveSelectedCourse(String courseName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_courses';
    final existing = prefs.getStringList(key) ?? [];
    if (!existing.contains(courseName)) {
      existing.add(courseName);
      await prefs.setStringList(key, existing);
    }
  }

  static Future<List<String>> getSelectedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selected_courses') ?? [];
  }

  static Future<List<String>> getScheduledCoursesOn(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'history_${_formatDate(date)}';
    final completed = prefs.getStringList(key) ?? [];
    final selected = prefs.getStringList('selected_courses') ?? [];

    final result = <String>[];

    for (final dt in _scheduledDates) {
      if (dt.year == date.year && dt.month == date.month && dt.day == date.day) {
        final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        for (final name in selected) {
          final entry = '$name|$timeStr';
          if (!completed.contains(entry)) {
            result.add(entry);
          }
        }
      }
    }
    return result;
  }

  static Future<List<String>> getCoursesOn(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'history_${_formatDate(date)}';
    return prefs.getStringList(key) ?? [];
  }

  static List<DateTime> getScheduledDates() => _scheduledDates;

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
