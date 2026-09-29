import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card tile presenting a required system permission with action trigger.
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final String actionLabel;
  final VoidCallback onAction;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isGranted ? AppColors.accentMint.withValues(alpha: 0.4) : AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: isGranted ? AppColors.accentMint : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          if (!isGranted)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentPrimary,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                child: Text(actionLabel),
              ),
            ),
        ],
      ),
    );
  }
}
