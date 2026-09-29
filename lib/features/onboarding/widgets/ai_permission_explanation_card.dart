import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Animated AI response card explaining why each permission is required in small, crisp text.
class AiPermissionExplanationCard extends StatefulWidget {
  const AiPermissionExplanationCard({super.key});

  @override
  State<AiPermissionExplanationCard> createState() => _AiPermissionExplanationCardState();
}

class _AiPermissionExplanationCardState extends State<AiPermissionExplanationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _typingTimer;

  static const String _fullExplanationText =
      '• Notification Bridge: Needed to capture incoming chat text and inject smart reply pills directly into messaging apps on-device.\n'
      '• Background Keep-Alive: Prevents OEM battery optimizations from killing background engine services.\n'
      '• System Notifications (Optional): Allows WristReply to show real-time status alerts, countdowns, and watch sync state.';

  int _characterIndex = 0;
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTypewriterEffect();
  }

  void _startTypewriterEffect() {
    _typingTimer?.cancel();
    _characterIndex = 0;
    _isTypingComplete = false;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_characterIndex < _fullExplanationText.length) {
        setState(() {
          _characterIndex++;
        });
      } else {
        setState(() {
          _isTypingComplete = true;
        });
        timer.cancel();
      }
    });
  }

  void _completeTypingImmediately() {
    if (!_isTypingComplete) {
      _typingTimer?.cancel();
      setState(() {
        _characterIndex = _fullExplanationText.length;
        _isTypingComplete = true;
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedText = _fullExplanationText.substring(0, _characterIndex);

    return GestureDetector(
      onTap: _completeTypingImmediately,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentMint.withValues(alpha: 0.25 * _pulseAnimation.value),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentMint.withValues(alpha: 0.05 * _pulseAnimation.value),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FadeTransition(
                      opacity: _pulseAnimation,
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.accentMint,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI PERMISSION ANALYZER',
                      style: TextStyle(
                        color: AppColors.accentMint,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInteractive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _isTypingComplete ? AppColors.accentMint : AppColors.accentPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isTypingComplete ? 'READY' : 'GENERATING...',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: displayedText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.45,
                      fontFamily: 'monospace',
                    ),
                    children: [
                      if (!_isTypingComplete)
                        TextSpan(
                          text: ' ▌',
                          style: TextStyle(
                            color: AppColors.accentMint.withValues(alpha: _pulseAnimation.value),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
