import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class HeelRaiseEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Heel Raise';

  @override
  String get feedback => 'เขย่งส้นเท้าให้สุด';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    if (!(points.containsKey(PoseLandmarkType.leftHeel) &&
          points.containsKey(PoseLandmarkType.leftAnkle))) return false;

    final heelY = points[PoseLandmarkType.leftHeel]!.dy;
    final ankleY = points[PoseLandmarkType.leftAnkle]!.dy;

    return heelY < ankleY - 10; // ยกส้นสูงจากพื้น

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