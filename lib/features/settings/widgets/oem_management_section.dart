import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/section_header.dart';

/// Section widget for OEM Keep-Alive autostart management.
class OemManagementSection extends StatelessWidget {
  const OemManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'OEM Keep-Alive Management'),
        ElevatedButton.icon(
          onPressed: () => NativeChannel.openOemAutostart(),
          icon: const Icon(Icons.settings_suggest_rounded),
          label: const Text('OPEN OEM AUTOSTART MANAGER'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceInteractive,
            foregroundColor: AppColors.accentMint,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
