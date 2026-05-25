import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

import '../models/gesture_type.dart';

/// Gesture recognition using the `hand_landmarker` package — real 21-point
/// MediaPipe hand landmarks via JNI on Android.
///
/// Each [Hand] contains 21 [Landmark] objects with normalized (0–1) x, y, z.
///
/// Standard MediaPipe hand landmark indices:
///   0 = wrist
///   4 = thumb tip,   3 = thumb IP,   2 = thumb MCP, 1 = thumb CMC
///   8 = index tip,   7 = index DIP,  6 = index PIP, 5 = index MCP
///   12 = middle tip, 11 = middle DIP, 10 = middle PIP, 9 = middle MCP
///   16 = ring tip,   15 = ring DIP,  14 = ring PIP, 13 = ring MCP
///   20 = pinky tip,  19 = pinky DIP, 18 = pinky PIP, 17 = pinky MCP
///
/// Detection strategy:
///   **PALM** — All 5 fingers extended (tip farther from wrist than MCP).
///   **FIST** — All 5 fingers curled (tip closer to wrist than MCP).
///   **LEFT/RIGHT/UP/DOWN** — Only index finger extended, others curled.
///     Direction = wrist→index tip vector.
class GestureRecognitionService {
  HandLandmarkerPlugin? _plugin;
  bool _isProcessing = false;
  bool _isInitialized = false;

  bool isFrontCamera = true;
  int _sensorOrientation = 0;
  int _frameCounter = 0;

  // ── Multi-frame confirmation ──
  GestureType _pendingGesture = GestureType.none;
  int _confirmCount = 0;
  static const int _confirmThreshold = 2;

  // ── Debug info ──
  bool _poseDetected = false;
  int _landmarkCount = 0;
  String _rawCandidate = '-';
  String _debugDistances = '';
  List<Landmark> _lastLandmarks = [];

  bool get poseDetected => _poseDetected;
  int get landmarkCount => _landmarkCount;
  String get rawCandidate => _rawCandidate;
  String get debugDistances => _debugDistances;
  List<Landmark> get lastLandmarks => _lastLandmarks;
  bool get isProcessing => _isProcessing;

  GestureRecognitionService();

