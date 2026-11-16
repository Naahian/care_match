import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/appointment.dart';

class AppointmentPatientDetails extends StatelessWidget {
  const AppointmentPatientDetails({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final patient = appointment.patient;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                appointment.patientName ??
                    patient?.name ??
                    'Patient name unavailable',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xs,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                switch (appointment.status) {
                  AppointmentStatus.requested => 'Requested',
                  AppointmentStatus.confirmed => 'Confirmed',
                  AppointmentStatus.completed => 'Completed',
                  AppointmentStatus.cancelled => 'Cancelled',
                },
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Reason : ${appointment.reason}'),
        if (patient?.email != null) Text('Email: ${patient!.email}'),
        if (patient?.phoneNumber != null)
          Text('Phone: ${patient!.phoneNumber}'),
      ],
    );
  }
}
