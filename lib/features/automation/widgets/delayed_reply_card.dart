import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';

/// Card for configuring delayed timer auto-replies with cancellation guard.
class DelayedReplyCard extends StatelessWidget {
  final bool enabled;
  final int delayMinutes;
  final TextEditingController controller;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<String> onTemplateChanged;

  const DelayedReplyCard({
    super.key,
    required this.enabled,
    required this.delayMinutes,
    required this.controller,
    required this.onEnabledChanged,
    required this.onMinutesChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleSwitchTile(
          title: 'Enable Delayed Auto-Reply',
          description: 'Fires an automated reply if you do not interact with the notification',
          value: enabled,
          icon: Icons.timer_outlined,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delay Duration', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text('$delayMinutes min', style: const TextStyle(color: AppColors.accentMint, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: delayMinutes.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: AppColors.accentMint,
                  onChanged: (val) => onMinutesChanged(val.toInt()),
                ),
                const SizedBox(height: 8),
                const Text('Response Template', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: onTemplateChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceCanvas,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceInteractive,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accentPrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dismissing the notification on your phone or smartwatch immediately cancels the pending auto-reply.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
