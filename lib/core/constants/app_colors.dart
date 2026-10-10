import 'package:flutter/material.dart';

/// Raw brand hues — fixed across light and dark modes.
abstract final class AppBrandColors {
  static const blue = Color(0xFF4579F2);
  static const teal = Color(0xFF20A98A);
  static const periwinkle = Color(0xFF5B5FEF);
  static const snow = Color(0xFFF7F9FD);
}

/// Semantic color roles for a single theme mode.
///
/// These palettes exist to build `ThemeData` in `core/theme/theme.dart`.
/// Widgets should read colors through `Theme.of(context).colorScheme`
/// instead of referencing this class directly.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  static const light = AppPalette(
    brightness: Brightness.light,
    // Bright blue — buttons, active nav, search icon.
    primary: AppBrandColors.blue,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE6F0FE),
    // Deep navy — headings and titles.
    onPrimaryContainer: Color(0xFF0A1A5C),
    // Teal green — logo leaf, "available" chips, doctor/prescription icons.
    secondary: AppBrandColors.teal,
    onSecondary: Color(0xFF06241D),
    secondaryContainer: Color(0xFFE4F8F2),
    onSecondaryContainer: Color(0xFF0B7A66),
    // Periwinkle — gynecology, health tips, "available tomorrow".
    tertiary: AppBrandColors.periwinkle,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFEDEFFE),
    onTertiaryContainer: Color(0xFF2E36B0),
    background: AppBrandColors.snow,
    onBackground: Color(0xFF121B3A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF121B3A),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFBFE),
    surfaceContainer: Color(0xFFF2F5FB),
    surfaceContainerHigh: Color(0xFFECF0F8),
    surfaceContainerHighest: Color(0xFFE4EAF5),
    // Muted blue-gray — subtitles, specialties, secondary labels.
    onSurfaceVariant: Color(0xFF52729B),
    outline: Color(0xFF9AA8C2),
    outlineVariant: Color(0xFFE2E8F3),
    // Soft rose — also used for the Pediatrics tile.
    error: Color(0xFFD12A41),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDECEF),
    onErrorContainer: Color(0xFF8A1025),
    inverseSurface: Color(0xFF1C2340),
    onInverseSurface: Color(0xFFEEF2FB),
    inversePrimary: Color(0xFFA9C4FF),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF7DA5FF),
    onPrimary: Color(0xFF08142E),
    primaryContainer: Color(0xFF1F3A7A),
    onPrimaryContainer: Color(0xFFD9E5FF),
    secondary: Color(0xFF5FD3B3),
    onSecondary: Color(0xFF04231B),
    secondaryContainer: Color(0xFF124538),
    onSecondaryContainer: Color(0xFFBFF0E2),
    tertiary: Color(0xFF9DA0FF),
    onTertiary: Color(0xFF12165A),
    tertiaryContainer: Color(0xFF2E3489),
    onTertiaryContainer: Color(0xFFE0E2FF),
    background: Color(0xFF0E1322),
    onBackground: Color(0xFFE6EBF7),
    surface: Color(0xFF151B2D),
    onSurface: Color(0xFFE6EBF7),
    surfaceContainerLowest: Color(0xFF0B0F1C),
    surfaceContainerLow: Color(0xFF111729),
    surfaceContainer: Color(0xFF151B2D),
    surfaceContainerHigh: Color(0xFF1D2438),
    surfaceContainerHighest: Color(0xFF262E46),
    onSurfaceVariant: Color(0xFFA5B3CF),
    outline: Color(0xFF66748F),
    outlineVariant: Color(0xFF2D3650),
    error: Color(0xFFFF8A9A),
    onError: Color(0xFF4A0A14),
    errorContainer: Color(0xFF6E1526),
    onErrorContainer: Color(0xFFFFD9DE),
    inverseSurface: Color(0xFFE6EBF7),
    onInverseSurface: Color(0xFF1C2340),
    inversePrimary: Color(0xFF4579F2),
  );
}
