import 'package:care_match/router.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'features/settings/preferences_controller.dart';
import 'core/services/snackbar_service.dart';
import 'core/services/storage_service.dart';
import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final isFirstOpen = await storage.checkAndMarkFirstOpen();
  await bootstrap(
    Sizer(
      builder: (context, _, _) {
        return MyApp(isFirstOpen: isFirstOpen);
      },
    ),
    storage: storage,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.router, this.isFirstOpen = true});

  final GoRouter? router;
  final bool isFirstOpen;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (router != null) return _buildApp(router!);
    return Consumer(
      builder: (_, ref, _) =>
          _buildApp(ref.watch(appRouterProvider(isFirstOpen))),
    );
  }

  Widget _buildApp(GoRouter appRouter) {
    return ListenableBuilder(
      listenable: appPreferences,
      builder: (context, _) => MaterialApp.router(
        title: 'Care Match',
        scaffoldMessengerKey: snackbar.messengerKey,
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
        routerConfig: appRouter,
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
