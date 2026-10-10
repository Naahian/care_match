import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:care_match/shared/widgets/doctor_summary.dart';
import 'package:flutter/material.dart';
import '../models/appointment_entry.dart';
import '../models/appointment_draft.dart';

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    required this.onView,
    required this.onPrimary,
  });
  final AppointmentEntry appointment;
  final VoidCallback onView;
  final VoidCallback onPrimary;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final upcoming = appointment.status == AppointmentStatus.upcoming;
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DoctorCard(
              doctor: DoctorSummary(
                name: appointment.doctor.name,
                specialty: appointment.doctor.specialty,
                availability: upcoming
                    ? (DateUtils.isSameDay(appointment.dateTime, DateTime.now())
                          ? 'Today'
                          : 'Confirmed')
                    : (appointment.status == AppointmentStatus.completed
                          ? 'Completed'
                          : 'Cancelled'),
              ),
              highlightAlt: appointment.status != AppointmentStatus.upcoming,
              onTap: onView,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: theme.colorScheme.primary,
                ),
                Text(localizations.formatMediumDate(appointment.dateTime)),
                Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                Text(
                  localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(appointment.dateTime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(appointment.type.icon, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    appointment.type.label,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (appointment.type == ConsultationType.inPerson) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(appointment.location, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (upcoming && appointment.type != ConsultationType.inPerson) ...[
              FilledButton.icon(
                onPressed: onPrimary,
                label: Text(
                  appointment.type == ConsultationType.video
                      ? 'Join video'
                      : 'Join chat',
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            OutlinedButton(
              onPressed: onView,
              child: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}
