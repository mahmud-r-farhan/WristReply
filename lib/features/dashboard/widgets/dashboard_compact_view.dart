import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/metrics_card.dart';
import '../../apps/screens/app_whitelist_screen.dart';
import '../../automation/screens/automation_screen.dart';
import '../../filters/screens/filters_screen.dart';
import '../../persona/screens/persona_screen.dart';
import '../../settings/screens/general_settings_screen.dart';
import 'hardware_status_card.dart';
import 'live_sandbox_widget.dart';

/// Single-pane layout for compact phones and folded cover screens (< 600dp).
class DashboardCompactView extends StatelessWidget {
  final bool isLive;
  final int dispatchedCount;
  final int avgLatencyMs;
  final Future<void> Function() onRefresh;

  const DashboardCompactView({
    super.key,
    required this.isLive,
    required this.dispatchedCount,
    required this.avgLatencyMs,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accentMint,
      backgroundColor: AppColors.surfaceRaised,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          HardwareStatusCard(isLive: isLive),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricsCard(
                  title: 'Dispatched',
                  value: '$dispatchedCount',
                  subtitle: 'Zero-cloud sends',
                  icon: Icons.send_rounded,
                  accentColor: AppColors.accentMint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricsCard(
                  title: 'Avg Latency',
                  value: '${avgLatencyMs}ms',
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
