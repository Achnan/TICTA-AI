import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ShoulderAbductionEvaluator extends PoseEvaluator {
  @override
  String get name => 'Shoulder Abduction';

  @override
  String get feedback => 'กางแขนถึงระดับไหล่';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftShoulder) &&
          points.containsKey(PoseLandmarkType.leftElbow))) return false;

    final angle = calculateAngle(
      Offset(points[PoseLandmarkType.leftShoulder]!.dx, points[PoseLandmarkType.leftShoulder]!.dy - 100),
      points[PoseLandmarkType.leftShoulder]!,
      points[PoseLandmarkType.leftElbow]!,
    );

    return (angle > 70 && angle < 110);

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
