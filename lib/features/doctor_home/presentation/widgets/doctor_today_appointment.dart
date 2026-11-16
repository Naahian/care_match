import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../appointments/domain/entities/appointment.dart';

class DoctorTodayAppointment extends StatelessWidget {
  const DoctorTodayAppointment({
    super.key,
    required this.appointment,
    required this.onView,
  });
  final Appointment appointment;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name =
        appointment.patientName ?? appointment.patient?.name ?? 'Patient';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .where((word) => word.isNotEmpty)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
    final icon = switch (appointment.type) {
      AppointmentType.video => Icons.videocam_outlined,
      AppointmentType.chat => Icons.chat_bubble_outline,
      AppointmentType.inPerson => Icons.location_on_outlined,
    };
    return Card(
      child: InkWell(
        onTap: onView,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: scheme.secondaryContainer,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay.fromDateTime(
                          appointment.scheduledFor.toLocal(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(icon, color: scheme.primary, size: 20),
                        Text(
                          appointment.type.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View appointment for $name',
                onPressed: onView,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
