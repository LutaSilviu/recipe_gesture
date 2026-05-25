import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../controllers/gesture_controller.dart';
import '../controllers/recipe_menu_controller.dart';
import '../models/gesture_type.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/gesture_debug_panel.dart';
import '../widgets/gesture_simulator_panel.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

/// Main grid screen listing all recipes.
class RecipeMenuScreen extends StatefulWidget {
  final GestureController gestureController;
  final RecipeMenuController menuController;

  const RecipeMenuScreen({
    super.key,
    required this.gestureController,
    required this.menuController,
  });

  @override
  State<RecipeMenuScreen> createState() => _RecipeMenuScreenState();
}

class _RecipeMenuScreenState extends State<RecipeMenuScreen> {
  @override
  void initState() {
    super.initState();
    widget.gestureController.pushHandler(_handleGesture);
  }

  @override
  void dispose() {
    widget.gestureController.popHandler();
    super.dispose();
  }

  // ── Gesture handling ──

  void _handleGesture(GestureType gesture) {
    switch (gesture) {
      case GestureType.left:
        widget.menuController.moveLeft();
      case GestureType.right:
        widget.menuController.moveRight();
      case GestureType.up:
        widget.menuController.moveUp();
      case GestureType.down:
        widget.menuController.moveDown();
      case GestureType.fist:
        _openRecipeDetail();
      case GestureType.palm:
        _showAlreadyOnMainMenu();
      case GestureType.none:
        break;
    }
  }

  void _openRecipeDetail() {
    final recipe = widget.menuController.selectedRecipe;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          recipe: recipe,
          gestureController: widget.gestureController,
        ),
      ),
    );
  }

  void _showAlreadyOnMainMenu() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Already on main menu'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          ListenableBuilder(
            listenable: widget.gestureController,
            builder: (context, _) {
              final isActive = widget.gestureController.isActive;
              return IconButton(
                tooltip: isActive
                    ? 'Stop gesture recognition'
                    : 'Start gesture recognition',
                icon: Icon(
                  isActive ? Icons.videocam : Icons.videocam_off,
                  color: isActive ? AppConstants.successGreen : Colors.white54,
                ),
                onPressed: widget.gestureController.toggleRecognition,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Main content column ──
          Column(
            children: [
              Expanded(child: _buildGrid()),
              GestureDebugPanel(gestureController: widget.gestureController),
              GestureSimulatorPanel(
                gestureController: widget.gestureController,
              ),
              const SizedBox(height: 8),
            ],
          ),

          // ── Camera preview overlay ──
          Positioned(
            top: 8,
            right: 8,
            child: CameraPreviewWidget(
              cameraService: widget.gestureController.cameraService,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return ListenableBuilder(
      listenable: widget.menuController,
      builder: (context, _) {
        final recipes = widget.menuController.recipes;
        final selectedIdx = widget.menuController.selectedIndex;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: GridView.builder(
            itemCount: recipes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppConstants.gridColumns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              return RecipeCard(
                recipe: recipes[index],
                isSelected: index == selectedIdx,
                onTap: () {
                  // Tap to select + open immediately.
                  if (index != selectedIdx) {
                    // Update selection visually first.
                    widget.menuController.moveToIndex(index);
                  }
                  _openRecipeDetail();
                },
              );
            },
          ),
        );
      },
    );
  }
}
