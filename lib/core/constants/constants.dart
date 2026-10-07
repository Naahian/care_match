import 'package:flutter/material.dart';

/// App-wide, non-visual constants.
///
/// Visual tokens live in `app_colors.dart`, `app_typography.dart`,
/// `app_spacing.dart`, and `app_radius.dart`.
abstract final class AppConstants {
  static const String appName = 'Care Match';

  static const int defaultPageSize = 20;
  static const int otpLength = 6;

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration requestTimeout = Duration(seconds: 30);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(full));
  static const BorderRadius sheet = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: md);
}
