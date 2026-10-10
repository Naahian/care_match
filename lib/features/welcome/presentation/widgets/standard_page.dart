import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'illustration_slot.dart';
import 'scrollable_fill.dart';

/// Pages 1–3: title, description, then the illustration below.
class StandardPage extends StatelessWidget {
  const StandardPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ScrollableFill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: IllustrationSlot(imageAsset: imageAsset)),
          ],
        ),
      ),
    );
  }
}
