import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../profile/account_profile_provider.dart';
import '../../doctor_home/presentation/screens/doctor_home_screen.dart';
import 'home_screen.dart';

class RoleHomeScreen extends ConsumerWidget {
  const RoleHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(accountProfileProvider)
        .when(
          data: (profile) => profile.role == 'doctor'
              ? const DoctorHomeScreen()
              : const HomeScreen(),
          // Render the patient home shell while the profile request resolves.
          // Its own data sections show their existing shimmer placeholders.
          loading: () => const HomeScreen(),
          error: (_, _) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.text('Could not load your account.')),
                    TextButton(
                      onPressed: () => ref.invalidate(accountProfileProvider),
                      child: Text(l10n.text('Retry')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
