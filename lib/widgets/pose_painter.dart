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

  Offset transform(PoseLandmark lm, Size screenSize) {
    final previewAspectRatio = imageHeight / imageWidth;
    final screenAspectRatio = screenSize.height / screenSize.width;

    double scale;
    double dx = 0, dy = 0;

    if (previewAspectRatio > screenAspectRatio) {
      // ครอบแนวตั้ง
      scale = screenSize.height / imageHeight;
      dx = (screenSize.width - imageWidth * scale) / 2;
    } else {
      // ครอบแนวนอน
      scale = screenSize.width / imageWidth;
      dy = (screenSize.height - imageHeight * scale) / 2;
    }

    double x = lm.x * scale + dx;
    double y = lm.y * scale + dy;

    if (isFrontCamera) x = screenSize.width - x;

    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 3.0;

    final points = {
      for (var lm in landmarks) lm.type: transform(lm, size),
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
