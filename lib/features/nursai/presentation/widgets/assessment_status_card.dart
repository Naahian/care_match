import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AssessmentStatusCard extends StatelessWidget {
  const AssessmentStatusCard({super.key, required this.activeStage});
  final int activeStage;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: AppRadius.input,
              ),
              child: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Assessing your\nsymptom details',
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (activeStage == 0)
              SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
