import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../widgets/pose_painter.dart';
import '../services/pose_evaluator_service.dart';
import '../evaluators/evaluator_base.dart';
import '../services/user_settings.dart';

class CameraPage extends StatefulWidget {
  final String courseName;

  const CameraPage({super.key, required this.courseName});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late final PoseDetector _poseDetector;
  final FlutterTts _tts = FlutterTts();

  bool _isDetecting = false;
  bool _isFrontCamera = true;
  List<PoseLandmark> _landmarks = [];
  String? _feedbackText;
  DateTime? _lastFeedbackTime;

  Timer? _exerciseTimer;
  Timer? _restTimer;
  int _remainingSeconds = 180;
  bool _isResting = false;

  bool _showTurnSideHint = false;
  bool _hasSpokenTurnHint = false;

  final List<String> encouragements = [
    "เยี่ยมมากครับ!",
    "สุดยอดเลย!",
    "ทำดีมากครับ",
    "คุณทำได้ดีมาก!",
    "เก่งมากครับ! สู้ต่อไป"
  ];

  final List<String> encouragementsWhenWrong = [
    "ไม่เป็นไรครับ ลองใหม่อีกครั้งนะครับ",
    "ใกล้แล้วครับ ผมเชื่อว่าคุณทำได้",
    "ผิดนิดเดียวเองครับ ลองอีกที",
    "สู้ต่อไปครับ ทุกครั้งคือการเรียนรู้"
  ];

  int _lastRepetitionCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    _isFrontCamera = true;

    _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );

    await _tts.setLanguage("th-TH");
    await _tts.setSpeechRate(0.5);

    await _controller!.startImageStream(_processImage);
    _startExerciseTimer();
    setState(() {});
  }

  void _startExerciseTimer() {
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);

      if (_remainingSeconds <= 0) {
        _exerciseTimer?.cancel();
        _tts.speak("\uD83C\uDF89 สิ้นสุดการฝึกวันนี้แล้ว ขอบคุณที่ร่วมฝึก");
        Navigator.pushReplacementNamed(context, '/select-course');
      }

      if (_remainingSeconds % 60 == 0 && _remainingSeconds != 0) {
        _startRestPeriod();
      }
    });
  }

  void _startRestPeriod() async {
    _isResting = true;
    await _tts.speak("⏸ ถึงเวลาพัก 10 วินาที");
    await _controller?.stopImageStream();

    _restTimer = Timer(const Duration(seconds: 10), () async {
      _isResting = false;
      await _tts.speak("\uD83D\uDCAA เริ่มฝึกต่อได้เลย");
      await _controller?.startImageStream(_processImage);
    });
  }

  bool _shouldShowTurnHint(Map<PoseLandmarkType, Offset> points) {
    return !(points.containsKey(PoseLandmarkType.leftShoulder) &&
             points.containsKey(PoseLandmarkType.rightShoulder) &&
             (points[PoseLandmarkType.leftShoulder]!.dx - points[PoseLandmarkType.rightShoulder]!.dx).abs() > 60);
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting || !_controller!.value.isStreamingImages || _isResting) return;
    _isDetecting = true;

    try {
      if (image.format.group != ImageFormatGroup.yuv420) {
        _isDetecting = false;
        return;
      }

      final inputImage = _convertCameraImage(image, _controller!.description.sensorOrientation);
      final poses = await _poseDetector.processImage(inputImage);

      if (mounted && poses.isNotEmpty) {
        final landmarks = poses.first.landmarks.values.toList();
        final points = {for (var lm in landmarks) lm.type: Offset(lm.x, lm.y)};
        final evaluator = PoseEvaluatorService.getEvaluatorByName(widget.courseName);

        if (_shouldShowTurnHint(points)) {
          if (!_showTurnSideHint) {
            setState(() => _showTurnSideHint = true);
          }
          if (!_hasSpokenTurnHint) {
            _hasSpokenTurnHint = true;
            await _tts.speak("กรุณาหันตัวด้านข้างให้กล้องมองเห็นท่าชัดเจนขึ้นนะครับ");
          }
        } else {
          _hasSpokenTurnHint = false;
          if (_showTurnSideHint) {
            setState(() => _showTurnSideHint = false);
          }
        }

        String? result;
        if (evaluator != null) {
          if (evaluator is RepetitionEvaluator) {
            result = evaluator.update(points);
            if (evaluator.repetitionCount > _lastRepetitionCount && UserSettings.enableEncouragement) {
              _lastRepetitionCount = evaluator.repetitionCount;
              final phrase = encouragements[Random().nextInt(encouragements.length)];
              await _tts.speak("$phrase ทำได้ $_lastRepetitionCount ครั้งแล้วครับ");
            }
          } else if (!evaluator.evaluate(points)) {
            result = evaluator.feedback;
            if (UserSettings.enableTechnicalFeedback) {
              await _tts.speak(result);
            }
            if (UserSettings.enableEncouragement) {
              final phrase = encouragementsWhenWrong[Random().nextInt(encouragementsWhenWrong.length)];
              await _tts.speak(phrase);
            }
          }
        }

        setState(() {
          _landmarks = landmarks;
          _feedbackText = result;
        });
      }
    } catch (e) {
      debugPrint('❌ Detection error: $e');
    }

    _isDetecting = false;
  }

  InputImage _convertCameraImage(CameraImage image, int rotation) {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotationValue.fromRawValue(rotation) ?? InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  void _stopSession() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    _controller?.stopImageStream();
    Navigator.pushReplacementNamed(context, '/select-course');
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    _controller?.dispose();
    _poseDetector.close();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final previewSize = _controller!.value.previewSize!;
    final scale = size.aspectRatio * previewSize.aspectRatio;

    return Scaffold(
      appBar: AppBar(title: Text('ฝึก: ${widget.courseName}')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale < 1 ? 1 / scale : scale,
            child: Center(child: CameraPreview(_controller!)),
          ),
          if (_landmarks.isNotEmpty)
            CustomPaint(
              painter: PosePainter.fromLandmarks(
                _landmarks,
                previewSize.width,
                previewSize.height,
                isFrontCamera: _isFrontCamera,
              ),
            ),
          if (_feedbackText != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _feedbackText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          if (_showTurnSideHint)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "\uD83D\uDCF8 กรุณาหันตัวด้านข้างให้กล้องเห็นได้ชัดเจน",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Text(
                  _isResting ? '⏸ กำลังพัก...' : '⏱ เหลือเวลา: $_remainingSeconds วินาที',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text("หยุดการฝึก"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: _stopSession,
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: ElevatedButton(
              onPressed: () => _tts.speak("ระบบเสียงทำงานเรียบร้อยแล้ว"),
              child: const Text("ทดสอบเสียง"),
            ),
          ),
        ],
      ),
    );
  }
}
