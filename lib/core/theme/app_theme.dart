import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App-wide theme definition implementing the OLED Dark Utility aesthetic.
///
/// All color, typography, and component themes are centralized here so any
/// future "light" mode can be added by simply mirroring this surface.
class AppTheme {
  AppTheme._();

  static const TextTheme _textTheme = const TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1),
    headlineLarge: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    headlineMedium: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    titleMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
    bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
    labelLarge: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      canvasColor: AppColors.surfaceCanvas,
      primaryColor: AppColors.accentMint,
      cardColor: AppColors.surfaceRaised,
      dividerColor: AppColors.borderSubtle,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceCanvas,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentMint;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentMint.withValues(alpha: 0.3);
          }
          return AppColors.surfaceInteractive;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accentMint,
        inactiveTrackColor: AppColors.surfaceInteractive,
        thumbColor: AppColors.accentMint,
        overlayColor: Color(0x3338EF7D),
        trackHeight: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInteractive,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentMint),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accentMint),
      dividerTheme: const DividerThemeData(color: AppColors.borderSubtle, thickness: 1, space: 1),
    );
  }
}