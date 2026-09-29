import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Utilities for detecting folding, flip, and large-screen form factors.
class DisplayHelpers {
  DisplayHelpers._();

  /// Returns true if the device window is Compact (< 600dp, e.g. phone or folded cover).
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  /// Returns true if the device window is Medium/Expanded (>= 600dp, e.g. unfolded foldable or tablet).
  static bool isFoldableExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  /// Detects whether the device is currently in tabletop / flex mode (half-opened posture).
  static bool isTabletopPosture(BuildContext context) {
    final features = MediaQuery.displayFeaturesOf(context);
    for (final feature in features) {
      if (feature.state == DisplayFeatureState.postureHalfOpened) {
        if (feature.bounds.width >= MediaQuery.sizeOf(context).width * 0.7) {
          return true;
        }
      }
    }
    return false;
  }
}
