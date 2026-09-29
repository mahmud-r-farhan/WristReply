import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Small branding footer displayed at the bottom of settings.
class SettingsBrandingFooter extends StatelessWidget {
  const SettingsBrandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28),
        Center(
          child: Text(
            'WristReply AI by Bengal Bytes',
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
