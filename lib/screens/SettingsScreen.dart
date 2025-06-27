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
                    ? const LinearGradient(
                        colors: [Color(0xFF64A6D3), Color(0xFF205781)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isToday && !isSelected ? const Color(0xFFB3D3E6) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isSelected)
                    const BoxShadow(
                      color: Color(0x4D205781),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    )
                  else if (isToday)
                    const BoxShadow(
                      color: Color(0x33205781),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                ],
                border: Border.all(
                  color: isSelected ? const Color(0xFF205781) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E('th_TH').format(day),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      )),
                  Text('${day.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      )),
                  if (hasCourse)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: CircleAvatar(radius: 3, backgroundColor: Color(0xFF205781)),
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
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _loadCoursesForDay(selectedDay);
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF64A6D3), Color(0xFF205781)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        selectedDecoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF64A6D3), Color(0xFF205781)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
      ),
      locale: 'th_TH',
    );
  }

  Widget _buildDayCourseList() {
    final d = _selectedDay ?? DateTime.now();
    final formattedDate = DateFormat("d MMMM", "th_TH").format(d);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Icon(
                isSameDay(d, DateTime.now()) ? LucideIcons.sun : LucideIcons.calendar,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                isSameDay(d, DateTime.now()) ? 'วันนี้ ($formattedDate)' : 'วันที่ $formattedDate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
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

  Widget _buildSafetySettings() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(LucideIcons.alertCircle, color: Colors.redAccent),
            title: const Text("ความปลอดภัย", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text("เปิดระบบโทรฉุกเฉินเมื่อเกิดการล้ม"),
            subtitle: const Text("ระบบจะโทรไปยังเบอร์ที่ตั้งไว้ หากตรวจพบว่าคุณล้ม"),
            value: UserSettings.enableFallDetection,
            onChanged: (val) async {
              setState(() => UserSettings.enableFallDetection = val);
              await UserSettings.saveSettings();
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.phone, color: Colors.red),
            title: const Text("เบอร์ฉุกเฉิน"),
            subtitle: Text(UserSettings.emergencyPhone),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final controller = TextEditingController(text: UserSettings.emergencyPhone);
                final newPhone = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("ตั้งค่าเบอร์ฉุกเฉิน"),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "เบอร์โทรฉุกเฉิน"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
                      TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("บันทึก")),
                    ],
                  ),
                );
                if (newPhone != null && newPhone.isNotEmpty) {
                  setState(() => UserSettings.emergencyPhone = newPhone);
                  await UserSettings.saveSettings();
                }
              },
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('ผู้ใช้งาน', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('🔥 Streak: $_streak วัน',
                      style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('กิจกรรมรายสัปดาห์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => setState(() => _showCalendar = !_showCalendar),
                  child: Text(_showCalendar ? 'ซ่อนปฏิทิน' : 'ปฏิทิน'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildWeekBar(),
            if (_showCalendar) _buildCalendar(),
            _buildDayCourseList(),
            const SizedBox(height: 24),
            _buildVoiceSettings(),
            _buildSafetySettings(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.plus),
              label: const Text("เลือกวันที่อยากเพิ่มคอร์ส"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final selectedCourse = await _selectCourseDialog();
                if (selectedCourse == null) return;

                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  helpText: 'เลือกวันที่',
                  cancelText: 'ยกเลิก',
                  confirmText: 'ยืนยัน',
                );
                if (selectedDate == null) return;

                final selectedTime = await _selectTimeDialog();
                if (selectedTime == null) return;

                final courseDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                await CourseEventService.scheduleCourseEvent(selectedCourse, courseDateTime);
                setState(() {
                  _highlightedDates.add(selectedDate);
                  _selectedDay = selectedDate;
                  _focusedDay = selectedDate;
                });
                await _loadCoursesForDay(selectedDate);
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.history),
              label: const Text("ล้างประวัติคำแนะนำ"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('suggestion_done');
                await prefs.remove('suggestion_skip');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ล้างประวัติคำแนะนำแล้ว')),
                );
              },
            ),
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
