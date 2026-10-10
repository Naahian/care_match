import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'upcoming_consultation.dart';

/// Card summarizing the next scheduled consultation: doctor, specialty and
/// time.
class UpcomingConsultationCard extends StatelessWidget {
  const UpcomingConsultationCard({
    super.key,
    required this.consultation,
  });

  final UpcomingConsultation consultation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final circle = 14.w.clamp(48.0, 64.0);

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Container(
            width: circle,
            height: circle,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_rounded,
              size: 22.sp,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your consultation is about to start',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${consultation.doctorName}  \u00B7  ${consultation.specialty}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(consultation.schedule, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
