import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/triage_assessment.dart';

class TriageResultCard extends StatelessWidget {
  const TriageResultCard({super.key, required this.assessment});
  final TriageAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final urgency = switch (assessment.urgency) {
      TriageUrgency.low => (
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        icon: Icons.shield_outlined,
      ),
      TriageUrgency.medium => (
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
        icon: Icons.schedule_rounded,
      ),
      TriageUrgency.high => (
        background: colors.errorContainer,
        foreground: colors.onErrorContainer,
        icon: Icons.priority_high_rounded,
      ),
      TriageUrgency.emergency => (
        background: colors.error,
        foreground: colors.onError,
        icon: Icons.emergency_outlined,
      ),
    };

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Assessment results', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: urgency.background,
                borderRadius: AppRadius.input,
              ),
              child: Row(
                children: [
                  Icon(urgency.icon, color: urgency.foreground),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Urgency: ${assessment.urgency.name.toUpperCase()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: urgency.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Assessment summary',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              assessment.summary,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            if (assessment.urgency == TriageUrgency.emergency) ...[
              const SizedBox(height: AppSpacing.md),
              _alert(
                context,
                'Seek emergency medical care now. Do not wait for a routine appointment.',
              ),
            ],
            if (assessment.redFlags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _redFlags(context),
            ],
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Recommended specialties',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (assessment.recommendedSpecialties.isEmpty)
              Text(
                'No specialties were provided.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final specialty in assessment.recommendedSpecialties)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: AppRadius.input,
                      ),
                      child: Text(
                        specialty,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _redFlags(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.input,
      ),
      child: Text(
        'Red flags: ${assessment.redFlags.join(' · ')}',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.onErrorContainer),
      ),
    );
  }

  Widget _alert(BuildContext context, String message) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: AppRadius.input,
    ),
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onErrorContainer,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
