import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/doctor_summary.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient_appointment.dart';

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.isUpdating = false,
    this.errorMessage,
  });
  final PatientAppointment appointment;
  final VoidCallback? onCancel;
  final bool isUpdating;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final record = appointment.appointment;
    final doctor = appointment.doctor;
    final date = record.scheduledFor.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DoctorCard(
              doctor: DoctorSummary(
                name: doctor?.name ?? 'Doctor details unavailable',
                specialty: doctor == null || doctor.specialties.isEmpty
                    ? 'Specialty not provided'
                    : doctor.specialties.join(', '),
                availability: switch (record.status) {
                  AppointmentStatus.requested => 'Requested',
                  AppointmentStatus.confirmed => 'Confirmed',
                  AppointmentStatus.completed => 'Completed',
                  AppointmentStatus.cancelled => 'Cancelled',
                },
                availableToday: false,
              ),
              highlightAlt: !record.canCancel,
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
                Text(localizations.formatMediumDate(date)),
                Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                Text(
                  localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date)),
                ),
              ],
            ),
            if (record.reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Reason: ${record.reason}'),
            ],
            if (record.notes != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Notes: ${record.notes}', style: theme.textTheme.bodySmall),
            ],
            if (record.videoRoomId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text('Video room assigned'),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (record.canCancel) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isUpdating ? null : onCancel,
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.event_busy_outlined),
                label: Text(isUpdating ? 'Cancelling…' : 'Cancel appointment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
