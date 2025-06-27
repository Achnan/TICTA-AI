
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/NewsScreen.dart';
import 'screens/CameraPage.dart';
import 'screens/Login.dart';
import 'screens/SelectCourse.dart';
import 'screens/SettingsScreen.dart';
import 'screens/SuggestionScreen.dart';
import 'services/user_settings.dart';

List<CameraDescription> cameras = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    await Permission.notification.request();
  }
}

// ✅ ขอ permission สำหรับโทรศัพท์
Future<void> requestPhonePermission() async {
  if (await Permission.phone.isDenied) {
    await Permission.phone.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

  await requestNotificationPermission();
  await requestPhonePermission();
  await UserSettings.loadSettings(); 

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint('🔔 Notification clicked: \${response.payload}');
    },
  );

  cameras = await availableCameras();

  final prefs = await SharedPreferences.getInstance();
  final suggestionDoneRaw = prefs.get('suggestion_done');
  final skipSuggestionRaw = prefs.get('suggestion_skip');

  final bool suggestionDone = suggestionDoneRaw is bool ? suggestionDoneRaw : false;
  final bool skipSuggestion = skipSuggestionRaw is bool ? skipSuggestionRaw : false;

  final initialRoute = (!suggestionDone && !skipSuggestion)
      ? '/suggestion'
      : '/select-course';

  runApp(TheraPhyApp(initialRoute: initialRoute));
}

class TheraPhyApp extends StatelessWidget {
  final String initialRoute;

  const TheraPhyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheraPhy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        primaryColor: const Color(0xFF205781),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF205781),
          foregroundColor: Colors.white,
        ),
      ),
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            final navigator = Navigator.of(context);
            if (!navigator.canPop()) {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SelectCourseScreen()),
                (route) => false,
              );
              return false;
            }
            return true;
          },
          child: child!,
        );
      },
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/news':
            return MaterialPageRoute(builder: (_) => const NewsScreen());
          case '/select-course':
            return MaterialPageRoute(builder: (_) => const SelectCourseScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/suggestion':
            return MaterialPageRoute(builder: (_) => const SuggestionScreen());
          case '/camera':
            final courseName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CameraPage(courseName: courseName),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('ไม่พบเส้นทางที่เรียก')),
              ),
            );
        }
      },
    );
  }
}
