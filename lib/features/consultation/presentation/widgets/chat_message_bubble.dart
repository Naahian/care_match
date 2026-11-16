import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = message.isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * .85),
          child: Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: message.isMine ? scheme.primary : scheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isMine ? 20 : 5),
                bottomRight: Radius.circular(message.isMine ? 5 : 20),
              ),
              border: message.isMine
                  ? null
                  : Border.all(color: scheme.outlineVariant),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      message.time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: message.isMine
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
