import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/metrics_card.dart';
import '../../../shared/widgets/state_badge.dart';
import '../../apps/screens/app_whitelist_screen.dart';
import '../../automation/screens/automation_screen.dart';
import '../../filters/screens/filters_screen.dart';
import '../../persona/screens/persona_screen.dart';
import '../../settings/screens/general_settings_screen.dart';
import '../widgets/hardware_status_card.dart';
import '../widgets/live_sandbox_widget.dart';

/// Screen 2: Real-time Cockpit / Console displaying daemon health and sandbox testing.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLive = true;
  int _dispatchedCount = 0;
  int _avgLatencyMs = 18;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final live = await NativeChannel.isListenerRunning();
    final metrics = await NativeChannel.getEngineMetrics();
    if (mounted) {
      setState(() {
        _isLive = live;
        _dispatchedCount = (metrics['repliesDispatched'] as num?)?.toInt() ?? 0;
        _avgLatencyMs = (metrics['avgLatencyMs'] as num?)?.toInt() ?? 18;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text(AppStrings.liveConsole),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: StateBadge(isLive: _isLive)),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMetrics,
          color: AppColors.accentMint,
          backgroundColor: AppColors.surfaceRaised,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              HardwareStatusCard(isLive: _isLive),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricsCard(
                      title: 'Dispatched',
                      value: '$_dispatchedCount',
                      subtitle: 'Zero-cloud sends',
                      icon: Icons.send_rounded,
                      accentColor: AppColors.accentMint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricsCard(
                      title: 'Avg Latency',
                      value: '${_avgLatencyMs}ms',
                      subtitle: 'On-device inference',
                      icon: Icons.bolt_rounded,
                      accentColor: AppColors.accentPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const LiveSandboxWidget(),
              const SizedBox(height: 24),
              _navTile(context, Icons.apps_rounded, 'Discovered Messaging Apps', 'Manage whitelist per app', const AppWhitelistScreen()),
              _navTile(context, Icons.psychology_rounded, 'Persona & Reply Tailoring', 'Tone, fallback pills, chrono bias', const PersonaScreen()),
              _navTile(context, Icons.security_rounded, 'LPTE Shield & Clipboard', 'Profanity filter & OTP / TrxID copy', const FiltersScreen()),
              _navTile(context, Icons.auto_mode_rounded, 'Automation & Delayed Replies', 'Auto-response rules & timers', const AutomationScreen()),
              _navTile(context, Icons.tune_rounded, 'General & System Settings', 'Delivery mode, sleep window, autostart', const GeneralSettingsScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String title, String subtitle, Widget targetScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentPrimary),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
      ),
    );
  }
}
