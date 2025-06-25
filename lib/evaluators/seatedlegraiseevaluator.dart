import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SeatedLegRaiseEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Seated Leg Raise';

  @override
  String get feedback => 'เหยียดขาให้ตรงมากขึ้น';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftHip) &&
          points.containsKey(PoseLandmarkType.leftKnee) &&
          points.containsKey(PoseLandmarkType.leftAnkle))) return false;

    final angle = calculateAngle(
      points[PoseLandmarkType.leftHip]!,
      points[PoseLandmarkType.leftKnee]!,
      points[PoseLandmarkType.leftAnkle]!,
    );

    return angle > 160;

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