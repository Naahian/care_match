import 'package:care_match/router.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'features/settings/preferences_controller.dart';

void main() {
  runApp(
    Sizer(
      builder: (context, _, _) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.router});

  final GoRouter? router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appPreferences,
      builder: (context, _) => MaterialApp.router(
        title: 'Care Match',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: appPreferences.themeMode,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: appPreferences.largerText
                  ? _LargerTextScaler(media.textScaler)
                  : media.textScaler,
            ),
            child: child!,
          );
        },
        routerConfig: router ?? appRouter,
      ),
    );
  }
}

class _LargerTextScaler extends TextScaler {
  const _LargerTextScaler(this.platformScaler);
  final TextScaler platformScaler;

  @override
  double scale(double fontSize) => platformScaler.scale(fontSize) * 1.2;

  @override
  double get textScaleFactor => scale(14) / 14;
}
