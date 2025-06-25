import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ShoulderShrugEvaluator extends PoseEvaluator {
  @override
  String get name => 'Shoulder Shrug';

  int repetitions = 0;
  String stage = 'down';

  final double thresholdUp = 30;
  final double thresholdDown = 50;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    final shoulder = points[PoseLandmarkType.leftShoulder];
    final ear = points[PoseLandmarkType.leftEar];

    if (shoulder == null || ear == null) return null;

    final deltaY = shoulder.dy - ear.dy;

    if (stage == 'down' && deltaY < thresholdUp) {
      stage = 'up';
      repetitions++;
      return '✅ ยกไหล่ขึ้นสำเร็จ (ครั้งที่ $repetitions)';
    } else if (stage == 'up' && deltaY > thresholdDown) {
      stage = 'down';
      return '⬇️ ลดไหล่ลง';
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    // ไม่ใช้ระบบ evaluate ธรรมดาในการจับท่าครั้งเดียว
    return true;
  }

  @override
  String get feedback => 'ยกไหล่ขึ้นสูงกว่าปกติ';
}