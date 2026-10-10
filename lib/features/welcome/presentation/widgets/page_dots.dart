import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Animated pagination dots for the onboarding flow.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: AppConstants.animationDuration,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: AppSpacing.sm,
          height: AppSpacing.sm,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? scheme.primary : scheme.outlineVariant,
          ),
        );
      }),
    );
  }
}
