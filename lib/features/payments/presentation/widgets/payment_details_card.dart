import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PaymentDetailsCard extends StatelessWidget {
  const PaymentDetailsCard({super.key, required this.details});
  final Map<String, String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in details.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
