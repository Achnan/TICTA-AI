import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ArmCirclesEvaluator extends PoseEvaluator {
  @override
  String get name => 'Arm Circles';

  @override
  String get feedback => 'หมุนแขนเป็นวงเล็ก ๆ';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    // ต้องตรวจเป็นลูป frame ต่อเนื่อง
    return true;

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
