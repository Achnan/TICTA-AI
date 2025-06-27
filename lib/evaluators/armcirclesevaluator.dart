import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ArmCirclesEvaluator extends RepetitionEvaluator {
  int _repetitionCount = 0;
  String _feedback = "";
  bool _isCirclingUp = false;
  bool _hasCompletedCircle = false;
  double? _previousY;

  @override
  String get name => "Arm Circles";

  @override
  String get feedback => _feedback;

  @override
  int get repetitionCount => _repetitionCount;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    if (!points.containsKey(PoseLandmarkType.rightWrist) || !points.containsKey(PoseLandmarkType.rightShoulder)) {
      _feedback = "กรุณายกแขนข้างขวาให้กล้องเห็น";
      return _feedback;
    }

    final wrist = points[PoseLandmarkType.rightWrist]!;
    final shoulder = points[PoseLandmarkType.rightShoulder]!;

    if (_previousY == null) {
      _previousY = wrist.dy;
      return null;
    }

    final dyChange = wrist.dy - _previousY!;
    _previousY = wrist.dy;

    // ถ้าแขนยกขึ้น (เคลื่อนที่จากล่างขึ้นบน)
    if (dyChange < -3.5) {
      _isCirclingUp = true;
    }

    // ถ้าแขนลดลง (จากบนลงล่าง)
    if (_isCirclingUp && dyChange > 3.5) {
      _hasCompletedCircle = true;
    }

    // เมื่อครบ 1 รอบ
    if (_hasCompletedCircle) {
      _repetitionCount++;
      _feedback = "✓ หมุนรอบที่ $_repetitionCount";
      _hasCompletedCircle = false;
      _isCirclingUp = false;
      return _feedback;
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    return true;
  }
}
