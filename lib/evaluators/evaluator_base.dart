import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui';

abstract class PoseEvaluator {
  bool get requiresSideView => false;
  String get name;
  String get feedback;
  bool evaluate(Map<PoseLandmarkType, Offset> points);
}

abstract class RepetitionEvaluator extends PoseEvaluator {
  String? update(Map<PoseLandmarkType, Offset> points);
  
  int get repetitionCount => 0;
}
