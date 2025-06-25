import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ArmExtensionForwardEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Arm Extension Forward';

  @override
  String get feedback => 'เหยียดแขนและยกขึ้นเหนือศีรษะ';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftShoulder) &&
          points.containsKey(PoseLandmarkType.leftElbow) &&
          points.containsKey(PoseLandmarkType.leftWrist))) return false;

    final angle = calculateAngle(
      points[PoseLandmarkType.leftShoulder]!,
      points[PoseLandmarkType.leftElbow]!,
      points[PoseLandmarkType.leftWrist]!,
    );

    return angle > 150;

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