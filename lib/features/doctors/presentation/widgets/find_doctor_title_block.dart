import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Hero block: "Find a Doctor" headline, supporting copy and a decorative
/// illustration slot.
class FindDoctorTitleBlock extends StatelessWidget {
  const FindDoctorTitleBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find a doctor',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Search by specialty, name, or clinic.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
