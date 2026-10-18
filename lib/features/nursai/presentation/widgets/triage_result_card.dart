import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/triage_assessment.dart';

class TriageResultCard extends StatelessWidget {
  const TriageResultCard({super.key, required this.assessment});
  final TriageAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Urgency: ${assessment.urgency.name.toUpperCase()}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: assessment.urgency == TriageUrgency.emergency
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            if (assessment.urgency == TriageUrgency.emergency) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Seek emergency medical care now. Do not wait for a routine appointment.',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(assessment.summary),
            if (assessment.redFlags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Red flags', style: theme.textTheme.titleSmall),
              for (final flag in assessment.redFlags) Text('• $flag'),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('Recommended specialties', style: theme.textTheme.titleSmall),
            Text(
              assessment.recommendedSpecialties.isEmpty
                  ? 'No specialties were provided.'
                  : assessment.recommendedSpecialties.join(', '),
            ),
          ],
        ),
      ),
    );
  }
}
