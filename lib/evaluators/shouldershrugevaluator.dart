import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ShoulderShrugEvaluator extends RepetitionEvaluator {
  int _state = 0;
  String _feedback = '';

  @override
  String get name => "Shoulder Shrug";

  @override
  String get feedback => _feedback;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final leftHip = points[PoseLandmarkType.leftHip];
    final rightHip = points[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) return null;

    final leftDy = leftHip.dy - leftShoulder.dy;
    final rightDy = rightHip.dy - rightShoulder.dy;
    final avgDy = (leftDy + rightDy) / 2;

    if (_state == 0 && avgDy > 60) {
      _state = 1;
    } else if (_state == 1 && avgDy < 40) {
      _state = 0;
      repetitionCount++;
      _feedback = "ยกไหล่ครั้งที่ $repetitionCount";
      return _feedback;
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final leftHip = points[PoseLandmarkType.leftHip];
    final rightHip = points[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      _feedback = "❗ กรุณาอยู่ในตำแหน่งที่กล้องเห็นได้ชัดเจน";
      return false;
    }

    final leftDy = leftHip.dy - leftShoulder.dy;
    final rightDy = rightHip.dy - rightShoulder.dy;
    final avgDy = (leftDy + rightDy) / 2;
    final shoulderDiff = (leftDy - rightDy).abs();

    if (avgDy >= 60 && shoulderDiff < 20) {
      _feedback = "✅ ยกไหล่ได้ดีมากแล้วครับ";
      return true;
    }

    if (avgDy < 40) {
      _feedback = "❗ กรุณายกไหล่ขึ้นอีกนิดครับ";
    } else if (shoulderDiff >= 20) {
      _feedback = "❗ ยกไหล่ให้เท่ากันทั้งสองข้างครับ";
    } else {
      _feedback = "❗ ลองยืดตัวตรงขึ้นนิดนึงครับ";
    }

    return false;
  }
}
