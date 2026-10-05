import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Interactive reply pill component with kinetic scale spring and haptic feedback.
///
/// Implements the kinetic spec from engineering.md §5.2:
///   - 48dp × 48dp minimum touch bounding box on mobile.
///   - 90ms scale-down (1.00 → 0.96) on press, springs back on release.
///   - Light haptic click on touch-down.
class ReplyPillPreview extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;

  const ReplyPillPreview({
    super.key,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<ReplyPillPreview> createState() => _ReplyPillPreviewState();
}

class _ReplyPillPreviewState extends State<ReplyPillPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected ? AppColors.accentMint : AppColors.borderSubtle;
    final bgColor = widget.isSelected ? AppColors.accentMint.withValues(alpha: 0.12) : AppColors.surfaceInteractive;

    return Semantics(
      label: 'Reply pill: ${widget.text}',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}