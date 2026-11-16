import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import 'doctor_profile.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key, required this.profile, this.portrait});
  final DoctorProfile profile;
  final Widget? portrait;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final areas = profile.careAreas.take(2).toList();
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            Row(
              children: [
                portrait ??
                    DoctorAvatar(
                      doctorName: profile.summary.name,
                      photoUrl: profile.summary.photoUrl,
                      radius: 52,
                    ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.summary.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs + 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          profile.daysAvailable.length == 7
                              ? '•  Available daily'
                              : profile.summary.availability,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (areas.isNotEmpty)
              Row(
                children: [
                  for (final area in areas) ...[
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: AppRadius.button,
                        ),
                        child: Text(area, style: theme.textTheme.labelSmall),
                      ),
                    ),
                    if (area != areas.last)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
