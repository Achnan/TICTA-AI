import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class WallPushUpEvaluator extends RepetitionEvaluator {
  int _state = 0;
  String _feedback = '';

  @override
  String get name => "Wall Push-Up";

  @override
  String get feedback => _feedback;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final leftWrist = points[PoseLandmarkType.leftWrist];
    final rightWrist = points[PoseLandmarkType.rightWrist];

    if ([leftShoulder, rightShoulder, leftWrist, rightWrist].any((p) => p == null)) return null;

    final rightDy = (rightShoulder!.dy - rightWrist!.dy).abs();
    final leftDy = (leftShoulder!.dy - leftWrist!.dy).abs();
    final avgDy = (rightDy + leftDy) / 2;

    if (_state == 0 && avgDy < 50) {
      _state = 1;
    } else if (_state == 1 && avgDy > 70) {
      _state = 0;
      repetitionCount++;
      _feedback = "✓ ดันกำแพงรอบที่ $repetitionCount";
      return _feedback;
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final rightWrist = points[PoseLandmarkType.rightWrist];
    if (rightShoulder == null || rightWrist == null) return false;

    return (rightShoulder.dy - rightWrist.dy).abs() > 60;
  }

  @override
  String getTechnicalFeedback(Map<PoseLandmarkType, Offset> points) {
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final rightWrist = points[PoseLandmarkType.rightWrist];

    if (rightShoulder == null || rightWrist == null) {
      return "ให้กล้องเห็นหัวไหล่และข้อมือขวาชัดเจน";
    }

    final dy = (rightShoulder.dy - rightWrist.dy).abs();
    if (dy < 60) return "ดันตัวเข้าหากำแพงให้ลึกกว่านี้";

    return "";
  }
}
