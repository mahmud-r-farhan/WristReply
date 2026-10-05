import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/adaptive_content_container.dart';
import '../widgets/delivery_mode_section.dart';
import '../widgets/master_control_section.dart';
import '../widgets/oem_management_section.dart';
import '../widgets/settings_branding_footer.dart';
import '../widgets/sleep_guard_section.dart';

/// Screen for general engine operation, notification mode, and battery persistency.
class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> with WidgetsBindingObserver {
  bool _masterEnabled = true;
  bool _notificationsEnabled = true;
  bool _hasNotificationPermission = false;
  bool _replaceMode = false;
  bool _privacyMode = false;
  int _pillsPerMessage = 3;
  bool _respectDnd = true;
  bool _sleepWindow = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final hasPermission = await NativeChannel.isNotificationPermissionGranted();
    if (!mounted) return;
    final prefs = await NativeChannel.getPreferences();
    if (!mounted) return;

    setState(() {
      _masterEnabled = prefs[AppKeys.keyMasterEnabled] as bool? ?? true;
      _replaceMode = prefs[AppKeys.keyReplaceMode] as bool? ?? false;
      _privacyMode = prefs[AppKeys.keyPrivacyMode] as bool? ?? false;
      _pillsPerMessage = prefs[AppKeys.keyPillsPerMessage] as int? ?? 3;
      _respectDnd = prefs[AppKeys.keyRespectDnd] as bool? ?? true;
      _sleepWindow = prefs[AppKeys.keySleepWindowEnabled] as bool? ?? false;

      _hasNotificationPermission = hasPermission;
      final savedNotifSetting = prefs[AppKeys.keyNotificationsEnabled] as bool? ?? true;

      if (!hasPermission) {
        _notificationsEnabled = false;
        // Fire-and-forget; safe because the host Activity stays in scope.
        NativeChannel.updatePreference(AppKeys.keyNotificationsEnabled, false);
      } else {
        _notificationsEnabled = savedNotifSetting;
      }
      _isLoading = false;
    });
  }

  Future<void> _onNotificationToggleChanged(bool val) async {
    if (val) {
      if (!_hasNotificationPermission) {
        await NativeChannel.requestNotificationPermission();
        if (!mounted) return;
        final granted = await NativeChannel.isNotificationPermissionGranted();
        if (!mounted) return;
        setState(() {
          _hasNotificationPermission = granted;
          _notificationsEnabled = granted;
        });
        await NativeChannel.updatePreference(AppKeys.keyNotificationsEnabled, granted);
      } else {
        setState(() => _notificationsEnabled = true);
        await NativeChannel.updatePreference(AppKeys.keyNotificationsEnabled, true);
      }
    } else {
      setState(() => _notificationsEnabled = false);
      await NativeChannel.updatePreference(AppKeys.keyNotificationsEnabled, false);
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
              MasterControlSection(
                masterEnabled: _masterEnabled,
                onMasterChanged: (val) {
                  setState(() => _masterEnabled = val);
                  NativeChannel.updatePreference(AppKeys.keyMasterEnabled, val);
                },
                notificationsEnabled: _notificationsEnabled,
                hasNotificationPermission: _hasNotificationPermission,
                onNotificationsChanged: _onNotificationToggleChanged,
              ),
              DeliveryModeSection(
                replaceMode: _replaceMode,
                onReplaceModeChanged: (val) {
                  setState(() => _replaceMode = val);
                  NativeChannel.updatePreference(AppKeys.keyReplaceMode, val);
                },
                privacyMode: _privacyMode,
                onPrivacyModeChanged: (val) {
                  setState(() => _privacyMode = val);
                  NativeChannel.updatePreference(AppKeys.keyPrivacyMode, val);
                },
                pillsPerMessage: _pillsPerMessage,
                onPillsCountChanged: (val) {
                  setState(() => _pillsPerMessage = val);
                  NativeChannel.updatePreference(AppKeys.keyPillsPerMessage, val);
                },
              ),
              SleepGuardSection(
                respectDnd: _respectDnd,
                onRespectDndChanged: (val) {
                  setState(() => _respectDnd = val);
                  NativeChannel.updatePreference(AppKeys.keyRespectDnd, val);
                },
                sleepWindow: _sleepWindow,
                onSleepWindowChanged: (val) {
                  setState(() => _sleepWindow = val);
                  NativeChannel.updatePreference(AppKeys.keySleepWindowEnabled, val);
                },
              ),
              const OemManagementSection(),
              const SettingsBrandingFooter(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentMint),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}