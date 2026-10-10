import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// "Chat & Video Consult" headline and supporting copy.
class ChatTitleBlock extends StatelessWidget {
  const ChatTitleBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chat & Video Consult',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Get expert advice, from anywhere. Chat or start a video '
          'consultation with your doctor.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
