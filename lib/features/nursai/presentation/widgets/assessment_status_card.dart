import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AssessmentStatusCard extends StatelessWidget {
  const AssessmentStatusCard({super.key, required this.activeStage});
  final int activeStage;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = [
      'Reviewing your symptom details',
      'Preparing assessment preview',
      'Finding sample doctor matches',
    ];
    final icons = [
      Icons.description_outlined,
      Icons.schedule_rounded,
      Icons.person_search_outlined,
    ];
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            for (var index = 0; index < labels.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        icons[index],
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        labels[index],
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (index < activeStage)
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                      )
                    else if (index == activeStage)
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: theme.colorScheme.outline,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
