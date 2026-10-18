import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import 'auth_primary_button.dart';

class EmailVerificationDialog extends StatelessWidget {
  const EmailVerificationDialog({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      scrollable: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      icon: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: scheme.primary,
              size: 40,
            ),
          ),
        ),
      ),
      title: const Text(
        'Verify email before sign in',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your account is ready! We sent a verification link to',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            email,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Open the link in your inbox to verify your email, then come back to sign in. Check your spam folder if you don’t see it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        AuthPrimaryButton(
          label: 'Go to sign in',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
