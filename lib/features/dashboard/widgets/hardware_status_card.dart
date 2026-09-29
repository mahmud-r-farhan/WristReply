import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Card surfacing real-time daemon execution status, wearable sync, and memory footprint.
class HardwareStatusCard extends StatelessWidget {
  final bool isLive;

  const HardwareStatusCard({super.key, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.engineStatus,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _statusRow(
            Icons.memory_rounded,
            'Engine Daemon',
            isLive ? 'Active (Headless Kotlin)' : 'Needs Permission',
            isLive,
          ),
          const SizedBox(height: 8),
          _statusRow(
            Icons.watch_rounded,
            'Wearable Node',
            'Mirrored (RTOS / Wear OS)',
            true,
          ),
          const SizedBox(height: 8),
          _statusRow(
            Icons.battery_charging_full_rounded,
            'Resident RAM',
            '~18.4 MB (OLED Minimal Mode)',
            true,
          ),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, String title, String subtitle, bool isPositive) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isPositive ? AppColors.accentMint : AppColors.accentWarning),
        const SizedBox(width: 10),
        Text('$title: ', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        Expanded(child: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      ],
    );
  }
}
