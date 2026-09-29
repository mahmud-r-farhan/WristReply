import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';

/// Card for configuring Bluetooth Car Audio detection and driving auto-replies.
class DrivingModeCard extends StatelessWidget {
  final bool isDrivingEnabled;
  final bool isAutoReplyEnabled;
  final TextEditingController templateController;
  final ValueChanged<bool> onDrivingChanged;
  final ValueChanged<bool> onAutoReplyChanged;
  final ValueChanged<String> onTemplateChanged;

  const DrivingModeCard({
    super.key,
    required this.isDrivingEnabled,
    required this.isAutoReplyEnabled,
    required this.templateController,
    required this.onDrivingChanged,
    required this.onAutoReplyChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleSwitchTile(
          title: 'Auto-Detect Driving (Bluetooth)',
          description: 'Detects connection to Car Audio or Bluetooth Headset (A2DP)',
          value: isDrivingEnabled,
          icon: Icons.directions_car_rounded,
          onChanged: onDrivingChanged,
        ),
        if (isDrivingEnabled) ...[
          const SizedBox(height: 8),
          ToggleSwitchTile(
            title: 'Autonomous Auto-Reply While Driving',
            description: 'Automatically dispatches reply without touching watch or phone',
            value: isAutoReplyEnabled,
            icon: Icons.send_rounded,
            onChanged: onAutoReplyChanged,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: TextField(
              controller: templateController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              onChanged: onTemplateChanged,
              decoration: InputDecoration(
                labelText: 'Driving Auto-Reply Template',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceCanvas,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
