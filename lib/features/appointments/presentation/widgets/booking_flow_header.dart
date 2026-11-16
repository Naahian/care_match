import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Compact header shared by the two appointment-booking steps.
class BookingFlowHeader extends StatelessWidget {
  const BookingFlowHeader({super.key, required this.title, required this.step});

  final String title;
  final int step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filled(
                tooltip: 'Go back',
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.surface,
                  foregroundColor: scheme.onPrimaryContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '0$step / 02',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: AppRadius.chip,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: step == 2 ? scheme.primary : scheme.outlineVariant,
                    borderRadius: AppRadius.chip,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
