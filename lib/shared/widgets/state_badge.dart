import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Glowing animated badge that pulses in sync with the active background engine.
class StateBadge extends StatefulWidget {
  final bool isLive;
  final String label;

  const StateBadge({
    super.key,
    required this.isLive,
    this.label = 'LIVE',
  });

  @override
  State<StateBadge> createState() => _StateBadgeState();
}

class _StateBadgeState extends State<StateBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.35, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isLive ? AppColors.accentMint : AppColors.accentWarning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacityAnim,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: TextStyle(
              color: activeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
