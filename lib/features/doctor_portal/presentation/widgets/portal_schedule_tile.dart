import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../models/portal_patient.dart';
import 'portal_patient_sheet.dart';

class PortalScheduleTile extends StatelessWidget {
  const PortalScheduleTile({
    super.key,
    required this.time,
    this.patient,
    this.isBreak = false,
  });
  final TimeOfDay time;
  final PortalPatient? patient;
  final bool isBreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entry = patient;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                time.format(context),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Card(
              color: entry == null ? scheme.surfaceContainer : scheme.surface,
              clipBehavior: Clip.antiAlias,
              child: entry == null && !isBreak
                  ? const SizedBox(height: 64)
                  : InkWell(
                      onTap: entry == null
                          ? null
                          : () => showPortalPatient(
                              context,
                              entry,
                              allowConsultationActions: false,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              isBreak
                                  ? Icons.restaurant_outlined
                                  : entry?.type.icon ?? Icons.remove_rounded,
                              size: 24,
                              color: entry?.type == PortalConsultation.chat
                                  ? scheme.secondary
                                  : scheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBreak ? 'Lunch break' : entry!.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    isBreak
                                        ? 'Personal time'
                                        : entry!.type.label,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (entry != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xs,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.secondaryContainer,
                                          borderRadius: AppRadius.chip,
                                        ),
                                        child: Text(
                                          entry.status == QueueStatus.completed
                                              ? 'Completed'
                                              : 'Confirmed',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    scheme.onSecondaryContainer,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
