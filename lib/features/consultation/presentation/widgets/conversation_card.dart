import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
    final extras = theme.extension<AppExtras>()!;

    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final videoSize = 10.w.clamp(34.0, 44.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + timestamp.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoctorAvatar(
                    doctorName: conversation.doctorName,
                    radius: 10.w.clamp(28.0, 42.0),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(conversation.time, style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        if (conversation.isOnline) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: extras.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      conversation.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      conversation.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: onVideoTap,
                tooltip: 'Start video consult',
                iconSize: 15.sp,
                style: IconButton.styleFrom(
                  minimumSize: Size.square(videoSize),
                  maximumSize: Size.square(videoSize),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.videocam_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
