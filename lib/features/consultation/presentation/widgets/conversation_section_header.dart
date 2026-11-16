import 'package:flutter/material.dart';

/// Section header for the conversation inbox.
class ConversationSectionHeader extends StatelessWidget {
  const ConversationSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Conversations',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
