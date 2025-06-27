import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool _isSpeaking = false;
  DateTime? _lastSpeechTime;
  Queue<String> _speechQueue = Queue<String>();
  bool _processingQueue = false;

  final List<String> encouragements = [
    "เยี่ยมมากครับ!", "สุดยอดเลย!", "ทำดีมากครับ", "คุณทำได้ดีมาก!", "เก่งมากครับ! สู้ต่อไป"
  ];
  final List<String> encouragementsWhenWrong = [
    "ไม่เป็นไรครับ ลองใหม่อีกครั้งนะครับ",
    "ใกล้แล้วครับ ผมเชื่อว่าคุณทำได้",
    "ผิดนิดเดียวเองครับ ลองอีกที",
    "สู้ต่อไปครับ ทุกครั้งคือการเรียนรู้"
  ];

  int _lastRepetitionCount = 0;
  bool _isInFallPose = false;
  DateTime? _fallStartTime;
  bool _hasSentEmergency = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to first camera if no front camera
      );
      _isFrontCamera = frontCamera.lensDirection == CameraLensDirection.front;

      _controller = CameraController(
        frontCamera, 
        ResolutionPreset.medium, 
        enableAudio: false
      );
      await _controller!.initialize();

      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );

      await _initializeTTS();

      if (mounted) {
        await _controller!.startImageStream(_processImage);
        _startExerciseTimer();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage("th-TH");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(0.8);
      await _tts.setPitch(1.0);
      
      _tts.setCompletionHandler(() {
        if (mounted) {
          _isSpeaking = false;
          _processNextSpeech();
        }
      });
      
      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        if (mounted) {
          _isSpeaking = false;
          _processNextSpeech();
        }
      });
      
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
    }
  }

  Future<void> _speakSafely(String text, {Duration minDelay = const Duration(seconds: 1)}) async {
    if (text.isEmpty || !mounted) return;
    
    final now = DateTime.now();
    if (_lastSpeechTime != null && now.difference(_lastSpeechTime!) < minDelay) {
      return;
    }
    
    _speechQueue.add(text);
    _lastSpeechTime = now;
    
    if (!_processingQueue) {
      _processNextSpeech();
    }
  }

  Future<void> _processNextSpeech() async {
    if (_speechQueue.isEmpty || _processingQueue || !mounted) return;
    
    _processingQueue = true;
    
    while (_speechQueue.isNotEmpty && mounted) {
      final text = _speechQueue.removeFirst();
      
      if (_isSpeaking) {
        await _tts.stop();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      _isSpeaking = true;
      
      try {
        await _tts.speak(text);
        while (_isSpeaking && mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('Speech Error: $e');
        _isSpeaking = false;
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    _processingQueue = false;
  }

  void _startExerciseTimer() {
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() => _remainingSeconds--);

      if (_remainingSeconds <= 0) {
        _exerciseTimer?.cancel();
        _speakSafely("🎉 สิ้นสุดการฝึกวันนี้แล้ว ขอบคุณที่ร่วมฝึก");
        
        Timer(const Duration(seconds: 4), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/select-course');
          }
        });
        return;
      }

      if (_remainingSeconds % 60 == 0 && _remainingSeconds != 0) {
        _startRestPeriod();
      }
    });
  }

  void _startRestPeriod() async {
    if (!mounted) return;
    
    setState(() => _isResting = true);
    _speakSafely("⏸ ถึงเวลาพัก 10 วินาที");
    await _controller?.stopImageStream();

    _restTimer = Timer(const Duration(seconds: 10), () async {
      if (!mounted) return;
      setState(() => _isResting = false);
      _speakSafely("💪 เริ่มฝึกต่อได้เลย");
      await _controller?.startImageStream(_processImage);
    });
  }

  bool _shouldShowTurnHint(Map<PoseLandmarkType, Offset> points) {
    return !(points.containsKey(PoseLandmarkType.leftShoulder) &&
             points.containsKey(PoseLandmarkType.rightShoulder) &&
             (points[PoseLandmarkType.leftShoulder]!.dx - points[PoseLandmarkType.rightShoulder]!.dx).abs() > 60);
  }

  void _processImage(CameraImage image) async {
    if (_isDetecting || !_controller!.value.isStreamingImages || _isResting || !mounted) return;
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

        _checkFall(points);

        if (_shouldShowTurnHint(points)) {
          if (!_showTurnSideHint && mounted) {
            setState(() => _showTurnSideHint = true);
          }
          if (!_hasSpokenTurnHint) {
            _hasSpokenTurnHint = true;
            _speakSafely("กรุณาหันตัวด้านข้างให้กล้องมองเห็นท่าชัดเจนขึ้นนะครับ", 
                        minDelay: const Duration(seconds: 5));
          }
        } else {
          _hasSpokenTurnHint = false;
          if (_showTurnSideHint && mounted) {
            setState(() => _showTurnSideHint = false);
          }
        }

        String? result;
        if (evaluator != null) {
          if (evaluator is RepetitionEvaluator) {
            result = evaluator.update(points);

            final isCorrect = evaluator.evaluate(points);
            final feedbackText = evaluator.feedback;

            if (!isCorrect && feedbackText.isNotEmpty) {
              String feedbackMessage = "";

              if (UserSettings.enableTechnicalFeedback) {
                feedbackMessage = feedbackText;
              }

              if (UserSettings.enableEncouragement) {
                final phrase = encouragementsWhenWrong[Random().nextInt(encouragementsWhenWrong.length)];
                if (feedbackMessage.isNotEmpty) {
                  feedbackMessage += " $phrase";
                } else {
                  feedbackMessage = phrase;
                }
              }

              if (feedbackMessage.isNotEmpty) {
                _speakSafely(feedbackMessage, minDelay: const Duration(seconds: 2));
              }
            }

            if (evaluator.repetitionCount > _lastRepetitionCount && UserSettings.enableEncouragement) {
              _lastRepetitionCount = evaluator.repetitionCount;
              final phrase = encouragements[Random().nextInt(encouragements.length)];
              _speakSafely("$phrase ทำได้ $_lastRepetitionCount ครั้งแล้วครับ", minDelay: const Duration(seconds: 2));
            }

            if (mounted) {
              setState(() {
                _feedbackText = feedbackText;
              });
            }
          }
        }

        if (mounted) {
          setState(() {
            _landmarks = landmarks;
            _feedbackText = result;
          });
        }
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

  void _checkFall(Map<PoseLandmarkType, Offset> points) {
    final head = points[PoseLandmarkType.nose];
    final leftHip = points[PoseLandmarkType.leftHip];
    final rightHip = points[PoseLandmarkType.rightHip];
    final leftKnee = points[PoseLandmarkType.leftKnee];
    final rightKnee = points[PoseLandmarkType.rightKnee];

    if ([head, leftHip, rightHip, leftKnee, rightKnee].any((p) => p == null)) return;

    final hipY = (leftHip!.dy + rightHip!.dy) / 2;
    final kneeY = (leftKnee!.dy + rightKnee!.dy) / 2;
    final headY = head!.dy;

    final isHeadTooLow = headY > hipY + 100;
    final isHipTooLow = hipY > kneeY + 60;
    final now = DateTime.now();

    if (isHeadTooLow && isHipTooLow) {
      if (!_isInFallPose) {
        _isInFallPose = true;
        _fallStartTime = now;
      } else {
        final duration = now.difference(_fallStartTime!);
        if (duration > const Duration(seconds: 5) && !_hasSentEmergency) {
          _hasSentEmergency = true;
          _speakSafely("🚨 ตรวจพบว่าคุณอาจล้มลง และอยู่ในท่าล้มเป็นเวลานาน กำลังติดต่อหน่วยฉุกเฉิน", 
                      minDelay: const Duration(seconds: 2));
          _triggerEmergencyCall();
        }
      }
    } else {
      _isInFallPose = false;
      _fallStartTime = null;
      _hasSentEmergency = false;
    }
  }

  Future<void> _triggerEmergencyCall() async {
    if (!UserSettings.enableFallDetection) return;

    final String phoneNumber = UserSettings.emergencyPhone;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('❌ ไม่สามารถโทรออกได้: $phoneUri');
    }
  }

  void _stopSession() async {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    await _controller?.stopImageStream();
    
    _speakSafely("การฝึกสิ้นสุดแล้ว");
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/select-course');
      }
    });
  }

  void _testVoice() {
    _speakSafely("ระบบเสียงทำงานเรียบร้อยแล้ว ขณะนี้เป็นภาษาไทย");
  }

  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังเปิดกล้อง...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final previewSize = _controller!.value.previewSize!;
    final screenRatio = size.width / size.height;
    final cameraRatio = previewSize.height / previewSize.width;
    final cameraScale = cameraRatio / screenRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // full-screen zoomed & cropped camera
        ClipRect(
          child: Transform.scale(
            scale: cameraScale,
            child: Center(child: CameraPreview(_controller!)),
          ),
        ),

        // pose overlay
        if (_landmarks.isNotEmpty)
          CustomPaint(
            painter: PosePainter.fromLandmarks(
              _landmarks,
              previewSize.width,
              previewSize.height,
              isFrontCamera: _isFrontCamera,
            ),
          ),

        // course badge top-left
        Positioned(
          top: 50,
          left: 16,
          child: _glassContainer(
            child: Text(
              widget.courseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // turn-side hint
        if (_showTurnSideHint)
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: _glassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rotate_right, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "กรุณาหันตัวด้านข้างให้กล้องเห็นได้ชัดเจน",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // feedback text
        if (_feedbackText != null && _feedbackText!.isNotEmpty)
          Positioned(
            bottom: 130,
            left: 24,
            right: 24,
            child: _glassContainer(
              child: Text(
                _feedbackText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // bottom controls: timer, stop, test voice
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: _glassContainer(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isResting ? Icons.pause_circle : Icons.timer,
                      color: _isResting ? Colors.orange : Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isResting
                          ? 'กำลังพัก...'
                          : 'เหลือเวลา: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}', 
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop_circle_outlined, size: 20),
                      label: const Text("หยุดการฝึก"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _stopSession,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        _isSpeaking ? Icons.volume_off : Icons.volume_up,
                        size: 20,
                      ),
                      label: Text(_isSpeaking ? "กำลังพูด" : "ทดสอบเสียง"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSpeaking ? null : _testVoice,
                    ),
                  ],  
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
