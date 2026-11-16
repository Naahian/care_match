import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthHeading extends StatelessWidget {
  const AuthHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.leftAligned = false,
  });
  final bool leftAligned;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: leftAligned
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: leftAligned ? TextAlign.start : TextAlign.center,
          style:
              (leftAligned
                      ? theme.textTheme.headlineLarge
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: leftAligned ? TextAlign.start : TextAlign.center,
          style:
              (leftAligned
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.bodyLarge)
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
