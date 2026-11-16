import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/shimmer.dart';

class ConversationCardShimmer extends StatelessWidget {
  const ConversationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacing.card,
        child: Shimmer(
          semanticLabel: 'Loading conversation',
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: base),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(base, 0.7, 18),
                    const SizedBox(height: AppSpacing.sm),
                    _bar(base, 0.5, 14),
                    const SizedBox(height: AppSpacing.sm),
                    _bar(base, 1, 14),
                    const SizedBox(height: AppSpacing.xs),
                    _bar(base, 0.8, 14),
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
            borderRadius: AppRadius.input,
          ),
        ),
      );
}
