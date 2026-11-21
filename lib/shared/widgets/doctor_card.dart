import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/widgets/doctor_summary.dart';
import 'doctor_avatar.dart';

/// Doctor summary, optionally tappable when an action is supplied.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.highlightAlt,
    this.onTap,
    this.price,
    this.directoryStyle = false,
    this.featured = false,
  });

  final DoctorSummary doctor;

  /// Alternates the availability chip color between cards.
  final bool highlightAlt;
  final VoidCallback? onTap;
  final String? price;
  final bool directoryStyle;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chipBackground = highlightAlt
        ? (directoryStyle ? scheme.errorContainer : scheme.tertiaryContainer)
        : scheme.secondaryContainer;
    final chipForeground = highlightAlt
        ? (directoryStyle
              ? scheme.onErrorContainer
              : scheme.onTertiaryContainer)
        : scheme.onSecondaryContainer;

    return Card(
      shape: directoryStyle || featured
          ? const RoundedRectangleBorder(borderRadius: AppRadius.sheet)
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  DoctorAvatar(
                    doctorName: doctor.name,
                    photoUrl: doctor.photoUrl,
                    radius: 26,
                  ),
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
                        if (featured) ...[
                          const SizedBox(height: 4),
                          Text(
                            doctor.availability,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right_rounded, color: scheme.outline),
                ],
              ),
              if (!featured) const SizedBox(height: AppSpacing.sm),
              if (!featured)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: chipBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    directoryStyle &&
                            !doctor.availability.toLowerCase().startsWith(
                              'availab',
                            )
                        ? 'Available: ${doctor.availability}'
                        : doctor.availability,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: chipForeground,
                    ),
                  ),
                ),
              if (price != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    price!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
