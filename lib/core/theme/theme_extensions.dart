import 'package:flutter/material.dart';

/// Status colors that `ColorScheme` does not cover.
///
/// Read via `Theme.of(context).extension<AppExtras>()`.
class AppExtras extends ThemeExtension<AppExtras> {
  const AppExtras({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  @override
  AppExtras copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppExtras(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  AppExtras lerp(AppExtras? other, double t) {
    if (other is! AppExtras) return this;
    return AppExtras(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }

  static const light = AppExtras(
    success: Color(0xFF17804E),
    successContainer: Color(0xFFD3F0E1),
    onSuccessContainer: Color(0xFF0A4B2D),
    warning: Color(0xFFA05E00),
    warningContainer: Color(0xFFFCE7C8),
    onWarningContainer: Color(0xFF4A2C00),
    info: Color(0xFF2B5DBE),
    infoContainer: Color(0xFFDCE7FC),
    onInfoContainer: Color(0xFF16346F),
  );

  static const dark = AppExtras(
    success: Color(0xFF5CCB93),
    successContainer: Color(0xFF123B27),
    onSuccessContainer: Color(0xFF99E8C2),
    warning: Color(0xFFF0B354),
    warningContainer: Color(0xFF4A3212),
    onWarningContainer: Color(0xFFFFD9A0),
    info: Color(0xFF93B0F5),
    infoContainer: Color(0xFF23365E),
    onInfoContainer: Color(0xFFCBDCFF),
  );

  static AppExtras forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
