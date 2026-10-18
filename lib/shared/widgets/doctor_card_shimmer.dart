import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'shimmer.dart';

class DoctorCardShimmer extends StatelessWidget {
  const DoctorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacing.card,
        child: Shimmer(
          semanticLabel: 'Loading doctor',
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
      ),
    );
  }

  Widget _bar(Color color, double widthFactor, double height) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
}
