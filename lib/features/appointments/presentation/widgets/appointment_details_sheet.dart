import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';

import '../models/appointment_draft.dart';
import '../models/appointment_entry.dart';

class AppointmentDetailsSheet extends StatelessWidget {
  const AppointmentDetailsSheet({super.key, required this.appointment});

  final AppointmentEntry appointment;

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: AppSpacing.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final (
      statusLabel,
      statusIcon,
      statusColor,
      statusBackground,
    ) = switch (appointment.status) {
      AppointmentStatus.upcoming => (
        'Upcoming',
        Icons.schedule_rounded,
        scheme.primary,
        scheme.primaryContainer,
      ),
      AppointmentStatus.completed => (
        'Completed',
        Icons.check_circle_outline_rounded,
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
      ),
      AppointmentStatus.cancelled => (
        'Cancelled',
        Icons.cancel_outlined,
        scheme.onErrorContainer,
        scheme.errorContainer,
      ),
    };

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Appointment details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close appointment details',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, scheme.surfaceContainerLow],
                ),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DoctorAvatar(doctorName: appointment.doctor.name),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctor.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              appointment.doctor.specialty,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: [
                  _detailRow(
                    context,
                    Icons.calendar_month_outlined,
                    'Date',
                    localizations.formatFullDate(appointment.dateTime),
                  ),
                  const Divider(
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _detailRow(
                    context,
                    Icons.schedule_rounded,
                    'Time',
                    '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(appointment.dateTime))} (${appointment.dateTime.timeZoneName})',
                  ),
                  const Divider(
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _detailRow(
                    context,
                    appointment.type.icon,
                    'Consultation type',
                    appointment.type.label,
                  ),
                  const Divider(
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _detailRow(
                    context,
                    appointment.type == ConsultationType.inPerson
                        ? Icons.location_on_outlined
                        : Icons.public_rounded,
                    'Location',
                    appointment.type == ConsultationType.inPerson
                        ? appointment.location
                        : 'Online',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.chip,
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
