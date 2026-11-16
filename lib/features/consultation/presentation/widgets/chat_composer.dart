import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.readOnly = false,
    this.isSending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled, readOnly, isSending;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled || readOnly,
                readOnly: readOnly,
                maxLength: 4000,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(borderRadius: AppRadius.card),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, _) => IconButton.filled(
                tooltip: 'Send message',
                style: IconButton.styleFrom(
                  minimumSize: const Size(56, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                  ),
                ),
                onPressed: !enabled || value.text.trim().isEmpty
                    ? null
                    : onSend,
                icon: isSending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
