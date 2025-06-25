import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class StandingKneeFlexionEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Standing Knee Flexion';

  @override
  String get feedback => 'งอเข่าให้ส้นเท้าชี้ขึ้นด้านหลัง';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.rightHip) &&
          points.containsKey(PoseLandmarkType.rightKnee) &&
          points.containsKey(PoseLandmarkType.rightAnkle))) return false;

    final angle = calculateAngle(
      points[PoseLandmarkType.rightHip]!,
      points[PoseLandmarkType.rightKnee]!,
      points[PoseLandmarkType.rightAnkle]!,
    );

    return angle < 100;

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