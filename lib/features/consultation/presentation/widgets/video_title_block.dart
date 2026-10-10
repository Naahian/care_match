import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// "Video Consultation" headline and supporting copy.
class VideoTitleBlock extends StatelessWidget {
  const VideoTitleBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Consultation',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Talk face-to-face with your doctor. Get your questions answered '
          'in real time.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
