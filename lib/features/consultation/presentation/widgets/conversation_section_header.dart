import 'package:flutter/material.dart';

/// Section header: "Recent Conversations" with a "See all" action.
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
        TextButton(
          onPressed: () {
            // TODO: navigate to the full conversations list screen
          },
          child: Text(
            'See all',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
