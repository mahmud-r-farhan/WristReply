import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/adaptive_content_container.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';
import '../widgets/pills_count_tile.dart';

/// Screen for general engine operation, notification mode, and battery persistency.
class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _masterEnabled = true;
  bool _replaceMode = false;
  bool _privacyMode = false;
  int _pillsPerMessage = 3;
  bool _respectDnd = true;
  bool _sleepWindow = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await NativeChannel.getPreferences();
    if (mounted) {
      setState(() {
        _masterEnabled = prefs[AppKeys.keyMasterEnabled] as bool? ?? true;
        _replaceMode = prefs[AppKeys.keyReplaceMode] as bool? ?? false;
        _privacyMode = prefs[AppKeys.keyPrivacyMode] as bool? ?? false;
        _pillsPerMessage = prefs[AppKeys.keyPillsPerMessage] as int? ?? 3;
        _respectDnd = prefs[AppKeys.keyRespectDnd] as bool? ?? true;
        _sleepWindow = prefs[AppKeys.keySleepWindowEnabled] as bool? ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('System & Delivery')),
      body: SafeArea(
        child: AdaptiveContentContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Master Engine Control'),
              ToggleSwitchTile(
                title: 'Enable WristReply Daemon',
                description: 'Active background interception of messaging notifications',
                value: _masterEnabled,
                icon: Icons.power_settings_new_rounded,
                onChanged: (val) {
                  setState(() => _masterEnabled = val);
                  NativeChannel.updatePreference(AppKeys.keyMasterEnabled, val);
                },
              ),
              const SectionHeader(title: 'Notification Delivery Mode'),
              ToggleSwitchTile(
                title: 'Replace Mode (Opt-in)',
                description: 'Cancels original notification and reposts with merged pills',
                value: _replaceMode,
                icon: Icons.sync_alt_rounded,
                onChanged: (val) {
                  setState(() => _replaceMode = val);
                  NativeChannel.updatePreference(AppKeys.keyReplaceMode, val);
                },
              ),
              ToggleSwitchTile(
                title: 'Privacy Mode (Mask Text)',
                description: 'Hides conversational preview and displays ••••••••••',
                value: _privacyMode,
                icon: Icons.visibility_off_outlined,
                onChanged: (val) {
                  setState(() => _privacyMode = val);
                  NativeChannel.updatePreference(AppKeys.keyPrivacyMode, val);
                },
              ),
              PillsCountTile(
                count: _pillsPerMessage,
                onChanged: (val) {
                  setState(() => _pillsPerMessage = val);
                  NativeChannel.updatePreference(AppKeys.keyPillsPerMessage, val);
                },
              ),
              const SectionHeader(title: 'Zero-Wake Sleep Guard'),
              ToggleSwitchTile(
                title: 'Respect System DND',
                description: 'Suppress Smart Reply generation when Do Not Disturb is active',
                value: _respectDnd,
                icon: Icons.do_not_disturb_on_outlined,
                onChanged: (val) {
                  setState(() => _respectDnd = val);
                  NativeChannel.updatePreference(AppKeys.keyRespectDnd, val);
                },
              ),
              ToggleSwitchTile(
                title: 'Scheduled Quiet Hours',
                description: 'Zero-CPU sleep mode between 23:00 and 06:30',
                value: _sleepWindow,
                icon: Icons.bedtime_outlined,
                onChanged: (val) {
                  setState(() => _sleepWindow = val);
                  NativeChannel.updatePreference(AppKeys.keySleepWindowEnabled, val);
                },
              ),
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
          ),
        ),
      ),
    );
  }
}
