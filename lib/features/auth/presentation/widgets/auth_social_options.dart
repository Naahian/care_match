import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthSocialOptions extends StatelessWidget {
  const AuthSocialOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        foregroundColor: scheme.onPrimaryContainer,
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      onPressed: () {
        // TODO: connect Google sign-in and route after authentication.
      },
      // TODO: add the Google logo asset.
      child: const Text('Continue with Google'),
    );
  }
}
