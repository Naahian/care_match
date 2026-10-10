import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/widgets/doctor_summary.dart';
import 'doctor_avatar.dart';

/// Tappable card summarizing a doctor: photo, name, specialty, availability.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.highlightAlt,
    required this.onTap,
    this.price,
  });

  final DoctorSummary doctor;

  /// Alternates the availability chip color between cards.
  final bool highlightAlt;
  final VoidCallback onTap;
  final String? price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chipBackground = highlightAlt
        ? scheme.tertiaryContainer
        : scheme.secondaryContainer;
    final chipForeground = highlightAlt
        ? scheme.onTertiaryContainer
        : scheme.onSecondaryContainer;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              DoctorAvatar(doctorName: doctor.name, radius: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + AppSpacing.xs,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: chipBackground,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            doctor.availability,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: chipForeground,
                            ),
                          ),
                        ),
                        if (price != null)
                          Text(
                            price!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
