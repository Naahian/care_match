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
    final foreground = message.isFromPatient
        ? scheme.onPrimary
        : scheme.onSurface;

    return Align(
      alignment: message.isFromPatient
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            color: message.isFromPatient ? scheme.primary : scheme.surface,
            borderRadius: AppRadius.card,
            border: message.isFromPatient
                ? null
                : Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  message.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: message.isFromPatient
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
