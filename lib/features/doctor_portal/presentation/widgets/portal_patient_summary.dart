import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../models/portal_patient.dart';

class PortalPatientSummary extends StatelessWidget {
  const PortalPatientSummary({
    super.key,
    required this.patient,
    this.showPriority = false,
  });
  final PortalPatient patient;
  final bool showPriority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (color, background) = switch (patient.priority) {
      PatientPriority.high => (scheme.error, scheme.errorContainer),
      PatientPriority.medium => (scheme.tertiary, scheme.tertiaryContainer),
      PatientPriority.low => (scheme.secondary, scheme.secondaryContainer),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: scheme.secondaryContainer,
          child: Text(
            patient.name
                .trim()
                .split(RegExp(r'\s+'))
                .where((part) => part.isNotEmpty)
                .map((part) => part[0])
                .take(2)
                .join(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    patient.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  if (showPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        patient.priority.name[0].toUpperCase() +
                            patient.priority.name.substring(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                '${patient.age == 0 ? 'New patient' : '${patient.age} years'} · ${patient.reason}',
                style: theme.textTheme.bodySmall,
              ),
              if (showPriority)
                Text(patient.symptoms, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    patient.type.icon,
                    size: 18,
                    color: patient.type == PortalConsultation.chat
                        ? scheme.secondary
                        : scheme.primary,
                  ),
                  Text(
                    '${patient.type.label}  |  ${patient.time.format(context)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
