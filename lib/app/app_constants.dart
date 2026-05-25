import 'dart:ui';

/// Centralized constants for the application.
class AppConstants {
  AppConstants._();

  static const String appTitle = 'Touchless Recipe Menu';
  static const int gridColumns = 2;
  static const Duration gestureCooldown = Duration(milliseconds: 1500);

  /// Process every Nth camera frame to avoid overload.
  static const int frameSkip = 5;

  /// Minimum wrist displacement (in image pixels) to trigger a directional gesture.
  static const double movementThreshold = 40.0;

  /// Number of wrist positions tracked for movement detection.
  static const int wristHistorySize = 8;

  // ── Colors ──
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF16213E);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color surfaceDark = Color(0xFF0F3460);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFB300);

  // ── Camera preview ──
  static const double cameraPreviewWidth = 160.0;
  static const double cameraPreviewHeight = 220.0;
}
