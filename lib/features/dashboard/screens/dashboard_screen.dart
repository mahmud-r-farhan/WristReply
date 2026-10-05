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

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  bool _isLive = false;
  int _dispatchedCount = 0;
  int _avgLatencyMs = 18;
  int _cacheHits = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMetrics();
    }
  }

  Future<void> _loadMetrics() async {
    final live = await NativeChannel.isListenerRunning();
    if (!mounted) return;
    final metrics = await NativeChannel.getEngineMetrics();
    if (!mounted) return;
    setState(() {
      _isLive = live;
      _dispatchedCount = metrics.repliesDispatched;
      _avgLatencyMs = metrics.avgLatencyMs;
      _cacheHits = metrics.cacheHits;
      _isLoading = false;
    });
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
                    isLoading: _isLoading,
                    dispatchedCount: _dispatchedCount,
                    avgLatencyMs: _avgLatencyMs,
                    cacheHits: _cacheHits,
                    onRefresh: _loadMetrics,
                  )
                : DashboardCompactView(
                    isLive: _isLive,
                    isLoading: _isLoading,
                    dispatchedCount: _dispatchedCount,
                    avgLatencyMs: _avgLatencyMs,
                    cacheHits: _cacheHits,
                    onRefresh: _loadMetrics,
                  ),
      ),
    );
  }
}