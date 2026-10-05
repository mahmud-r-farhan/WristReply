import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card tile presenting a single Android runtime permission with action trigger.
///
/// Designed for the OLED Dark Utility aesthetic — high contrast, glanceable,
/// and respecting the 48dp minimum touch target via the trailing button.
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final bool isOptional;
  final bool isLoading;
  final String actionLabel;
  final VoidCallback onAction;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isGranted,
    this.isOptional = false,
    this.isLoading = false,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
              _StatusDot(isGranted: isGranted, isLoading: isLoading),
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
                      const _OptionalBadge(),
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
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: isLoading ? null : onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: isOptional ? AppColors.accentMint : AppColors.accentPrimary,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isGranted;
  final bool isLoading;
  const _StatusDot({required this.isGranted, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPrimary),
      );
    }
    return Icon(
      isGranted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
      color: isGranted ? AppColors.accentMint : AppColors.textTertiary,
      size: 22,
    );
  }
}

class _OptionalBadge extends StatelessWidget {
  const _OptionalBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceInteractive,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
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
    );
  }
}