import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Bottom call-to-action banner prompting the user to find a doctor to chat
/// or video consult with.
class FindDoctorBanner extends StatelessWidget {
  const FindDoctorBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final circle = 14.w.clamp(48.0, 64.0);

    return Material(
      color: scheme.primaryContainer,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: circle,
                height: circle,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 22.sp,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a doctor to chat or video',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Get matched with the right specialist',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
