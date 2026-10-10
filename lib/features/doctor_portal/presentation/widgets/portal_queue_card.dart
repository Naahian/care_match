import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../models/portal_patient.dart';
import 'portal_patient_summary.dart';
import 'portal_patient_sheet.dart';

class PortalQueueCard extends StatelessWidget {
  const PortalQueueCard({super.key, required this.patient});
  final PortalPatient patient;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PortalPatientSummary(patient: patient, showPriority: true),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              TextButton(
                onPressed: () => showPortalPatient(context, patient),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                child: const Text('View details'),
              ),
              if (patient.status != QueueStatus.completed)
                FilledButton(
                  onPressed: () =>
                      showPortalPatient(context, patient, startConsult: true),
                  child: Text(
                    patient.status == QueueStatus.waiting
                        ? 'Start consult'
                        : 'Continue consult',
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
