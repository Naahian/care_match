import 'package:flutter/material.dart';

/// Raw brand hues — fixed across light and dark modes.
abstract final class AppBrandColors {
  static const blue = Color(0xFF5B61ED);
  static const teal = Color(0xFF20A98A);
  static const periwinkle = Color(0xFF5B61ED);
  static const snow = Color(0xFFF2F3FB);
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
    primaryContainer: Color(0xFFE8DCFA),
    // Deep navy — headings and titles.
    onPrimaryContainer: Color(0xFF27283F),
    // Teal green — logo leaf, "available" chips, doctor/prescription icons.
    secondary: AppBrandColors.teal,
    onSecondary: Color(0xFF06241D),
    secondaryContainer: Color(0xFFE4F8F2),
    onSecondaryContainer: Color(0xFF0B7A66),
    // Periwinkle — gynecology, health tips, "available tomorrow".
    tertiary: AppBrandColors.periwinkle,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE8DCFA),
    onTertiaryContainer: Color(0xFF5B61ED),
    background: AppBrandColors.snow,
    onBackground: Color(0xFF27283F),
    surface: Color(0xFFFEFEFF),
    onSurface: Color(0xFF27283F),
    surfaceContainerLowest: Color(0xFFFEFEFF),
    surfaceContainerLow: Color(0xFFFEFEFF),
    surfaceContainer: Color(0xFFF2F3FB),
    surfaceContainerHigh: Color(0xFFE8DCFA),
    surfaceContainerHighest: Color(0xFFE8DCFA),
    // Muted blue-gray — subtitles, specialties, secondary labels.
    onSurfaceVariant: Color(0xFF6E708B),
    outline: Color(0xFFB6B8CC),
    outlineVariant: Color(0xFFE8E9F3),
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
    primary: Color(0xFF7C83FF),
    onPrimary: Color(0xFF08142E),
    primaryContainer: Color(0xFF252538),
    onPrimaryContainer: Color(0xFFD9E5FF),
    secondary: Color(0xFF5C7CD6),
    onSecondary: Color(0xFF04231B),
    secondaryContainer: Color(0xFF124538),
    onSecondaryContainer: Color(0xFFBFF0E2),
    tertiary: Color(0xFF9DA0FF),
    onTertiary: Color(0xFF12165A),
    tertiaryContainer: Color(0xFF2E3489),
    onTertiaryContainer: Color(0xFFE0E2FF),
    background: Color(0xFF12121A),
    onBackground: Color(0xFFE6EBF7),
    surface: Color(0xFF252538),
    onSurface: Color(0xFFE6EBF7),
    surfaceContainerLowest: Color(0xFF09090D),
    surfaceContainerLow: Color(0xFF12121A),
    surfaceContainer: Color(0xFF252538),
    surfaceContainerHigh: Color(0xFF303047),
    surfaceContainerHighest: Color(0xFF393950),
    onSurfaceVariant: Color(0xFFA5B3CF),
    outline: Color(0xFF66748F),
    outlineVariant: Color(0xFF2D3650),
    error: Color(0xFFFF8A9A),
    onError: Color(0xFF4A0A14),
    errorContainer: Color(0xFF6E1526),
    onErrorContainer: Color(0xFFFFD9DE),
    inverseSurface: Color(0xFFE6EBF7),
    onInverseSurface: Color(0xFF1C2340),
    inversePrimary: Color(0xFF5B61ED),
  );
}
