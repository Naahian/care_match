import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';

import 'conversation.dart';

/// Card for one recent conversation: avatar, name, last message, timestamp
/// and a quick video-consult button.
class ConversationCard extends StatelessWidget {
  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onVideoTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onVideoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DoctorAvatar(
                    doctorName: conversation.peerName,
                    photoUrl: conversation.photoUrl,
                    radius: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.peerName,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          conversation.time,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.primary),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                conversation.lastMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
