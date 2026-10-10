import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthSocialOptions extends StatelessWidget {
  const AuthSocialOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'or continue with',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.onPrimaryContainer,
            backgroundColor: scheme.surface,
            side: BorderSide(color: scheme.outlineVariant),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
          ),
          onPressed: () {
            // TODO: connect Google sign-in and route after authentication.
          },
          // TODO: add the Google logo asset.
          child: const Text('Continue with Google'),
        ),
      ],
    );
  }
}
