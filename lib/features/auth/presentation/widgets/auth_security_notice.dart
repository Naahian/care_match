import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthSecurityNotice extends StatelessWidget {
  const AuthSecurityNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.secondaryContainer,
            child: Icon(Icons.lock_rounded, color: scheme.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your information is secure\nand never shared with third parties.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
