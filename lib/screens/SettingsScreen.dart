import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/course_event_service.dart';
import '../services/user_settings.dart';
import '../widgets/thera_app_bar.dart';
import '../widgets/navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _navIndex = 2;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _highlightedDates = {};
  int _streak = 0;
  List<String> _badges = [];
  List<String> _dailyCourses = [];
  List<String> _scheduledCourses = [];
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _highlightedDates = CourseEventService.getScheduledDates().toSet();
    _selectedDay = DateTime.now();
    _loadStats();
    _loadCoursesForDay(_selectedDay!);
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    await UserSettings.loadSettings();
    setState(() {
      _streak = prefs.getInt('streak') ?? 0;
      _badges = prefs.getStringList('badges') ?? [];
    });
  }

  Future<void> _loadCoursesForDay(DateTime day) async {
    final courses = await CourseEventService.getCoursesOn(day);
    final scheduled = await CourseEventService.getScheduledCoursesOn(day);
    setState(() {
      _dailyCourses = courses;
      _scheduledCourses = scheduled;
    });
  }

  void _onNavTapped(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/select-course');
        break;
    }
  }

  Future<String?> _selectCourseDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('เลือกคอร์ส'),
        children: CourseEventService.courseList
            .map((c) => SimpleDialogOption(
                  child: Text(c['name']),
                  onPressed: () => Navigator.pop(context, c['name']),
                ))
            .toList(),
      ),
    );
  }

  Future<TimeOfDay?> _selectTimeDialog() async {
    return await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  void _showBadgesPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🏅 ความสำเร็จ'),
        content: _badges.isEmpty
            ? const Text('คุณยังไม่มีเหรียญตรา')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _badges.map((b) => Text('• $b')).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          )
        ],
      ),
    );
  }

  Widget _buildWeekBar() {
    final base = _selectedDay ?? DateTime.now();
    final week = List.generate(7, (i) => base.subtract(Duration(days: base.weekday - 1 - i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: week.length,
        itemBuilder: (context, index) {
          final day = week[index];
          final isToday = isSameDay(day, DateTime.now());
          final isSelected = isSameDay(day, _selectedDay);
          final hasCourse = _highlightedDates.any((d) => isSameDay(d, day));

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });
              _loadCoursesForDay(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [Colors.orange.shade200, Colors.deepOrange.shade400])
                    : null,
                color: isToday && !isSelected ? Colors.orange.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isSelected || isToday)
                    BoxShadow(color: Colors.orange.shade200, blurRadius: 6, offset: const Offset(0, 3))
                ],
                border: Border.all(
                  color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E().format(day), style: const TextStyle(fontSize: 14)),
                  Text('${day.day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (hasCourse)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2026, 1, 1),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) async {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        await _loadCoursesForDay(selected);
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.orange.shade300, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final isMarked = _highlightedDates.any((d) => isSameDay(d, day));
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isMarked ? Colors.blue : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${day.day}', style: TextStyle(color: isMarked ? Colors.white : null)),
            ),
          );
        },
      ),
      locale: 'th_TH',
    );
  }

  Widget _buildDayCourseList() {
    final d = _selectedDay ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            isSameDay(d, DateTime.now()) ? 'วันนี้' : 'วันที่ ${d.day}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ..._scheduledCourses.map((e) {
          final parts = e.split('|');
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(LucideIcons.clock, color: Color(0xFFE76F51)),
              title: Text(parts[0]),
              subtitle: Text('กำหนดเวลา: ${parts[1]}'),
              tileColor: Colors.orange.shade50,
            ),
          );
        }),
        ..._dailyCourses.map((c) {
          final parts = c.split('|');
          final name = parts[0];
          final time = parts.length > 1 ? parts[1] : '';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(LucideIcons.checkCircle2, color: Colors.green),
              title: Text(name),
              subtitle: time.isNotEmpty ? Text('เวลา: $time') : null,
            ),
          );
        }),
        if (_showCalendar)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.plusCircle),
              label: const Text('เพิ่มกิจกรรม'),
              onPressed: () async {
                final selectedCourse = await _selectCourseDialog();
                if (selectedCourse != null) {
                  final selectedTime = await _selectTimeDialog();
                  if (selectedTime != null) {
                    final scheduled = DateTime(
                      d.year,
                      d.month,
                      d.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    if (scheduled.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⏰ กรุณาเลือกเวลาที่อยู่ในอนาคต')));
                      return;
                    }
                    await CourseEventService.scheduleCourseEvent(selectedCourse, scheduled);
                    await CourseEventService.logCourse(selectedCourse, scheduled);
                    setState(() => _highlightedDates.add(scheduled));
                    await _loadCoursesForDay(d);
                  }
                }
              },
            ),
          )
      ],
    );
  }

  Widget _buildVoiceSettings() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(LucideIcons.headphones, color: Colors.deepOrange),
            title: const Text("การตั้งค่าเสียง", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text("เปิดเสียงคำแนะนำ"),
            value: UserSettings.enableTechnicalFeedback,
            onChanged: (val) async {
              setState(() => UserSettings.enableTechnicalFeedback = val);
              await UserSettings.saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text("เปิดเสียงให้กำลังใจ"),
            value: UserSettings.enableEncouragement,
            onChanged: (val) async {
              setState(() => UserSettings.enableEncouragement = val);
              await UserSettings.saveSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TheraAppBar(
        title: 'TheraPhy',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.award),
            onPressed: _showBadgesPopup,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('ผู้ใช้งาน', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('🔥 Streak: $_streak วัน', style: const TextStyle(fontSize: 18, color: Colors.orange)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('กิจกรรมรายสัปดาห์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildCalendar(),
                    ),
                  ).then((_) => setState(() => _showCalendar = true)),
                  child: const Text('ปฏิทิน'),
                ),
              ],
            ),
            _buildWeekBar(),
            _buildDayCourseList(),
            const SizedBox(height: 20),
            _buildVoiceSettings(),
          ],
        ),
      ),
      bottomNavigationBar: TheraBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTapped,
        labels: const ['ข่าวสาร', 'เลือกคอร์ส', 'ผู้ใช้งาน'],
      ),
    );
  }
}
