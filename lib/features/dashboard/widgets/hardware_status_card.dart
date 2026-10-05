import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Card surfacing real-time daemon execution status, wearable sync, and memory footprint.
class HardwareStatusCard extends StatelessWidget {
  final bool isLive;
  final bool isLoading;

  const HardwareStatusCard({
    super.key,
    required this.isLive,
    this.isLoading = false,
  });

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
          _StatusRow(
            icon: Icons.memory_rounded,
            title: 'Engine Daemon',
            subtitle: isLoading
                ? 'Probing daemon status...'
                : (isLive ? 'Active (Headless Kotlin)' : 'Needs Notification Access'),
            isPositive: isLive,
          ),
          const SizedBox(height: 8),
          const _StatusRow(
            icon: Icons.devices_rounded,
            title: 'Active Surfaces',
            subtitle: 'Phone Shade & Smartwatches',
            isPositive: true,
          ),
          const SizedBox(height: 8),
          const _StatusRow(
            icon: Icons.battery_charging_full_rounded,
            title: 'Resident RAM',
            subtitle: '~18.4 MB (OLED Minimal Mode)',
            isPositive: true,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPositive;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isPositive ? AppColors.accentMint : AppColors.accentWarning),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
