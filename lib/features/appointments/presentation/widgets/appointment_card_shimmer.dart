import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/shimmer.dart';

class AppointmentCardShimmer extends StatelessWidget {
  const AppointmentCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Shimmer(
          semanticLabel: 'Loading appointment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    CircleAvatar(radius: 36, backgroundColor: base),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bar(base, 0.8, 18),
                          const SizedBox(height: AppSpacing.xs),
                          _bar(base, 0.6, 16),
                          const SizedBox(height: AppSpacing.sm),
                          _bar(base, 0.5, 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _bar(base, 0.65, 18),
              const SizedBox(height: AppSpacing.sm),
              _bar(base, 0.85, 16),
              const SizedBox(height: AppSpacing.sm),
              _bar(base, 0.6, 14),
              const SizedBox(height: AppSpacing.md),
              _bar(base, 1, 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(Color color, double widthFactor, double height) => Align(
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.input),
      ),
    ),
  );
}
