import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class SymptomQuestionCard extends StatelessWidget {
  const SymptomQuestionCard({
    super.key,
    required this.title,
    required this.step,
    required this.icon,
    required this.child,
  });
  final String title;
  final String step;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  step,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