  /// Initialize the hand landmarker plugin.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Try GPU first, fall back to CPU if GPU fails.
    try {
      _plugin = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.5,
        delegate: HandLandmarkerDelegate.gpu,
      );
      _isInitialized = true;
      _rawCandidate = 'init OK (GPU)';
      debugPrint('HandLandmarkerPlugin initialized (GPU)');
    } catch (e) {
      debugPrint('HandLandmarkerPlugin GPU init failed: $e');
      try {
        _plugin = HandLandmarkerPlugin.create(
          numHands: 1,
          minHandDetectionConfidence: 0.5,
          delegate: HandLandmarkerDelegate.cpu,
        );
        _isInitialized = true;
        _rawCandidate = 'init OK (CPU)';
        debugPrint('HandLandmarkerPlugin initialized (CPU fallback)');
      } catch (e2) {
        debugPrint('HandLandmarkerPlugin CPU init also failed: $e2');
        _rawCandidate = 'INIT FAIL: $e2';
      }
    }
  }

  /// Set the sensor orientation (from CameraDescription.sensorOrientation).
  void setSensorOrientation(int orientation) {
    _sensorOrientation = orientation;
  }

  /// Process a camera frame and return the detected gesture.
  Future<GestureType> processCameraImage(CameraImage image) async {
    if (_isProcessing || !_isInitialized || _plugin == null) {
      return GestureType.none;
    }
    _isProcessing = true;
    _frameCounter++;

    try {
      final hands = _plugin!.detect(image, _sensorOrientation);

      // Log every 30th frame so we can see if detect() is running.
      if (_frameCounter % 30 == 0) {
        debugPrint(
          'HandLandmarker frame #$_frameCounter: '
          '${hands.length} hands, '
          'img ${image.width}x${image.height} '
          'fmt=${image.format.group.name} '
          'orient=$_sensorOrientation',
        );
      }

      if (hands.isEmpty) {
        _poseDetected = false;
        _landmarkCount = 0;
        _rawCandidate = 'no hand (#$_frameCounter)';
        _debugDistances =
            '${image.width}x${image.height} ${image.format.group.name}';
        _lastLandmarks = [];
        _resetConfirmation();
        return GestureType.none;
      }

      _poseDetected = true;
      final hand = hands.first;
      _landmarkCount = hand.landmarks.length;
      _lastLandmarks = hand.landmarks;

      debugPrint('HAND DETECTED! ${hand.landmarks.length} landmarks');
      return _analyzeHand(hand);
    } catch (e) {
      debugPrint('GestureRecognition error: $e');
      _rawCandidate = 'ERR: $e';
      return GestureType.none;
    } finally {
      _isProcessing = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Hand analysis using 21 MediaPipe landmarks
  // ──────────────────────────────────────────────────────────────────────────

  GestureType _analyzeHand(Hand hand) {
    final lm = hand.landmarks;
    if (lm.length < 21) {
      _rawCandidate = 'incomplete (${lm.length})';
      return GestureType.none;
    }

    // ── Key landmarks ──
    final wrist = lm[0];

    // Finger tips and PIPs (proximal interphalangeal joints).
    // A finger is "extended" when tip.y < pip.y (tip is ABOVE pip in image).
    // For thumb: tip.x vs ip.x (thumb extends sideways).
    final thumbTip = lm[4];
    final thumbIp = lm[3];
    final thumbMcp = lm[2];

    final indexTip = lm[8];
    final indexPip = lm[6];

    final middleTip = lm[12];
    final middlePip = lm[10];

    final ringTip = lm[16];
    final ringPip = lm[14];

    final pinkyTip = lm[20];
    final pinkyPip = lm[18];

    // ── Check which fingers are extended ──
    // For fingers (index, middle, ring, pinky): compare tip vs PIP
    //   along the wrist→finger axis. If tip is farther from wrist
    //   than PIP (in the direction the hand points), finger is extended.
    final indexExt = _isFingerExtended(wrist, indexTip, indexPip);
    final middleExt = _isFingerExtended(wrist, middleTip, middlePip);
    final ringExt = _isFingerExtended(wrist, ringTip, ringPip);
    final pinkyExt = _isFingerExtended(wrist, pinkyTip, pinkyPip);

    // Thumb: compare tip vs IP distance from the wrist.
    // Thumb extends sideways, so pure Y comparison doesn't work.
    final thumbExt = _isThumbExtended(thumbTip, thumbIp, thumbMcp);

    final extCount =
        (thumbExt ? 1 : 0) +
        (indexExt ? 1 : 0) +
        (middleExt ? 1 : 0) +
        (ringExt ? 1 : 0) +
        (pinkyExt ? 1 : 0);

    // Debug output.
    _debugDistances =
        'T:${thumbExt ? "1" : "0"} '
        'I:${indexExt ? "1" : "0"} '
        'M:${middleExt ? "1" : "0"} '
        'R:${ringExt ? "1" : "0"} '
        'P:${pinkyExt ? "1" : "0"} '
        '($extCount/5)';

    // ────────────────────────────────────────────────────────────────────────
    // PALM — 4+ fingers extended (open hand).
    // ────────────────────────────────────────────────────────────────────────
    if (extCount >= 4) {
      _rawCandidate = 'PALM ✋ ($extCount/5)';
      return _confirm(GestureType.palm);
    }

    // ────────────────────────────────────────────────────────────────────────
    // FIST — 0 or 1 fingers extended AND index NOT extended.
    // ────────────────────────────────────────────────────────────────────────
    if (extCount <= 1 && !indexExt) {
      _rawCandidate = 'FIST ✊ ($extCount/5)';
      return _confirm(GestureType.fist);
    }

    // ────────────────────────────────────────────────────────────────────────
    // POINTING — index extended, at least 2 of (middle, ring, pinky) curled.
    // Direction = wrist → index tip vector.
    // ────────────────────────────────────────────────────────────────────────
    final curledOthers =
        (!middleExt ? 1 : 0) + (!ringExt ? 1 : 0) + (!pinkyExt ? 1 : 0);

    if (indexExt && curledOthers >= 2) {
      // Raw direction in sensor coordinates.
      var rawDx = indexTip.x - wrist.x;
      var rawDy = indexTip.y - wrist.y;

      // Rotate direction vector to match screen orientation.
      double dx, dy;
      switch (_sensorOrientation) {
        case 90:
          dx = -rawDy;
          dy = rawDx;
          break;
        case 180:
          dx = -rawDx;
          dy = -rawDy;
          break;
        case 270:
          dx = rawDy;
          dy = -rawDx;
          break;
        default: // 0
          dx = rawDx;
          dy = rawDy;
      }

      // Front camera preview is mirrored horizontally.
      if (isFrontCamera) dx = -dx;

      final absDx = dx.abs();
      final absDy = dy.abs();

      if (absDx > absDy * 1.2) {
        final g = dx > 0 ? GestureType.right : GestureType.left;
        _rawCandidate = '${g.name.toUpperCase()} 👆';
        return _confirm(g);
      }
      if (absDy > absDx * 1.2) {
        final g = dy > 0 ? GestureType.down : GestureType.up;
        _rawCandidate = '${g.name.toUpperCase()} 👆';
        return _confirm(g);
      }

      _rawCandidate = 'point diagonal';
      return GestureType.none;
    }

    _rawCandidate = 'fingers: $extCount';
    _resetConfirmation();
    return GestureType.none;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Check if a finger is extended by comparing tip vs PIP distance from wrist.
  /// A finger is extended when its tip is farther from the wrist than its PIP.
  bool _isFingerExtended(Landmark wrist, Landmark tip, Landmark pip) {
    final tipDist = _dist(wrist, tip);
    final pipDist = _dist(wrist, pip);
    // Tip must be noticeably farther from wrist than PIP.
    return tipDist > pipDist * 1.05;
  }

  /// Thumb detection: the thumb extends sideways, so we compare
  /// the distance from tip to MCP base. When thumb is extended,
  /// the tip→MCP distance is much larger than ip→MCP distance.
  bool _isThumbExtended(
    Landmark thumbTip,
    Landmark thumbIp,
    Landmark thumbMcp,
  ) {
    final tipToMcp = _dist(thumbTip, thumbMcp);
    final ipToMcp = _dist(thumbIp, thumbMcp);
    return tipToMcp > ipToMcp * 1.2;
  }

  double _dist(Landmark a, Landmark b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

  GestureType _confirm(GestureType gesture) {
    if (_pendingGesture == gesture) {
      _confirmCount++;
      if (_confirmCount >= _confirmThreshold) {
        _resetConfirmation();
        return gesture;
      }
    } else {
      _pendingGesture = gesture;
      _confirmCount = 1;
    }
    return GestureType.none;
  }

  void _resetConfirmation() {
    _pendingGesture = GestureType.none;
    _confirmCount = 0;
  }

  void reset() {
    _resetConfirmation();
    _poseDetected = false;
    _rawCandidate = '-';
    _debugDistances = '';
    _lastLandmarks = [];
  }

  void dispose() {
    _plugin?.dispose();
    _plugin = null;
    _isInitialized = false;
  }
}
