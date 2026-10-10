import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../portal_controller.dart';
import '../models/portal_patient.dart';
import 'portal_patient_summary.dart';

Future<void> showPortalPatient(
  BuildContext context,
  PortalPatient patient, {
  bool startConsult = false,
  bool allowConsultationActions = true,
}) async {
  if (allowConsultationActions &&
      startConsult &&
      patient.status == QueueStatus.waiting) {
    doctorPortal.setStatus(patient.id, QueueStatus.ongoing);
  }
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (context) => ListenableBuilder(
      listenable: doctorPortal,
      builder: (context, _) {
        final current = doctorPortal.patientById(patient.id) ?? patient;
        return SingleChildScrollView(
          padding: AppSpacing.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                startConsult ? 'Consultation preview' : 'Patient details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              PortalPatientSummary(patient: current, showPriority: true),
              const SizedBox(height: AppSpacing.md),
              Text('Status: ${current.status.name}'),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Sample patient information. Live chat, video, and patient records will be available when consultation services are connected.',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (allowConsultationActions &&
                  current.status != QueueStatus.completed)
                FilledButton(
                  onPressed: () => doctorPortal.setStatus(
                    current.id,
                    current.status == QueueStatus.waiting
                        ? QueueStatus.ongoing
                        : QueueStatus.completed,
                  ),
                  child: Text(
                    current.status == QueueStatus.waiting
                        ? 'Start consult'
                        : 'Mark completed',
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    ),
  );
}
