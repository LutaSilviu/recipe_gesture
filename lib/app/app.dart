import 'package:flutter/material.dart';

import '../controllers/gesture_controller.dart';
import '../controllers/recipe_menu_controller.dart';
import '../repositories/recipe_repository.dart';
import '../screens/recipe_menu_screen.dart';
import '../services/camera_service.dart';
import '../services/gesture_recognition_service.dart';
import 'app_constants.dart';
import 'app_theme.dart';

/// Root widget that creates all services / controllers and manages lifecycle.
class RecipeApp extends StatefulWidget {
  final CameraService cameraService;

  const RecipeApp({super.key, required this.cameraService});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> with WidgetsBindingObserver {
  late final GestureRecognitionService _recognitionService;
  late final GestureController _gestureController;
  late final RecipeMenuController _menuController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _recognitionService = GestureRecognitionService();
    _gestureController = GestureController(
      cameraService: widget.cameraService,
      recognitionService: _recognitionService,
    );
    _menuController = RecipeMenuController(recipes: RecipeRepository.recipes);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gestureController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  /// Stop the camera stream when the app goes to background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _gestureController.stopRecognition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: RecipeMenuScreen(
        gestureController: _gestureController,
        menuController: _menuController,
      ),
    );
  }
}
