import 'dart:math';
import 'dart:ui';
import 'evaluator_base.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ShoulderRollsEvaluator extends PoseEvaluator {
  @override
  bool get requiresSideView => true;
  @override
  String get name => 'Shoulder Rolls';

  @override
  String get feedback => 'หมุนไหล่ให้สุดช่วง';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    // Logic placeholder: ต้องใช้การเคลื่อนไหวต่อเนื่อง
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