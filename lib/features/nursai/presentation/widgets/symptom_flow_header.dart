import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// Shared chrome for the three-step NurseAI symptom flow.
class SymptomFlowHeader extends StatelessWidget {
  const SymptomFlowHeader({
    super.key,
    required this.title,
    required this.currentStep,
    this.onBack,
  });

  final String title;
  final int currentStep;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Go back',
                child: IconButton.filled(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.onSurface,
                    fixedSize: const Size(42, 42),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                '0$currentStep / 03',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(3, (index) {
              final complete = index < currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: complete ? colors.primary : colors.outlineVariant,
                    borderRadius: AppRadius.chip,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
