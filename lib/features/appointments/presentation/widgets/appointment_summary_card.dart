import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/features/appointments/presentation/widgets/appointment_doctor_card.dart';
import 'package:flutter/material.dart';
import '../models/appointment_draft.dart';

class AppointmentSummaryCard extends StatelessWidget {
  const AppointmentSummaryCard({super.key, required this.draft});
  final AppointmentDraft draft;

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
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
            AppointmentDoctorCard(draft: draft, showProfileDetails: true),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            _row(
              context,
              Icons.calendar_month_outlined,
              'Date',
              draft.date == null
                  ? 'Not selected'
                  : localizations.formatMediumDate(draft.date!),
            ),
            _row(
              context,
              Icons.schedule_rounded,
              'Time',
              draft.time == null
                  ? 'Not selected'
                  : '${localizations.formatTimeOfDay(draft.time!)} (${draft.scheduledAt!.timeZoneName})',
            ),
            _row(
              context,
              draft.type.icon,
              'Consultation type',
              draft.type.label,
            ),
            _row(
              context,
              Icons.local_hospital_outlined,
              'Location',
              draft.type == ConsultationType.inPerson
                  ? draft.doctor.hospital
                  : 'Online',
            ),
          ],
        ),
      ),
    );
  }
}
