import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';

/// Section widget for Master Daemon and App Notification sending controls.
class MasterControlSection extends StatelessWidget {
  final bool masterEnabled;
  final ValueChanged<bool> onMasterChanged;
  final bool notificationsEnabled;
  final bool hasNotificationPermission;
  final ValueChanged<bool> onNotificationsChanged;

  const MasterControlSection({
    super.key,
    required this.masterEnabled,
    required this.onMasterChanged,
    required this.notificationsEnabled,
    required this.hasNotificationPermission,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Master Engine Control'),
        ToggleSwitchTile(
          title: 'Enable WristReply Daemon',
          description: 'Active background interception of messaging notifications',
          value: masterEnabled,
          icon: Icons.power_settings_new_rounded,
          onChanged: onMasterChanged,
        ),
        ToggleSwitchTile(
          title: AppStrings.appNotificationSendTitle,
          description: hasNotificationPermission
              ? AppStrings.appNotificationSendDesc
              : '${AppStrings.appNotificationSendDesc} (Permission required)',
          value: notificationsEnabled,
          icon: Icons.notifications_active_outlined,
          onChanged: onNotificationsChanged,
        ),
      ],
    );
  }
}
