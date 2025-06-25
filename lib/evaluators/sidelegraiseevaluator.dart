import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SideLegRaiseEvaluator extends PoseEvaluator {
  @override
  String get name => 'Side Leg Raise';

  @override
  String get feedback => 'ยกขาออกด้านข้างให้สูง';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftHip) &&
          points.containsKey(PoseLandmarkType.leftKnee))) return false;

    final hipY = points[PoseLandmarkType.leftHip]!.dy;
    final kneeY = points[PoseLandmarkType.leftKnee]!.dy;

    return kneeY < hipY; // เข่าต้องยกสูงกว่าสะโพก

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
