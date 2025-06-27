import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ArmExtensionForwardEvaluator extends RepetitionEvaluator {
  int _state = 0;
  String _feedback = '';

  @override
  String get name => "Arm Extension Forward";

  @override
  String get feedback => _feedback;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];

    if (rightWrist == null || rightShoulder == null) return null;

    final dy = rightShoulder.dy - rightWrist.dy;
    final dx = (rightWrist.dx - rightShoulder.dx).abs();

    if (_state == 0 && dy > 60 && dx > 50) {
      _state = 1;
    } else if (_state == 1 && dy < 15) {
      _state = 0;
      repetitionCount++;
      _feedback = "✓ เหยียดแขนครั้งที่ $repetitionCount";
      return _feedback;
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    if (rightWrist == null || rightShoulder == null) return false;

    final dy = rightShoulder.dy - rightWrist.dy;
    final dx = (rightWrist.dx - rightShoulder.dx).abs();

    return dy > 15 && dx > 50;
  }

  @override
  String getTechnicalFeedback(Map<PoseLandmarkType, Offset> points) {
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];

    if (rightWrist == null || rightShoulder == null) {
      return "กรุณาให้เห็นแขนขวาและหัวไหล่ในกล้อง";
    }

    final dy = rightShoulder.dy - rightWrist.dy;
    final dx = (rightWrist.dx - rightShoulder.dx).abs();

    if (dy <= 15) return "ยกแขนขึ้นอีกนิด";
    if (dx <= 50) return "เหยียดแขนไปด้านหน้าให้ตรง";

    return "";
  }
}
