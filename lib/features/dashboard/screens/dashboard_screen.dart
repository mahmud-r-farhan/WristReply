import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/platform/native_channel.dart';
import '../../../core/utils/display_helpers.dart';
import '../../../shared/widgets/state_badge.dart';
import '../widgets/dashboard_compact_view.dart';
import '../widgets/dashboard_expanded_view.dart';

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
    final isExpanded = DisplayHelpers.isFoldableExpanded(context);

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
        child: isExpanded
            ? DashboardExpandedView(
                isLive: _isLive,
                dispatchedCount: _dispatchedCount,
                avgLatencyMs: _avgLatencyMs,
                onRefresh: _loadMetrics,
              )
            : DashboardCompactView(
                isLive: _isLive,
                dispatchedCount: _dispatchedCount,
                avgLatencyMs: _avgLatencyMs,
                onRefresh: _loadMetrics,
              ),
      ),
    );
  }
}
