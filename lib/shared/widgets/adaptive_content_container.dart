import 'package:flutter/widgets.dart';

/// Wraps content in a centered, max-width constrained container for foldables and tablets.
class AdaptiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AdaptiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
