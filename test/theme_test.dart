import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/core/constants/app_colors.dart';
import 'package:wrist_reply/core/theme/app_theme.dart';

void main() {
  test('darkTheme uses the OLED Dark Utility color tokens', () {
    final theme = AppTheme.darkTheme;
    expect(theme.scaffoldBackgroundColor, AppColors.surfaceCanvas);
    expect(theme.primaryColor, AppColors.accentMint);
    expect(theme.brightness, Brightness.dark);
  });

  test('darkTheme text theme uses the brand colors', () {
    final theme = AppTheme.darkTheme;
    expect(theme.textTheme.headlineMedium?.color, AppColors.textPrimary);
    expect(theme.textTheme.bodyMedium?.color, AppColors.textSecondary);
    expect(theme.textTheme.labelSmall?.color, AppColors.textTertiary);
  });

  test('switch theme uses accent mint when selected', () {
    final theme = AppTheme.darkTheme;
    final switchTheme = theme.switchTheme;
    expect(switchTheme, isNotNull);
  });

  test('slider theme uses accent mint for active track', () {
    final theme = AppTheme.darkTheme;
    expect(theme.sliderTheme.activeTrackColor, AppColors.accentMint);
  });
}
