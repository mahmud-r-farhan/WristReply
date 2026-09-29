import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/adaptive_content_container.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';
import '../widgets/delayed_reply_card.dart';
import '../widgets/driving_mode_card.dart';

/// Screen for managing automated triggers, driving detection, and meeting replies.
class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  bool _delayedEnabled = false;
  int _delayMinutes = 5;
  final TextEditingController _delayedController =
      TextEditingController(text: 'Busy right now, will reply shortly.');

  bool _drivingEnabled = false;
  bool _drivingAutoReply = false;
  final TextEditingController _drivingController =
      TextEditingController(text: 'Driving right now, will reply once parked.');

  bool _calendarEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _delayedController.dispose();
    _drivingController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await NativeChannel.getPreferences();
    if (mounted) {
      setState(() {
        _delayedEnabled = prefs[AppKeys.keyDelayedReplyEnabled] as bool? ?? false;
        _delayMinutes = prefs[AppKeys.keyDelayedReplyMinutes] as int? ?? 5;
        final delayedTpl = prefs[AppKeys.keyDelayedReplyTemplate] as String?;
        if (delayedTpl != null && delayedTpl.isNotEmpty) _delayedController.text = delayedTpl;

        _drivingEnabled = prefs[AppKeys.keyDrivingModeEnabled] as bool? ?? false;
        _drivingAutoReply = prefs[AppKeys.keyDrivingAutoReplyEnabled] as bool? ?? false;
        final drivingTpl = prefs[AppKeys.keyDrivingTemplate] as String?;
        if (drivingTpl != null && drivingTpl.isNotEmpty) _drivingController.text = drivingTpl;

        _calendarEnabled = prefs[AppKeys.keyCalendarModeEnabled] as bool? ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Automation & Context')),
      body: SafeArea(
        child: AdaptiveContentContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Delayed Auto-Reply'),
              DelayedReplyCard(
                enabled: _delayedEnabled,
                delayMinutes: _delayMinutes,
                controller: _delayedController,
                onEnabledChanged: (val) {
                  setState(() => _delayedEnabled = val);
                  NativeChannel.updatePreference(AppKeys.keyDelayedReplyEnabled, val);
                },
                onMinutesChanged: (val) {
                  setState(() => _delayMinutes = val);
                  NativeChannel.updatePreference(AppKeys.keyDelayedReplyMinutes, val);
                },
                onTemplateChanged: (val) {
                  NativeChannel.updatePreference(AppKeys.keyDelayedReplyTemplate, val);
                },
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Autonomous Driving Mode'),
              DrivingModeCard(
                isDrivingEnabled: _drivingEnabled,
                isAutoReplyEnabled: _drivingAutoReply,
                templateController: _drivingController,
                onDrivingChanged: (val) {
                  setState(() => _drivingEnabled = val);
                  NativeChannel.updatePreference(AppKeys.keyDrivingModeEnabled, val);
                },
                onAutoReplyChanged: (val) {
                  setState(() => _drivingAutoReply = val);
                  NativeChannel.updatePreference(AppKeys.keyDrivingAutoReplyEnabled, val);
                },
                onTemplateChanged: (val) {
                  NativeChannel.updatePreference(AppKeys.keyDrivingTemplate, val);
                },
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Calendar & Meeting Integration'),
              ToggleSwitchTile(
                title: 'Detect Busy Calendar Events',
                description: 'Injects [📅 In a meeting until X:XX] quick-reply pill during scheduled meetings',
                value: _calendarEnabled,
                icon: Icons.event_busy_rounded,
                onChanged: (val) {
                  setState(() => _calendarEnabled = val);
                  NativeChannel.updatePreference(AppKeys.keyCalendarModeEnabled, val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
