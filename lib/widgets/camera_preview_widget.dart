import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../services/camera_service.dart';

/// Small camera preview widget displayed as an overlay in a corner.
class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;

  const CameraPreviewWidget({super.key, required this.cameraService});

  @override
  Widget build(BuildContext context) {
    final isReady =
        cameraService.isInitialized && cameraService.controller != null;

    return Container(
      width: AppConstants.cameraPreviewWidth,
      height: AppConstants.cameraPreviewHeight,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryOrange, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: isReady
          ? CameraPreview(cameraService.controller!)
          : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white38, size: 28),
                  SizedBox(height: 4),
                  Text(
                    'No camera',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
    );
  }
}
