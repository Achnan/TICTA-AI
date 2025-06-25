
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui';

class UpDownTracker {
  final PoseLandmarkType joint;
  final double threshold;
  double? _lastY;
  bool? _goingDown;
  int repetitionCount = 0;

  UpDownTracker({required this.joint, this.threshold = 20});

  void update(Map<PoseLandmarkType, Offset> points) {
    final currentY = points[joint]?.dy;
    if (currentY == null) return;

    if (_lastY == null) {
      _lastY = currentY;
      return;
    }

    final delta = currentY - _lastY!;
    if (delta.abs() < threshold) return;

    if (_goingDown == true && delta < 0) {
      repetitionCount++;
    }

    _goingDown = delta > 0;
    _lastY = currentY;
  }
}
