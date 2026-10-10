import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/medical_report.dart';

class MedicalReportCard extends StatelessWidget {
  const MedicalReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onDownload,
    this.latest = false,
  });
  final MedicalReport report;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final bool latest;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: latest ? scheme.secondaryContainer : scheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(report.category.icon, color: scheme.primary, size: 32),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          report.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        if (latest)
                          Text(
                            'Latest',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                      ],
                    ),
                    Text(report.doctor, style: theme.textTheme.bodyMedium),
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(report.date),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${report.category.description} · PDF · ${report.size}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Download ${report.title}',
                onPressed: onDownload,
                icon: Icon(Icons.download_rounded, color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
