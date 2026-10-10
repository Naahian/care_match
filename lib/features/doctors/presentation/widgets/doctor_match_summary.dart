import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DoctorMatchSummary extends StatelessWidget {
  const DoctorMatchSummary({super.key});
  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) => Column(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: AppSpacing.sm),
      Text(title, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xs),
      Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Container(
    padding: AppSpacing.card,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: AppRadius.card,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _item(
            context,
            Icons.medical_services_outlined,
            'Specialty',
            'Internal Medicine',
          ),
          _item(context, Icons.schedule_rounded, 'Urgency', 'Not assessed'),
          _item(context, Icons.language_rounded, 'Language', 'English'),
        ];
        if (constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.md),
                items[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: items[index]),
            ],
          ],
        );
      },
    ),
  );
}
