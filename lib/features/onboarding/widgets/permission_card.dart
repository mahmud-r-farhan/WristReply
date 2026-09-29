import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card tile presenting a system permission with action trigger.
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final bool isOptional;
  final String actionLabel;
  final VoidCallback onAction;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isGranted,
    this.isOptional = false,
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
        border: Border.all(
          color: isGranted ? AppColors.accentMint.withValues(alpha: 0.4) : AppColors.borderSubtle,
        ),
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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceInteractive,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.textTertiary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'OPTIONAL',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (!isGranted)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: isOptional ? AppColors.accentMint : AppColors.accentPrimary,
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
