import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'evaluator_base.dart';

class ShoulderAbductionEvaluator extends RepetitionEvaluator {
  int _state = 0;
  String _feedback = '';

  @override
  String get name => "Shoulder Abduction";

  @override
  String get feedback => _feedback;

  @override
  String? update(Map<PoseLandmarkType, Offset> points) {
    final leftWrist = points[PoseLandmarkType.leftWrist];
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];

    if ([leftWrist, rightWrist, leftShoulder, rightShoulder].any((p) => p == null)) return null;

    final dyLeft = leftShoulder!.dy - leftWrist!.dy;
    final dyRight = rightShoulder!.dy - rightWrist!.dy;
    final dxLeft = (leftWrist.dx - leftShoulder.dx).abs();
    final dxRight = (rightWrist.dx - rightShoulder.dx).abs();

    final avgDy = (dyLeft + dyRight) / 2;
    final avgDx = (dxLeft + dxRight) / 2;

    if (_state == 0 && avgDy > 50 && avgDx > 30) {
      _state = 1;
    } else if (_state == 1 && avgDy < 20) {
      _state = 0;
      repetitionCount++;
      _feedback = "✓ กางแขนครั้งที่ $repetitionCount";
      return _feedback;
    }

    return null;
  }

  @override
  bool evaluate(Map<PoseLandmarkType, Offset> points) {
    final leftWrist = points[PoseLandmarkType.leftWrist];
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];

    if ([leftWrist, rightWrist, leftShoulder, rightShoulder].any((p) => p == null)) return false;

    final dyLeft = leftShoulder!.dy - leftWrist!.dy;
    final dyRight = rightShoulder!.dy - rightWrist!.dy;

    return dyLeft > 20 && dyRight > 20;
  }

  @override
  String getTechnicalFeedback(Map<PoseLandmarkType, Offset> points) {
    final leftWrist = points[PoseLandmarkType.leftWrist];
    final rightWrist = points[PoseLandmarkType.rightWrist];
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];

    if ([leftWrist, rightWrist, leftShoulder, rightShoulder].any((p) => p == null)) {
      return "ขยับให้เห็นแขนและไหล่ทั้งสองข้างในกล้อง";
    }

    final dyLeft = leftShoulder!.dy - leftWrist!.dy;
    final dyRight = rightShoulder!.dy - rightWrist!.dy;
    final dxLeft = (leftWrist.dx - leftShoulder.dx).abs();
    final dxRight = (rightWrist.dx - rightShoulder.dx).abs();

    if (dyLeft < 20 || dyRight < 20) return "ยกแขนให้สูงขึ้นอีกนิด";
    if (dxLeft < 30 || dxRight < 30) return "กางแขนออกด้านข้างให้มากขึ้น";

    return "";
  }
}
