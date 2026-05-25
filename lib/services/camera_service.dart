import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Manages the device camera: initialisation, preview controller, and image stream.
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isStreaming = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isStreaming => _isStreaming;
  bool get isAvailable => _cameras != null && _cameras!.isNotEmpty;

  /// Returns the front-facing camera if available, otherwise the first camera.
  CameraDescription? get currentCamera {
    if (_cameras == null || _cameras!.isEmpty) return null;
    for (final c in _cameras!) {
      if (c.lensDirection == CameraLensDirection.front) return c;
    }
    return _cameras!.first;
  }

  bool get isFrontCamera =>
      currentCamera?.lensDirection == CameraLensDirection.front;

  /// Initialise the camera. Returns `true` on success.
  Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return false;

      final camera = currentCamera!;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('CameraService: initialisation failed – $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Start streaming camera frames.
  void startImageStream(void Function(CameraImage image) onImage) {
    if (_controller == null || !_isInitialized || _isStreaming) return;
    _controller!.startImageStream(onImage);
    _isStreaming = true;
  }

  /// Stop the image stream.
  void stopImageStream() {
    if (_controller == null || !_isStreaming) return;
    try {
      _controller!.stopImageStream();
    } catch (_) {
      // Controller may already be disposed.
    }
    _isStreaming = false;
  }

  /// Release camera resources.
  void dispose() {
    stopImageStream();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
