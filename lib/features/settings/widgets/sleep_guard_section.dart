import 'package:flutter/material.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';

/// Section widget for Do Not Disturb and Quiet Hours controls.
class SleepGuardSection extends StatelessWidget {
  final bool respectDnd;
  final ValueChanged<bool> onRespectDndChanged;
  final bool sleepWindow;
  final ValueChanged<bool> onSleepWindowChanged;

  const SleepGuardSection({
    super.key,
    required this.respectDnd,
    required this.onRespectDndChanged,
    required this.sleepWindow,
    required this.onSleepWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Zero-Wake Sleep Guard'),
        ToggleSwitchTile(
          title: 'Respect System DND',
          description: 'Suppress Smart Reply generation when Do Not Disturb is active',
          value: respectDnd,
          icon: Icons.do_not_disturb_on_outlined,
          onChanged: onRespectDndChanged,
        ),
        ToggleSwitchTile(
          title: 'Scheduled Quiet Hours',
          description: 'Zero-CPU sleep mode between 23:00 and 06:30',
          value: sleepWindow,
          icon: Icons.bedtime_outlined,
          onChanged: onSleepWindowChanged,
        ),
      ],
    );
  }
}
