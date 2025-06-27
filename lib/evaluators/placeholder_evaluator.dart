import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class PlaceholderEvaluator extends PoseEvaluator {
  final String _name;

  PlaceholderEvaluator(this._name);

  @override
  String get name => _name;

  @override
  String get feedback => '🔧 ท่านี้ยังอยู่ระหว่างพัฒนา';

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    return false;
  }
}
