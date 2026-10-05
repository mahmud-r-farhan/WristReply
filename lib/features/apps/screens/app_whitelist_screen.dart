import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/adaptive_content_container.dart';

/// Screen for managing granular per-application whitelist toggles.
class AppWhitelistScreen extends StatefulWidget {
  const AppWhitelistScreen({super.key});

  @override
  State<AppWhitelistScreen> createState() => _AppWhitelistScreenState();
}

class _AppWhitelistScreenState extends State<AppWhitelistScreen> {
  List<DiscoveredApp> _apps = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscoveredApps();
  }

  Future<void> _loadDiscoveredApps() async {
    final apps = await NativeChannel.getDiscoveredApps();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _isLoading = false;
    });
  }

  Future<void> _toggleApp(int index, bool value) async {
    final app = _apps[index];
    setState(() {
      _apps = List<DiscoveredApp>.from(_apps)..[index] =
          DiscoveredApp(packageName: app.packageName, appName: app.appName, isEnabled: value);
    });
    await NativeChannel.setAppWhitelisted(app.packageName, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Monitored Apps')),
      body: SafeArea(
        child: AdaptiveContentContainer(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentMint))
              : _apps.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _apps.length,
                      itemBuilder: (context, index) {
                        final app = _apps[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceInteractive,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentMint, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.appName,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      app.packageName,
                                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: app.isEnabled,
                                onChanged: (val) => _toggleApp(index, val),
                                activeThumbColor: AppColors.accentMint,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_chat_read_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'No messaging clients detected',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
