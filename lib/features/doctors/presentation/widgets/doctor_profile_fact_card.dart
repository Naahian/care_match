import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DoctorProfileFactCard extends StatelessWidget {
  const DoctorProfileFactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isAvailable = false,
  });
  final IconData icon;
  final String title;
  final String value;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isAvailable ? scheme.secondary : scheme.primary,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isAvailable
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
