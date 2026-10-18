import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Hero block: "Find a Doctor" headline, supporting copy and a decorative
/// illustration slot.
class FindDoctorTitleBlock extends StatelessWidget {
  const FindDoctorTitleBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find a Doctor',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Search by specialty, name, or clinic.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Image.asset(
          'assets/images/leaf.png',
          width: 18.w.clamp(64.0, 110.0),
          height: 18.w.clamp(64.0, 110.0),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ],
    );
  }
}
