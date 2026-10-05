import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/platform/native_channel.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../widgets/ai_permission_modal.dart';
import '../widgets/permission_card.dart';

/// Screen 1B: Zero-Friction Permissions Handshake with real-time lifecycle refresh.
///
/// Optimized for foldables, flips, tablets, and compact cover displays.
/// Re-evaluates permission state whenever the user resumes from system settings.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _isListenerGranted = false;
  bool _isBatteryIgnored = false;
  bool _isNotificationGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final listener = await NativeChannel.isListenerRunning();
    final battery = await NativeChannel.isBatteryOptimizationIgnored();
    final notification = await NativeChannel.isNotificationPermissionGranted();
    if (!mounted) return;
    setState(() {
      _isListenerGranted = listener;
      _isBatteryIgnored = battery;
      _isNotificationGranted = notification;
      _isLoading = false;
    });
  }

  Future<void> _launchConsole() async {
    if (!_isListenerGranted) {
      // Defensive: don't allow forward navigation if permission was revoked
      // while the user was on this screen.
      await _checkPermissions();
      if (!mounted || !_isListenerGranted) return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentMint),
            tooltip: 'AI Permission Insights',
            onPressed: () => AiPermissionModal.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CORE ACCESS REQUIRED',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PermissionCard(
                    title: AppStrings.notificationBridgeTitle,
                    description: AppStrings.notificationBridgeDesc,
                    isGranted: _isListenerGranted,
                    isLoading: _isLoading,
                    actionLabel: AppStrings.grantAccess,
                    onAction: () async => await NativeChannel.requestListenerPermission(),
                  ),
                  const SizedBox(height: 16),
                  PermissionCard(
                    title: AppStrings.backgroundKeepAliveTitle,
                    description: AppStrings.backgroundKeepAliveDesc,
                    isGranted: _isBatteryIgnored,
                    isLoading: _isLoading,
                    actionLabel: AppStrings.whitelistMe,
                    onAction: () async => await NativeChannel.requestBatteryExemption(),
                  ),
                  const SizedBox(height: 16),
                  PermissionCard(
                    title: AppStrings.notificationPostingTitle,
                    description: AppStrings.notificationPostingDesc,
                    isGranted: _isNotificationGranted,
                    isLoading: _isLoading,
                    isOptional: true,
                    actionLabel: AppStrings.grantOptional,
                    onAction: () async => await NativeChannel.requestNotificationPermission(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isListenerGranted && !_isLoading ? _launchConsole : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentMint,
                        disabledBackgroundColor: AppColors.surfaceInteractive,
                        foregroundColor: Colors.black,
                        disabledForegroundColor: AppColors.textTertiary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        AppStrings.launchConsole,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}