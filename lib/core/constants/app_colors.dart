import 'package:flutter/material.dart';

/// Raw brand hues — fixed across light and dark modes.
abstract final class AppBrandColors {
  static const indigo = Color(0xFF536DCF);
  static const sage = Color(0xFF84C2AF);
  static const sky = Color(0xFF98B7F0);
  static const cream = Color(0xFFFCF9F5);
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
    primary: AppBrandColors.indigo,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE3E8FB),
    onPrimaryContainer: Color(0xFF182659),
    secondary: AppBrandColors.sage,
    onSecondary: Color(0xFF0E2B22),
    secondaryContainer: Color(0xFFD8F0E7),
    onSecondaryContainer: Color(0xFF173A2E),
    tertiary: AppBrandColors.sky,
    onTertiary: Color(0xFF14213D),
    tertiaryContainer: Color(0xFFE7EEFD),
    onTertiaryContainer: Color(0xFF1C2E58),
    background: AppBrandColors.cream,
    onBackground: Color(0xFF1B1A17),
    surface: Color(0xFFFFFDFB),
    onSurface: Color(0xFF1B1A17),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: AppBrandColors.cream,
    surfaceContainer: Color(0xFFF6F2EB),
    surfaceContainerHigh: Color(0xFFF0EBE3),
    surfaceContainerHighest: Color(0xFFEAE4DA),
    onSurfaceVariant: Color(0xFF5F5B54),
    outline: Color(0xFFA8A196),
    outlineVariant: Color(0xFFD8D2C6),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    inverseSurface: Color(0xFF31302C),
    onInverseSurface: Color(0xFFF6F1E9),
    inversePrimary: Color(0xFFB8C0F4),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF8493E8),
    onPrimary: Color(0xFF111527),
    primaryContainer: Color(0xFF333F86),
    onPrimaryContainer: Color(0xFFD6DCFF),
    secondary: Color(0xFFA5D6C3),
    onSecondary: Color(0xFF0E2B22),
    secondaryContainer: Color(0xFF274C40),
    onSecondaryContainer: Color(0xFFC6EADC),
    tertiary: Color(0xFFB7C8F5),
    onTertiary: Color(0xFF16203F),
    tertiaryContainer: Color(0xFF3A4A78),
    onTertiaryContainer: Color(0xFFD8E2FF),
    background: Color(0xFF1B1A18),
    onBackground: Color(0xFFE8E4DC),
    surface: Color(0xFF242220),
    onSurface: Color(0xFFE8E4DC),
    surfaceContainerLowest: Color(0xFF141312),
    surfaceContainerLow: Color(0xFF1F1E1C),
    surfaceContainer: Color(0xFF242220),
    surfaceContainerHigh: Color(0xFF2E2C29),
    surfaceContainerHighest: Color(0xFF353330),
    onSurfaceVariant: Color(0xFFB8B2A6),
    outline: Color(0xFF6F6A61),
    outlineVariant: Color(0xFF4A4640),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    inverseSurface: Color(0xFFE8E4DC),
    onInverseSurface: Color(0xFF32302C),
    inversePrimary: Color(0xFF536DCF),
  );
}
