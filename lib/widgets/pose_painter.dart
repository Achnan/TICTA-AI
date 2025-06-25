import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final double imageWidth;
  final double imageHeight;
  final bool isFrontCamera;

  PosePainter(
    this.landmarks,
    this.imageWidth,
    this.imageHeight, {
    this.isFrontCamera = false,
  });

  factory PosePainter.fromLandmarks(
    List<PoseLandmark> landmarks,
    double w,
    double h, {
    bool isFrontCamera = false,
  }) {
    return PosePainter(landmarks, w, h, isFrontCamera: isFrontCamera);
  }

  final List<List<PoseLandmarkType>> connections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    Offset transform(PoseLandmark lm) {
      final x = isFrontCamera ? (imageWidth - lm.x) * scaleX : lm.x * scaleX;
      final y = lm.y * scaleY;
      return Offset(x, y);
    }

    final pointPaint = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 3.0;

    final points = {
      for (var lm in landmarks) lm.type: transform(lm),
    };

    for (final connection in connections) {
      final p1 = points[connection[0]];
      final p2 = points[connection[1]];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, linePaint);
      }
    }

    for (final p in points.values) {
      canvas.drawCircle(p, 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
