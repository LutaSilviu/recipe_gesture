import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../controllers/gesture_controller.dart';
import '../models/gesture_type.dart';
import '../models/recipe.dart';
import '../widgets/camera_preview_widget.dart';

/// Full-screen recipe detail with ingredients and steps.
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final GestureController gestureController;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.gestureController,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollAmount = 250.0;

  @override
  void initState() {
    super.initState();
    widget.gestureController.pushHandler(_handleGesture);
  }

  @override
  void dispose() {
    widget.gestureController.popHandler();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleGesture(GestureType gesture) {
    switch (gesture) {
      case GestureType.palm:
        if (mounted) Navigator.pop(context);
      case GestureType.down:
        _scroll(_scrollAmount);
      case GestureType.up:
        _scroll(-_scrollAmount);
      default:
        break;
    }
  }

  void _scroll(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Hero app bar ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppConstants.darkBackground,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppConstants.primaryOrange.withAlpha(60),
                          AppConstants.darkBackground,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Time & difficulty chips ──
                      Row(
                        children: [
                          _infoChip('⏱  ${recipe.time}'),
                          const SizedBox(width: 10),
                          _infoChip('📊  ${recipe.difficulty}'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Description ──
                      Text(
                        recipe.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Ingredients ──
                      _sectionTitle('🧂  Ingredients'),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map(_ingredientCard),
                      const SizedBox(height: 24),

                      // ── Steps ──
                      _sectionTitle('👩‍🍳  Steps'),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map(
                        (e) => _stepCard(e.key + 1, e.value),
                      ),
                      const SizedBox(height: 24),

                      // ── Back hint ──
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✋ Palm = Back  ↑↓ Point = Scroll',
                            style: TextStyle(
                              color: AppConstants.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
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

  // ── Helper widgets ──

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppConstants.textLight),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.accentGold,
      ),
    );
  }

  Widget _ingredientCard(String ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Text(
              '•  ',
              style: TextStyle(color: AppConstants.primaryOrange),
            ),
            Expanded(
              child: Text(
                ingredient,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard(int number, String step) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppConstants.primaryOrange,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
