import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../controllers/gesture_controller.dart';
import '../models/gesture_type.dart';

/// Row of buttons to simulate each gesture for testing / debug.
class GestureSimulatorPanel extends StatelessWidget {
  final GestureController gestureController;

  const GestureSimulatorPanel({super.key, required this.gestureController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Gesture Simulator',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppConstants.accentGold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _simButton(context, GestureType.left, '←'),
              _simButton(context, GestureType.up, '↑'),
              _simButton(context, GestureType.down, '↓'),
              _simButton(context, GestureType.right, '→'),
              _simButton(context, GestureType.fist, '✊'),
              _simButton(context, GestureType.palm, '✋'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simButton(BuildContext context, GestureType gesture, String icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.cardBackground,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => gestureController.reportGesture(gesture),
          child: Text(icon, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
