import 'dart:ui';
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ShoulderRollsEvaluator extends RepetitionEvaluator {
  int _repetitionCount = 0;
  String _feedback = "";
  double? _previousAngle;
  bool _hasPassedFront = false;

  @override
  String get name => "Shoulder Rolls";

  @override
  String get feedback => _feedback;

  @override
  int get repetitionCount => _repetitionCount;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    if (!points.containsKey(PoseLandmarkType.rightShoulder) || !points.containsKey(PoseLandmarkType.rightElbow)) {
      _feedback = "กรุณาหันไหล่ให้กล้องเห็นชัดเจน";
      return _feedback;
    }

    final shoulder = points[PoseLandmarkType.rightShoulder]!;
    final elbow = points[PoseLandmarkType.rightElbow]!;

    final dx = elbow.dx - shoulder.dx;
    final dy = elbow.dy - shoulder.dy;
    double angle = atan2(dy, dx) * 180 / pi;
    angle = (angle + 360) % 360;

    if (_previousAngle != null) {
      if (_previousAngle! > 270 && angle < 90) {
        _hasPassedFront = true;
      }

      if (_hasPassedFront && _previousAngle! < 180 && angle > 270) {
        _repetitionCount++;
        _hasPassedFront = false;
        _feedback = "✓ หมุนไหล่รอบที่ $_repetitionCount";
        _previousAngle = angle;
        return _feedback;
      }
    }

    _previousAngle = angle;
    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    return true;
  }
}
