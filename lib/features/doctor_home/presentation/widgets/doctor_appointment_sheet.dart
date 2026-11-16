import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/presentation/widgets/appointment_patient_details.dart';

class DoctorAppointmentSheet extends StatelessWidget {
  const DoctorAppointmentSheet({super.key, required this.appointment});
  final Appointment appointment;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: AppSpacing.page,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Appointment details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppointmentPatientDetails(appointment: appointment),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MaterialLocalizations.of(
              context,
            ).formatFullDate(appointment.scheduledFor.toLocal()),
          ),
          Text(
            '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(appointment.scheduledFor.toLocal()))} · ${appointment.type.label}',
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutes.appointments);
            },
            child: const Text('Manage appointments'),
          ),
        ],
      ),
    ),
  );
}
