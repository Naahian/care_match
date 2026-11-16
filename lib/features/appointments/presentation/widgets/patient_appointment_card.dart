import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/doctor_avatar.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/patient_appointment.dart';
import 'appointment_patient_details.dart';

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onJoinVideo,
    this.onOpenChat,
    this.onComplete,
    this.isUpdating = false,
    this.errorMessage,
    this.role = AppointmentRole.patient,
  });
  final PatientAppointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onJoinVideo;
  final VoidCallback? onOpenChat;
  final VoidCallback? onComplete;
  final bool isUpdating;
  final String? errorMessage;
  final AppointmentRole role;

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
            if (role == AppointmentRole.doctor)
              AppointmentPatientDetails(appointment: record)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAvatar(
                    doctorName: doctor?.name ?? 'Doctor',
                    photoUrl: doctor?.photoUrl,
                    radius: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor?.name ?? 'Doctor details unavailable',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor == null || doctor.specialties.isEmpty
                              ? 'Specialty not provided'
                              : doctor.specialties.join(', '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: AppRadius.button,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(switch (record.status) {
                          AppointmentStatus.requested => 'Requested',
                          AppointmentStatus.confirmed => 'Confirmed',
                          AppointmentStatus.completed => 'Completed',
                          AppointmentStatus.cancelled => 'Cancelled',
                        }, style: theme.textTheme.labelSmall),
                      ),
                    ),
                  ),
                ],
              ),

            if (record.notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              _InfoStrip(
                child: Text(
                  'Notes: ${record.notes}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
            if (role == AppointmentRole.doctor ||
                record.type == AppointmentType.inPerson ||
                !record.isActive ||
                (record.type == AppointmentType.video && onJoinVideo == null) ||
                (record.type == AppointmentType.chat && onOpenChat == null))
              Text(record.type.label, style: theme.textTheme.labelLarge),
            _InfoStrip(
              child: Row(
                children: [
                  Expanded(
                    child: _ScheduleValue(
                      icon: Icons.calendar_month_outlined,
                      value: localizations.formatMediumDate(date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScheduleValue(
                      icon: Icons.schedule_rounded,
                      value: localizations.formatTimeOfDay(
                        TimeOfDay.fromDateTime(date),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (record.isActive) ...[
              const SizedBox(height: AppSpacing.sm),
              if (record.type == AppointmentType.video &&
                  onJoinVideo != null) ...[
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.card,
                    ),
                  ),
                  onPressed: isUpdating ? null : onJoinVideo,
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Join video consultation'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              if (record.type == AppointmentType.chat &&
                  onOpenChat != null) ...[
                OutlinedButton.icon(
                  onPressed: isUpdating ? null : onOpenChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Open chat consultation'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Completed Button
              if (role == AppointmentRole.doctor) ...[
                FilledButton.icon(
                  onPressed: isUpdating ? null : onComplete,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(isUpdating ? 'Updating…' : 'Mark as completed'),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Cancel Button
                OutlinedButton.icon(
                  onPressed: isUpdating ? null : onCancel,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.event_busy_outlined),
                  label: const Text('Cancel appointment'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: AppRadius.button,
    ),
    child: DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.bodySmall!,
      child: child,
    ),
  );
}

class _ScheduleValue extends StatelessWidget {
  const _ScheduleValue({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(value)),
    ],
  );
}
