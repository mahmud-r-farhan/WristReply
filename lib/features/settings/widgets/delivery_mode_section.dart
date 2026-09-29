import 'package:flutter/material.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';
import 'pills_count_tile.dart';

/// Section widget for notification delivery mode, privacy masking, and pill count.
class DeliveryModeSection extends StatelessWidget {
  final bool replaceMode;
  final ValueChanged<bool> onReplaceModeChanged;
  final bool privacyMode;
  final ValueChanged<bool> onPrivacyModeChanged;
  final int pillsPerMessage;
  final ValueChanged<int> onPillsCountChanged;

  const DeliveryModeSection({
    super.key,
    required this.replaceMode,
    required this.onReplaceModeChanged,
    required this.privacyMode,
    required this.onPrivacyModeChanged,
    required this.pillsPerMessage,
    required this.onPillsCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Notification Delivery Mode'),
        ToggleSwitchTile(
          title: 'Replace Mode (Opt-in)',
          description: 'Cancels original notification and reposts with merged pills',
          value: replaceMode,
          icon: Icons.sync_alt_rounded,
          onChanged: onReplaceModeChanged,
        ),
        ToggleSwitchTile(
          title: 'Privacy Mode (Mask Text)',
          description: 'Hides conversational preview and displays ••••••••••',
          value: privacyMode,
          icon: Icons.visibility_off_outlined,
          onChanged: onPrivacyModeChanged,
        ),
        PillsCountTile(
          count: pillsPerMessage,
          onChanged: onPillsCountChanged,
        ),
      ],
    );
  }
}
