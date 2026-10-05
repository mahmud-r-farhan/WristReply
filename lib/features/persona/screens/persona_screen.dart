import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/adaptive_content_container.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/toggle_switch_tile.dart';
import '../widgets/fallback_pill_editor.dart';

/// Screen 3: Global tone rules, multi-lingual settings, and fallback persona customization.
class PersonaScreen extends StatefulWidget {
  const PersonaScreen({super.key});

  @override
  State<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  String _selectedTone = 'casual';
  List<String> _fallbackPills = ['Sounds good!', 'On my way!', 'Can\'t talk right now, call later.'];
  bool _chronoBias = true;
  bool _locationPin = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await NativeChannel.getPreferences();
    if (!mounted) return;
    setState(() {
      _selectedTone = prefs[AppKeys.keyConversationTone] as String? ?? 'casual';
      _fallbackPills = (prefs[AppKeys.keyCustomFallbackPills] as List?)?.cast<String>() ?? _fallbackPills;
      _chronoBias = prefs[AppKeys.keyChronoBiasEnabled] as bool? ?? true;
      _locationPin = prefs[AppKeys.keyLocationPinEnabled] as bool? ?? false;
    });
  }

  Future<void> _updateTone(String tone) async {
    setState(() => _selectedTone = tone);
    await NativeChannel.updatePreference(AppKeys.keyConversationTone, tone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(title: const Text('Reply Personality')),
      body: SafeArea(
        child: AdaptiveContentContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Global Conversation Tone'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tonePill('Casual (Global)', 'casual', 'Sounds good!', Icons.bolt_rounded),
                  _tonePill('Professional', 'professional', 'Understood', Icons.work_outline_rounded),
                  _tonePill('Spanish', 'spanish', '¡Dale, voy!', Icons.language_rounded),
                  _tonePill('German', 'german', 'Alles klar!', Icons.public_rounded),
                  _tonePill('Portuguese', 'portuguese', 'Beleza!', Icons.chat_rounded),
                  _tonePill('Multi-Lingual Auto', 'multilingual', 'Auto-Detect', Icons.translate_rounded),
                ],
              ),
              const SectionHeader(title: 'Persistent Fallback Pills'),
              const Text(
                'Used when on-device AI cannot detect context or for offline regional messages:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              FallbackPillEditor(
                pills: _fallbackPills,
                onChanged: (updated) {
                  setState(() => _fallbackPills = updated);
                  NativeChannel.updatePreference(AppKeys.keyCustomFallbackPills, updated);
                },
              ),
              const SectionHeader(title: 'Dynamic Smart Injections'),
              ToggleSwitchTile(
                title: 'Chrono-Aware Bias',
                description: 'Late-night (23:00–06:00) & work hours priority ranking across languages',
                value: _chronoBias,
                icon: Icons.access_time_rounded,
                onChanged: (val) {
                  setState(() => _chronoBias = val);
                  NativeChannel.updatePreference(AppKeys.keyChronoBiasEnabled, val);
                },
              ),
              ToggleSwitchTile(
                title: 'Auto-Append Location Pin',
                description: 'Append [📍 Location] pill when queried "Where are you?" / "¿Dónde estás?"',
                value: _locationPin,
                icon: Icons.location_on_outlined,
                onChanged: (val) {
                  setState(() => _locationPin = val);
                  NativeChannel.updatePreference(AppKeys.keyLocationPinEnabled, val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tonePill(String label, String id, String sample, IconData icon) {
    final isSelected = _selectedTone == id;
    final border = isSelected ? AppColors.accentMint : AppColors.borderSubtle;
    final bg = isSelected ? AppColors.accentMint.withValues(alpha: 0.12) : AppColors.surfaceRaised;

    return GestureDetector(
      onTap: () => _updateTone(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.accentMint : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
