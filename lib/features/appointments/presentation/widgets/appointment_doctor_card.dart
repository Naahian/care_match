import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import '../models/appointment_draft.dart';

class AppointmentDoctorCard extends StatelessWidget {
  const AppointmentDoctorCard({
    super.key,
    required this.draft,
    this.showProfileDetails = false,
  });
  final AppointmentDraft draft;
  final bool showProfileDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doctor = draft.doctor;
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DoctorAvatar(
                  doctorName: doctor.summary.name,
                  radius: 10.w.clamp(28.0, 44.0),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.summary.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        doctor.summary.specialty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (showProfileDetails) ...[
                        Text(doctor.hospital, style: theme.textTheme.bodySmall),
                      ] else
                        Wrap(
                          spacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                              draft.type.icon,
                              color: scheme.primary,
                              size: 20,
                            ),
                            Text(
                              draft.type.label,
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              draft.priceFor(draft.type),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (showProfileDetails) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final area in doctor.careAreas.take(2))
                    Chip(
                      label: Text(area),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                      ),
                      backgroundColor: scheme.primaryContainer,
                      side: BorderSide.none,
                    ),
                  Chip(
                    label: Text(doctor.summary.availability),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                    backgroundColor: scheme.secondaryContainer,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
