import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';
import '../widgets/custom_word_editor.dart';

/// Screen for managing the LPTE Profanity Filter and Smart Clipboard Automation.
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  bool _shieldEnabled = true;
  List<String> _blockedWords = [];
  bool _autoCopyOtp = true;
  bool _autoCopyTrx = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final prefs = await NativeChannel.getPreferences();
    if (mounted) {
      setState(() {
        _shieldEnabled = prefs[AppKeys.keyProfanityShield] as bool? ?? true;
        _blockedWords = (prefs[AppKeys.keyCustomBlockedWords] as List?)?.cast<String>() ?? [];
        _autoCopyOtp = prefs[AppKeys.keyAutoCopyOtp] as bool? ?? true;
        _autoCopyTrx = prefs[AppKeys.keyAutoCopyTrx] as bool? ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Filters & Automation')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Inappropriate Language Shield (LPTE)'),
            ToggleSwitchTile(
              title: 'Abusive Content Interceptor',
              description: 'Suppresses cheerful pills and warns on toxic/abusive messages',
              value: _shieldEnabled,
              icon: Icons.shield_rounded,
              onChanged: (val) {
                setState(() => _shieldEnabled = val);
                NativeChannel.updatePreference(AppKeys.keyProfanityShield, val);
              },
            ),
            if (_shieldEnabled) ...[
              const SizedBox(height: 8),
              const Text(
                'Custom Trigger Words (English, Bengali & Banglish):',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              CustomWordEditor(
                words: _blockedWords,
                onChanged: (updated) {
                  setState(() => _blockedWords = updated);
                  NativeChannel.updatePreference(AppKeys.keyCustomBlockedWords, updated);
                },
              ),
            ],
            const SectionHeader(title: 'Smart Clipboard Automation'),
            ToggleSwitchTile(
              title: 'Auto-Copy OTP / Verification Codes',
              description: 'Detects 4-6 digit authentication codes and copies to clipboard',
              value: _autoCopyOtp,
              icon: Icons.pin_outlined,
              onChanged: (val) {
                setState(() => _autoCopyOtp = val);
                NativeChannel.updatePreference(AppKeys.keyAutoCopyOtp, val);
              },
            ),
            ToggleSwitchTile(
              title: 'Auto-Copy Transaction IDs',
              description: 'Detects TrxID from bKash, Nagad, Bank SMS, UPI & PayPal',
              value: _autoCopyTrx,
              icon: Icons.receipt_long_rounded,
              onChanged: (val) {
                setState(() => _autoCopyTrx = val);
                NativeChannel.updatePreference(AppKeys.keyAutoCopyTrx, val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
