import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../app/app_constants.dart';
import '../models/gesture_type.dart';
import '../services/camera_service.dart';
import '../services/gesture_recognition_service.dart';

typedef GestureCallback = void Function(GestureType gesture);

/// Central controller that bridges camera, recognition service, and the UI.
///
/// Provides:
///  - a handler-stack so each screen can register / unregister its gesture
///    callback (top-of-stack receives gestures);
///  - cooldown / debounce;
///  - camera ↔ ML Kit image conversion.
///
/// Both camera-detected and simulator-injected gestures flow through
/// [reportGesture], ensuring a single code path.
class GestureController extends ChangeNotifier {
  final CameraService _cameraService;
  final GestureRecognitionService _recognitionService;

  GestureType _lastGesture = GestureType.none;
  bool _isActive = false;
  bool _isCooldown = false;
  int _frameCount = 0;

  final List<GestureCallback> _handlerStack = [];

  GestureController({
    required CameraService cameraService,
    required GestureRecognitionService recognitionService,
  }) : _cameraService = cameraService,
       _recognitionService = recognitionService;

  // ── Public getters ──

  GestureType get lastGesture => _lastGesture;
  bool get isActive => _isActive;
  bool get isCooldown => _isCooldown;
  CameraService get cameraService => _cameraService;
  bool get isCameraAvailable => _cameraService.isInitialized;

  // ── Recognition debug info ──
  bool get poseDetected => _recognitionService.poseDetected;
  int get landmarkCount => _recognitionService.landmarkCount;
  String get rawCandidate => _recognitionService.rawCandidate;
  String get debugDistances => _recognitionService.debugDistances;
  int get sensorOrientation =>
      _cameraService.currentCamera?.sensorOrientation ?? 270;

  // ── Handler stack ──

  void pushHandler(GestureCallback handler) => _handlerStack.add(handler);

  void popHandler() {
    if (_handlerStack.isNotEmpty) _handlerStack.removeLast();
  }

  // ── Gesture reporting (single entry point) ──

  /// Report a gesture from *any* source (camera or simulator).
  void reportGesture(GestureType gesture) {
    if (gesture == GestureType.none || _isCooldown) return;
    _lastGesture = gesture;
    _startCooldown();
    notifyListeners();
    if (_handlerStack.isNotEmpty) {
      _handlerStack.last(gesture);
    }
  }

  void _startCooldown() {
    _isCooldown = true;
    notifyListeners();
    Future.delayed(AppConstants.gestureCooldown, () {
      _isCooldown = false;
      notifyListeners();
    });
  }

  // ── Camera-based recognition ──

  Future<void> startRecognition() async {
    if (!_cameraService.isInitialized) return;
    _isActive = true;
    _frameCount = 0;
    _recognitionService.isFrontCamera = _cameraService.isFrontCamera;

    // Initialize the hand detector if not already done.
    await _recognitionService.initialize();

    // Pass sensor orientation for correct image rotation.
    final camera = _cameraService.currentCamera;
    if (camera != null) {
      _recognitionService.setSensorOrientation(camera.sensorOrientation);
    }

    notifyListeners();

    _cameraService.startImageStream((CameraImage image) {
      _frameCount++;
      if (_frameCount % AppConstants.frameSkip != 0) return;
      if (_isCooldown || _recognitionService.isProcessing) return;

      _recognitionService.processCameraImage(image).then((gesture) {
        if (gesture != GestureType.none) reportGesture(gesture);
        // Notify for debug info updates even without gesture.
        notifyListeners();
      });
    });
  }

  void stopRecognition() {
    _cameraService.stopImageStream();
    _isActive = false;
    _recognitionService.reset();
    notifyListeners();
  }

  void toggleRecognition() {
    _isActive ? stopRecognition() : startRecognition();
  }

  // ── Lifecycle ──

  @override
  void dispose() {
    stopRecognition();
    _recognitionService.dispose();
    _cameraService.dispose();
    _handlerStack.clear();
    super.dispose();
  }
}
