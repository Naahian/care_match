import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'tip_row.dart';

/// Card listing preparation tips: where to join from, what you'll need and
/// how to reschedule.
class TipsCard extends StatelessWidget {
  const TipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            TipRow(
              icon: Icons.self_improvement_rounded,
              title: 'Before you join',
              description:
                  'Make sure you\u2019re in a quiet place with a '
                  'stable internet connection.',
            ),
            SizedBox(height: AppSpacing.lg),
            TipRow(
              icon: Icons.photo_camera_outlined,
              title: 'What you\u2019ll need',
              description:
                  'Camera, microphone and a recent health update '
                  '(if any).',
            ),
          ],
        ),
      ),
    );
  }
}
