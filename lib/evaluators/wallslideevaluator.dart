import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class WallSlideEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Wall Slide';

  @override
  String get feedback => 'เลื่อนแขนแนบผนังขึ้น-ลง';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftWrist) &&
          points.containsKey(PoseLandmarkType.leftShoulder))) return false;

    final wristY = points[PoseLandmarkType.leftWrist]!.dy;
    final shoulderY = points[PoseLandmarkType.leftShoulder]!.dy;

    return wristY < shoulderY; // แขนเลื่อนขึ้น

  }

double calculateAngle(Offset a, Offset b, Offset c) {
  final ab = a - b;
  final cb = c - b;
  final dot = ab.dx * cb.dx + ab.dy * cb.dy;
  final abLen = ab.distance;
  final cbLen = cb.distance;
  return acos(dot / (abLen * cbLen)) * (180 / pi);
}

}