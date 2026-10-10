import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DoctorConsultationOption extends StatelessWidget {
  const DoctorConsultationOption({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.sm,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          price,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
