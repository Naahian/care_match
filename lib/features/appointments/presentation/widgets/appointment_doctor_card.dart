import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
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
                  photoUrl: doctor.summary.photoUrl,
                  radius: 26,
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
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!showProfileDetails) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(draft.type.icon, color: scheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      draft.type.label,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      draft.priceFor(draft.type),
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (showProfileDetails) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final area in doctor.careAreas.take(2)) ...[
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
                    if (area != doctor.careAreas.take(2).last)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
