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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isAvailable
                ? scheme.secondaryContainer
                : scheme.primaryContainer,
            borderRadius: AppRadius.button,
          ),
          child: Icon(
            icon,
            color: isAvailable ? scheme.secondary : scheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
