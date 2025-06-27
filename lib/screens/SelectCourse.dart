import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_event_service.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/thera_app_bar.dart';
import '../widgets/exercise_preview_dialog.dart';


class SelectCourseScreen extends StatefulWidget {
  const SelectCourseScreen({super.key});

  @override
  State<SelectCourseScreen> createState() => _SelectCourseScreenState();
}

class _SelectCourseScreenState extends State<SelectCourseScreen> {
  int _navIndex = 1;
  final List<Map<String, dynamic>> courseList = CourseEventService.courseList;
  String? _suggestedCategory;

  @override
  void initState() {
    super.initState();
    _loadSuggestedCategory();
  }

  Future<void> _loadSuggestedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _suggestedCategory = prefs.getString('suggested_category');
    });
  }

  void _onNavTapped(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

 void _startCourse(String exerciseName,String slug) async {
final imageAsset = 'assets/picture/$slug.png';
final description = 'ตัวอย่างท่า: $exerciseName\n\nรักษาท่าทางให้ถูกต้องตลอดการฝึก';


  final previewConfirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ExercisePreviewDialog(
      title: exerciseName,
      imageAsset: imageAsset,
      description: description,
    ),
  );

  if (previewConfirmed != true) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text('คำเตือนก่อนเริ่มฝึก', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('โปรดตรวจสอบสิ่งต่อไปนี้ก่อนเริ่มต้น:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(height: 12),
            BulletText('📍 อยู่ในพื้นที่ที่มีพื้นที่ว่างเพียงพอสำหรับการเคลื่อนไหว'),
            BulletText('📷 กล้องสามารถมองเห็นร่างกายของคุณได้เต็มตัว'),
            BulletText('🚫 ไม่มีสิ่งกีดขวางรอบตัวคุณ'),
            SizedBox(height: 12),
            Text('⚠️ ข้อควรระวัง', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            BulletText('👵 หากเป็นผู้สูงอายุหรือเด็ก ควรมีผู้ดูแลอยู่ด้วย'),
            BulletText('❗ หากมีอาการปวด ชา หรือไม่สบาย ให้หยุดฝึกทันที'),
            SizedBox(height: 8),
            Text('คุณต้องการเริ่มฝึกท่านี้หรือไม่?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_fill),
          onPressed: () => Navigator.pop(context, true),
          label: const Text('เริ่มฝึก'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    Navigator.pushNamed(context, '/camera', arguments: exerciseName);
  }
}


  Widget _buildExerciseCard(Map<String, String> ex, Color color, IconData icon) {
    return GestureDetector(
      onTap: () =>_startCourse(ex['title']!, ex['slug']!),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F4E79))),
                  const SizedBox(height: 4),
                  if (ex['desc'] != null && ex['desc']!.isNotEmpty)
                    Text(ex['desc']!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (ex['reps'] != null)
                        Row(
                          children: [
                            const Icon(Icons.loop, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(ex['reps']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      const SizedBox(width: 12),
                      if (ex['duration'] != null)
                        Row(
                          children: [
                            const Icon(Icons.hourglass_bottom, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(ex['duration']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSection(Map<String, dynamic> course, {bool isSuggested = false}) {
    final String name = course['name'];
    Color color;
    IconData icon;

    if (name.contains('กีฬา')) {
      color = const Color(0xFF6BCB77);
      icon = Icons.directions_run;
    } else if (name.contains('ผู้สูงอายุ')) {
      color = const Color(0xFF4CC9F0);
      icon = Icons.elderly;
    } else if (name.contains('ระบบประสาท')) {
      color = const Color(0xFFF4A261);
      icon = Icons.psychology;
    } else if (name.contains('กระดูก')) {
      color = const Color(0xFF9D4EDD);
      icon = Icons.accessibility_new;
    } else {
      color = Colors.grey;
      icon = Icons.self_improvement;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            if (isSuggested)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('⭐ แนะนำ', style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(course['exercises'].length, (i) {
          final ex = course['exercises'][i] as Map<String, String>;
          return _buildExerciseCard(ex, color, icon);
        }),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recommended = [];
    final List<Map<String, dynamic>> others = [];

    for (final course in courseList) {
      if (_suggestedCategory != null && course['name'].contains(_suggestedCategory!)) {
        recommended.add(course);
      } else {
        others.add(course);
      }
    }

    final allCourses = [...recommended, ...others];

    return Scaffold(
      appBar: const TheraAppBar(title: 'เลือกคอร์ส'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: allCourses.length,
        itemBuilder: (context, index) {
          final course = allCourses[index];
          final isRecommended = recommended.contains(course);
          return _buildCourseSection(course, isSuggested: isRecommended);
        },
      ),
      bottomNavigationBar: TheraBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
