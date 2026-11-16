import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import '../models/appointment_draft.dart';

class AppointmentSummaryCard extends StatelessWidget {
  const AppointmentSummaryCard({super.key, required this.draft});
  final AppointmentDraft draft;

  Widget _fact(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DoctorAvatar(
                  doctorName: draft.doctor.summary.name,
                  photoUrl: draft.doctor.summary.photoUrl,
                  radius: 26,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.doctor.summary.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        draft.doctor.summary.specialty,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (draft.doctor.hospital != 'Not provided') ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          draft.doctor.hospital,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (draft.doctor.careAreas.isNotEmpty) ...[
              Row(
                children: [
                  for (final area in draft.doctor.careAreas.take(2))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: AppRadius.button,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              area,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                  Theme.of(context).colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Availability · ${draft.doctor.daysAvailable.length == 7 ? 'Monday – Sunday' : draft.doctor.summary.availability}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _fact(
                    context,
                    Icons.calendar_month_outlined,
                    'Date',
                    draft.date == null
                        ? 'Not selected'
                        : localizations.formatMediumDate(draft.date!),
                  ),
                ),
                Expanded(
                  child: _fact(
                    context,
                    Icons.schedule_rounded,
                    'Time',
                    draft.scheduledAt == null || draft.time == null
                        ? 'Not selected'
                        : '${localizations.formatTimeOfDay(draft.time!)} (${draft.scheduledAt!.timeZoneName})',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _fact(
                    context,
                    draft.type.icon,
                    'Consultation type',
                    draft.type.label,
                  ),
                ),
                Expanded(
                  child: _fact(
                    context,
                    Icons.location_on_outlined,
                    'Location',
                    draft.type == ConsultationType.inPerson
                        ? draft.doctor.hospital
                        : 'Online',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
