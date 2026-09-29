import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';

/// Screen for managing optional delayed auto-replies and message automation.
class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  bool _delayedReplyEnabled = false;
  int _delayMinutes = 5;
  final TextEditingController _templateController =
      TextEditingController(text: 'Busy right now, will reply shortly.');

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await NativeChannel.getPreferences();
    if (mounted) {
      setState(() {
        _delayedReplyEnabled = prefs[AppKeys.keyDelayedReplyEnabled] as bool? ?? false;
        _delayMinutes = prefs[AppKeys.keyDelayedReplyMinutes] as int? ?? 5;
        final template = prefs[AppKeys.keyDelayedReplyTemplate] as String?;
        if (template != null && template.isNotEmpty) {
          _templateController.text = template;
        }
      });
    }
  }

  void _saveTemplate(String text) {
    NativeChannel.updatePreference(AppKeys.keyDelayedReplyTemplate, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Automation Rules')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Delayed Auto-Reply'),
            ToggleSwitchTile(
              title: 'Enable Delayed Auto-Reply',
              description: 'Fires an automated reply if you do not interact with the notification',
              value: _delayedReplyEnabled,
              icon: Icons.timer_outlined,
              onChanged: (val) {
                setState(() => _delayedReplyEnabled = val);
                NativeChannel.updatePreference(AppKeys.keyDelayedReplyEnabled, val);
              },
            ),
            if (_delayedReplyEnabled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delay Duration', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text('$_delayMinutes min', style: const TextStyle(color: AppColors.accentMint, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _delayMinutes.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: AppColors.accentMint,
                      onChanged: (val) {
                        setState(() => _delayMinutes = val.toInt());
                        NativeChannel.updatePreference(AppKeys.keyDelayedReplyMinutes, val.toInt());
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('Response Template', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _templateController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: _saveTemplate,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceCanvas,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInteractive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accentPrimary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dismissing the notification on your phone or smartwatch immediately cancels the pending auto-reply.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
