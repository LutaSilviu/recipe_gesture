import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../controllers/gesture_controller.dart';
import '../models/gesture_type.dart';

/// Compact debug panel showing gesture status and mapping.
class GestureDebugPanel extends StatelessWidget {
  final GestureController gestureController;

  const GestureDebugPanel({super.key, required this.gestureController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gestureController,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.surfaceDark.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status row ──
              Row(
                children: [
                  const Text(
                    'Gesture Debug',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppConstants.accentGold,
                    ),
                  ),
                  const Spacer(),
                  _statusChip(
                    'POSE',
                    gestureController.poseDetected,
                    Colors.cyanAccent,
                  ),
                  const SizedBox(width: 6),
                  _statusChip(
                    'REC',
                    gestureController.isActive,
                    AppConstants.successGreen,
                  ),
                  const SizedBox(width: 6),
                  _statusChip(
                    'CD',
                    gestureController.isCooldown,
                    AppConstants.warningAmber,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Last gesture + raw candidate ──
              Row(
                children: [
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: gestureController.lastGesture != GestureType.none
                          ? 1
                          : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        'Last: ${gestureController.lastGesture.label}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'raw: ${gestureController.rawCandidate}',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),

              // ── Raw distances (finger ratios) ──
              if (gestureController.debugDistances.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    gestureController.debugDistances,
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      color: Colors.white30,
                    ),
                  ),
                ),

              const Divider(height: 12, color: Colors.white24),

              // ── Mapping ──
              Wrap(
                spacing: 12,
                runSpacing: 2,
                children: GestureType.values
                    .where((g) => g != GestureType.none)
                    .map(
                      (g) => Text(
                        '${g.name.toUpperCase()} = ${g.actionDescription}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String label, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? color.withAlpha(50) : Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? color : Colors.white24, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? color : Colors.white38,
        ),
      ),
    );
  }
}
