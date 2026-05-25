import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/app.dart';
import 'services/camera_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request camera permission at startup.
  await Permission.camera.request();

  // Initialise camera – may fail on emulators or devices without a camera.
  // The app remains fully functional via the gesture simulator.
  final cameraService = CameraService();
  await cameraService.initialize();

  runApp(RecipeApp(cameraService: cameraService));
}
