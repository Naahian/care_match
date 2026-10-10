import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../portal_controller.dart';
import '../models/portal_patient.dart';
import '../widgets/portal_scaffold.dart';
import '../widgets/portal_queue_card.dart';

class PatientQueueScreen extends StatefulWidget {
  const PatientQueueScreen({super.key});
  @override
  State<PatientQueueScreen> createState() => _PatientQueueScreenState();
}

class _PatientQueueScreenState extends State<PatientQueueScreen> {
  QueueStatus _status = QueueStatus.waiting;
  @override
  Widget build(BuildContext context) => PortalScaffold(
    current: 1,
    title: 'Patient Queue',
    child: ListenableBuilder(
      listenable: doctorPortal,
      builder: (context, _) {
        final patients = doctorPortal.patients
            .where((patient) => patient.status == _status)
            .toList();
        return ListView(
          padding: AppSpacing.page,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final status in QueueStatus.values)
                  ChoiceChip(
                    label: Text(
                      '${status.name[0].toUpperCase()}${status.name.substring(1)} (${doctorPortal.count(status)})',
                    ),
                    selected: _status == status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (patients.isEmpty)
              Padding(
                padding: AppSpacing.card,
                child: Text(
                  'No ${_status.name} patients.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            for (final patient in patients) ...[
              PortalQueueCard(patient: patient),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    ),
  );
}
